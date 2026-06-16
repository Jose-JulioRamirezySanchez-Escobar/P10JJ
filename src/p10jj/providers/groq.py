"""Provider de Groq con reintentos automaticos via tenacity.

Encapsula la creacion del cliente ChatGroq y anade una capa de
resiliencia: si la llamada al modelo falla por un error transitorio
(rate limit, error 5xx), reintenta hasta `max_attempts` veces con
backoff exponencial. Si todos los intentos fallan, lanza ProviderError.
"""

from langchain_groq import ChatGroq
from tenacity import retry, stop_after_attempt, wait_exponential

# Modelo Groq centralizado: si Groq deprecia, se cambia AQUI y solo aqui.
MODEL = "llama-3.1-8b-instant"


class ProviderError(RuntimeError):
    """Lanzada cuando el proveedor LLM falla tras los reintentos configurados.

    Attributes:
        mensaje: descripcion legible del fallo.
        ultimo_error: la ultima excepcion capturada por el wrapper.
    """

    def __init__(self, mensaje: str, ultimo_error: Exception | None = None):
        super().__init__(mensaje)
        self.mensaje = mensaje
        self.ultimo_error = ultimo_error


class GroqLLM:
    """Wrapper de ChatGroq con reintentos automaticos (tenacity).

    API compatible con ChatGroq: expone .invoke(prompt) que devuelve un
    objeto con atributo .content.
    """

    def __init__(
        self,
        model: str = MODEL,
        temperature: float = 0.7,
        max_attempts: int = 3,
    ) -> None:
        self._chat = ChatGroq(model=model, temperature=temperature)
        self.max_attempts = max_attempts

    def invoke(self, prompt: str):
        """Invoca el modelo. Reintenta hasta max_attempts veces con backoff.

        Si todos los intentos fallan, lanza ProviderError.
        """

        @retry(
            stop=stop_after_attempt(self.max_attempts),
            wait=wait_exponential(multiplier=1, min=1, max=10),
            reraise=True,
        )
        def _attempt(_prompt: str):
            return self._chat.invoke(_prompt)

        try:
            return _attempt(prompt)
        except Exception as e:
            raise ProviderError(
                mensaje=f"Groq fallo tras {self.max_attempts} intentos",
                ultimo_error=e,
            ) from e


def get_groq_llm(
    temperature: float = 0.7,
    max_attempts: int = 3,
) -> GroqLLM:
    """Factoria: crea una instancia de GroqLLM lista para usar.

    Es el punto de entrada recomendado para que el resto del codigo
    obtenga un cliente Groq con reintentos automaticos.
    """
    return GroqLLM(
        model=MODEL,
        temperature=temperature,
        max_attempts=max_attempts,
    )
