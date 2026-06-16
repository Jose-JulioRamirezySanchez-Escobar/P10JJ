"""Core del generador de contenido P10JJ.

Paso 5: carga de plantillas .md desde src/p10jj/prompts/.
Paso 5b: validacion de tono fuera de rango (ValueError).
Paso 6: usa p10jj.providers.groq.get_groq_llm (tenacity + ProviderError).
"""

from pathlib import Path
from typing import Literal

from p10jj.providers.groq import get_groq_llm

# Tipos del contrato publico (SPEC v2 seccion 5)
Plataforma = Literal["blog", "twitter", "instagram", "linkedin"]
Audiencia = Literal["general", "tecnica", "infantil", "ejecutiva"]

# Defaults de longitud por plataforma (palabras aproximadas)
DEFAULTS_MAX_PALABRAS: dict[str, int] = {
    "blog": 800,
    "linkedin": 200,
    "instagram": 100,
    "twitter": 40,  # margen sobre los 280 caracteres de X
}

# Directorio de plantillas: src/p10jj/prompts/
PROMPTS_DIR = Path(__file__).resolve().parent / "prompts"


def _cargar_plantilla(plataforma: str) -> str:
    """Lee la plantilla .md correspondiente a la plataforma indicada."""
    ruta = PROMPTS_DIR / f"{plataforma}.md"
    return ruta.read_text(encoding="utf-8")


def generar(
    tema: str,
    plataforma: Plataforma,
    audiencia: Audiencia = "general",
    tono: float = 0.7,
    max_palabras: int | None = None,
) -> str:
    """Genera contenido adaptado a la plataforma y audiencia indicadas.

    Args:
        tema: asunto principal del contenido.
        plataforma: determina la plantilla aplicada y la longitud por defecto.
        audiencia: nivel y registro del texto.
        tono: float en [0.0, 1.0]. Se pasa COMO temperature al modelo.
            NO se usa como marcador del prompt.
        max_palabras: si None, se usa DEFAULTS_MAX_PALABRAS[plataforma].
            Se pasa al prompt como guia. No se valida en post-proceso.

    Returns:
        Texto generado en castellano, listo para publicar.

    Raises:
        ValueError: si tono esta fuera de [0.0, 1.0].
        ProviderError: si Groq falla tras los reintentos configurados.
    """
    if not 0.0 <= tono <= 1.0:
        raise ValueError(f"tono debe estar en [0.0, 1.0], recibido: {tono}")

    if max_palabras is None:
        max_palabras = DEFAULTS_MAX_PALABRAS[plataforma]

    plantilla = _cargar_plantilla(plataforma)
    prompt = plantilla.format(
        tema=tema,
        audiencia=audiencia,
        plataforma=plataforma,
        max_palabras=max_palabras,
    )

    llm = get_groq_llm(temperature=tono)
    response = llm.invoke(prompt)
    return response.content
