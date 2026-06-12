"""Core del generador de contenido P10JJ.

Versión MÍNIMA del Paso 3 del apéndice SPEC v2 — pasa el test unitario
test_invoca_provider_y_devuelve_string sin más.

Pendiente para pasos posteriores:
- Paso 4: validación de tono fuera de rango (ValueError).
- Paso 5: cargar prompt desde plantillas .md externas en src/p10jj/prompts/.
- Paso 6: reintentos con tenacity + ProviderError tras 3 fallos.
"""

from typing import Literal

from langchain_groq import ChatGroq

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

# Modelo Groq centralizado: cambio unico si se deprecia el modelo
MODEL = "llama-3.1-8b-instant"


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
    """
    if max_palabras is None:
        max_palabras = DEFAULTS_MAX_PALABRAS[plataforma]

    llm = ChatGroq(model=MODEL, temperature=tono)

    prompt = (
        f"Eres un redactor especializado en {plataforma}. "
        f"Tema: {tema}. Audiencia: {audiencia}. "
        f"Longitud aproximada: {max_palabras} palabras. "
        f"Genera el contenido en castellano."
    )

    response = llm.invoke(prompt)
    return response.content
