"""Tests unitarios de p10jj.core.generar (sin red, con mock de ChatGroq).

Estos tests NO consumen cuota de Groq. Los tests de integración van en
test_generar_integration.py y se ejecutan opcionalmente con:

    uv run pytest -m integration
"""

from unittest.mock import MagicMock, patch


def test_invoca_provider_y_devuelve_string():
    """generar() invoca al LLM y devuelve el contenido como string."""
    # Import diferido: si el módulo no existe, el test falla con un error
    # claro (en vez de hacer caer toda la carga del archivo).
    from p10jj.core import generar

    # Preparamos un mock de respuesta como la que devuelve ChatGroq.invoke()
    fake_response = MagicMock(content="Texto generado de prueba")

    # Parchamos ChatGroq en el namespace de p10jj.core (donde se usa).
    # Cuando core.py haga `ChatGroq(...)`, recibirá nuestro mock.
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
