"""Tests unitarios de p10jj.core.generar (sin red, con mock de ChatGroq).

Estos tests NO consumen cuota de Groq. Los tests de integracion van en
test_generar_integration.py y se ejecutan opcionalmente con:

    uv run pytest -m integration
"""

from unittest.mock import MagicMock, patch

import pytest


def test_invoca_provider_y_devuelve_string():
    """generar() invoca al LLM y devuelve el contenido como string."""
    # Import diferido: si el modulo no existe, el test falla con un error
    # claro (en vez de hacer caer toda la carga del archivo).
    from p10jj.core import generar

    # Preparamos un mock de respuesta como la que devuelve ChatGroq.invoke()
    fake_response = MagicMock(content="Texto generado de prueba")

    # Parchamos ChatGroq en el namespace de p10jj.core (donde se usa).
    # Cuando core.py haga `ChatGroq(...)`, recibira nuestro mock.
    with patch("p10jj.core.ChatGroq") as mock_chatgroq:
        mock_instance = MagicMock()
        mock_instance.invoke.return_value = fake_response
        mock_chatgroq.return_value = mock_instance

        resultado = generar(
            tema="Python en 2026",
            plataforma="blog",
            audiencia="tecnica",
        )

    # Verificaciones
    assert isinstance(resultado, str), "El resultado debe ser str"
    assert resultado == "Texto generado de prueba"
    assert mock_instance.invoke.call_count == 1


@pytest.mark.parametrize("tono_invalido", [-0.1, -1.0, 1.01, 1.5, 99.0])
def test_lanza_value_error_si_tono_fuera_de_rango(tono_invalido: float) -> None:
    """generar() debe lanzar ValueError si tono no esta en [0.0, 1.0]."""
    from p10jj.core import generar

    with pytest.raises(ValueError, match="tono"):
        generar(
            tema="cualquier tema",
            plataforma="blog",
            tono=tono_invalido,
        )
