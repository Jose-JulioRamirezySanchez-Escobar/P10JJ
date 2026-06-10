# P10JJ — Generador de contenido con LLMs

[![Python](https://img.shields.io/badge/python-3.13-blue.svg)](https://www.python.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Code style: ruff](https://img.shields.io/badge/code%20style-ruff-000000.svg)](https://github.com/astral-sh/ruff)

Prueba de concepto de un sistema que genera contenido (texto e imágenes) para
diversos medios y audiencias, usando LLMs vía API y RAG sobre fuentes científicas.

> Proyecto académico del Bootcamp F5 IA — P4 Proyecto XI: LLMs.

## Estado por niveles

- [ ] Nivel Esencial — prompts + Streamlit + ≥1 LLM
- [ ] Nivel Medio — Docker + ≥2 LLMs + personalización + imágenes
- [ ] Nivel Avanzado — Trazabilidad (LangSmith) + multilenguaje + finanzas + RAG arXiv
- [ ] Nivel Experto — Graph RAG + Multiagente + guardarraíles

## Arquitectura (esbozo)

Detalles en [`docs/design/`](docs/design/). Resumen:

- **LLMs**: Groq (principal) + Google AI Studio / Gemini (secundario) + Ollama (local opcional)
- **Frontend**: Streamlit
- **BD vectorial**: Chroma (local)
- **Embeddings**: sentence-transformers (Hugging Face)
- **Orquestación**: LangChain (base); LangGraph / CrewAI (Experto)
- **Trazabilidad**: LangSmith
- **Empaquetado**: Docker (a partir de Nivel Medio)

## Setup local (con uv)

Requisitos previos: Python 3.13, [uv](https://docs.astral.sh/uv/), Git, Docker Desktop.

```bash
# 1) Clonar y entrar al repo
git clone https://github.com/Jose-JulioRamirezySanchez-Escobar/P10JJ.git
cd P10JJ
```

A partir de aquí, dos opciones equivalentes para preparar el entorno:

### Opción A — uv sync directo (camino corto)

```bash
uv sync --group dev --group notebooks
```

### Opción B — Script de arranque con log (recomendada la primera vez)

Hace lo mismo que la Opción A, pero además: valida que `uv` esté instalado, prepara
`__init__.py` y `.gitkeep` que pudieran faltar, y deja constancia en `logs/`.

```bash
# Ejecutar SIEMPRE desde la raíz del repo:
bash scripts_sh/setup_project.sh |& tee "logs/setup_project.sh.$(date +%Y%m%d%H%M%S).log"
```

> Si tienes una función `sella` propia en tu shell para timestamping
> (`YYYYMMDDhhmmss<L|M|X|J|V|S|D>`), puedes usarla en lugar de `date`:
> `... |& tee "logs/setup_project.sh.$(sella).log"`

### Configurar variables de entorno

```bash
cp .env.example .env
# Editar .env con tus claves: GROQ_API_KEY, GOOGLE_API_KEY, ...
```

### Verificar

```bash
uv run python -c "from p10jj import __version__; print(__version__)"
```

### Grupos opcionales por nivel

```bash
uv sync --group rag        # Nivel Avanzado: arXiv + PDFs
uv sync --group agents     # Nivel Experto: LangGraph + CrewAI + LangSmith
uv sync --group finance    # Funcionalidad de mercados financieros
```

## Uso

```bash
# Lanzar JupyterLab
uv run jupyter lab

# Lanzar la app Streamlit
uv run streamlit run src/p10jj/ui/app.py

# Ejecutar tests
uv run pytest
```

## Estructura del repositorio

```
P10JJ/
├── notebooks/          # cuadernos por nivel (00..06)
├── src/p10jj/          # módulos reutilizables (providers, rag, agents...)
├── tests/              # tests con pytest
├── data/               # raw / interim / processed / sample
├── docker/             # Dockerfile + docker-compose
├── docs/               # briefing (gitignored), design (SSD), decisions (ADRs), medium
├── logs/               # logs de ejecución (gitignored)
├── scripts_sh/         # scripts auxiliares (setup, seed_issues, show_urls...)
├── .github/            # plantillas de Issue/PR + CI
├── pyproject.toml      # dependencias y configuración (uv)
├── uv.lock             # lockfile reproducible
├── Makefile            # atajos comunes
└── README.md
```

## Convenciones

- **Ramas**: `main` (entregables) · `develop` (integración) · `feature/<slug>` · `fix/<slug>` · `docs/<slug>` · `exp/<slug>`
- **Commits**: [Conventional Commits](https://www.conventionalcommits.org/) — `feat:`, `fix:`, `docs:`, `chore:`, `refactor:`, `test:`, `ci:`
- **Tags por nivel**: `v0.1.0-esencial`, `v0.2.0-medio`, `v0.3.0-avanzado`, `v0.4.0-experto`
- **Scripts**: viven en `scripts_sh/` y se ejecutan SIEMPRE desde la raíz del repo

## Licencia

[MIT](LICENSE)
