# Dockerfile mínimo. Se construye desde la raíz del repo:
#   docker build -f docker/Dockerfile -t p10jj:dev .
# Ejecutar:
#   docker run --rm -p 8501:8501 --env-file .env p10jj:dev

FROM python:3.13-slim

# uv: gestor rápido de dependencias
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

ENV UV_LINK_MODE=copy \
    UV_COMPILE_BYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1

WORKDIR /app

# 1) Solo el manifiesto, para cachear capa de dependencias
COPY pyproject.toml uv.lock* ./
RUN uv sync --frozen --no-install-project --group notebooks || uv sync --no-install-project --group notebooks

# 2) Código
COPY src ./src
COPY notebooks ./notebooks
RUN uv sync --frozen --group notebooks || uv sync --group notebooks

EXPOSE 8501

CMD ["uv", "run", "streamlit", "run", "src/p10jj/ui/app.py", \
     "--server.address=0.0.0.0", "--server.port=8501"]
