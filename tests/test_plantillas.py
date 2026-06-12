"""Tests unitarios de las plantillas en src/p10jj/prompts/."""

from pathlib import Path

import pytest

# Las plantillas viven dentro del paquete src/p10jj/prompts/.
# Resolvemos la ruta de forma absoluta y robusta a CWD.
PROMPTS_DIR = Path(__file__).resolve().parent.parent / "src" / "p10jj" / "prompts"

PLATAFORMAS = ["blog", "twitter", "instagram", "linkedin"]
MARCADORES_OBLIGATORIOS = [
    "{tema}",
    "{audiencia}",
    "{plataforma}",
    "{max_palabras}",
]


@pytest.mark.parametrize("plataforma", PLATAFORMAS)
def test_todas_las_plantillas_tienen_marcadores(plataforma: str) -> None:
    """Cada plantilla debe contener los 4 marcadores obligatorios."""
    ruta = PROMPTS_DIR / f"{plataforma}.md"
    assert ruta.exists(), f"Plantilla no encontrada: {ruta}"

    contenido = ruta.read_text(encoding="utf-8")
    for marcador in MARCADORES_OBLIGATORIOS:
        assert marcador in contenido, (
            f"Plantilla {plataforma}.md no contiene el marcador {marcador}"
        )


@pytest.mark.parametrize("plataforma", PLATAFORMAS)
def test_plantillas_son_utf8(plataforma: str) -> None:
    """Cada plantilla debe poder leerse como UTF-8 sin errores."""
    ruta = PROMPTS_DIR / f"{plataforma}.md"
    assert ruta.exists(), f"Plantilla no encontrada: {ruta}"

    try:
        ruta.read_text(encoding="utf-8")
    except UnicodeDecodeError as e:
        pytest.fail(f"Plantilla {plataforma}.md no es UTF-8 válido: {e}")
