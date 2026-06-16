"""Tests unitarios de p10jj.core.generar (sin red, con mocks).

Estos tests NO consumen cuota de Groq. Los tests de integracion van en
test_generar_integration.py y se ejecutan opcionalmente con:

    uv run pytest -m integration
"""

from unittest.mock import MagicMock, patch

import pytest


def test_invoca_provider_y_devuelve_string():
    """generar() invoca al LLM y devuelve el contenido como string."""
    from p10jj.core import generar

    # Mock del LLM completo (no de ChatGroq): es lo que devuelve get_groq_llm()
    fake_response = MagicMock(content="Texto generado de prueba")
    mock_llm = MagicMock()
    mock_llm.invoke.return_value = fake_response

    # Parchamos get_groq_llm en el namespace de p10jj.core
    with patch("p10jj.core.get_groq_llm", return_value=mock_llm):
        resultado = generar(
            tema="Python en 2026",
            plataforma="blog",
            audiencia="tecnica",
        )

    assert isinstance(resultado, str), "El resultado debe ser str"
    assert resultado == "Texto generado de prueba"
    assert mock_llm.invoke.call_count == 1


@pytest.mark.parametrize("tono_invalido", [-0.1, -1.0, 1.01, 1.5, 99.0])
def test_lanza_value_error_si_tono_fuera_de_rango(tono_invalido: float) -> None:
    """generar() debe lanzar ValueError si tono no esta en [0.0, 1.0]."""
    from p10jj.core import generar

    # Tambien parcheamos get_groq_llm para que el test no toque ChatGroq real
    with patch("p10jj.core.get_groq_llm"), pytest.raises(ValueError, match="tono"):
        generar(
            tema="cualquier tema",
            plataforma="blog",
            tono=tono_invalido,
        )


def test_lanza_provider_error_tras_3_fallos():
    """get_groq_llm().invoke() lanza ProviderError tras 3 fallos consecutivos.

    Parcheamos ChatGroq dentro de providers.groq para que .invoke() siempre
    falle. Esperamos que tenacity reintente 3 veces y luego se lance ProviderError.
    """
    from p10jj.providers.groq import ProviderError, get_groq_llm

    # ChatGroq mockeado: su .invoke() siempre lanza una excepcion
    with patch("p10jj.providers.groq.ChatGroq") as mock_chatgroq_cls:
        mock_instance = MagicMock()
        mock_instance.invoke.side_effect = RuntimeError("Error simulado de Groq")
        mock_chatgroq_cls.return_value = mock_instance

        llm = get_groq_llm(max_attempts=3)

        with pytest.raises(ProviderError) as exc_info:
            llm.invoke("cualquier prompt")

    # Verificaciones
    assert "3 intentos" in str(exc_info.value)
    assert exc_info.value.ultimo_error is not None
    assert mock_instance.invoke.call_count == 3
