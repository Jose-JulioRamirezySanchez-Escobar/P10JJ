#!/usr/bin/env bash
# setup_project.sh
# Termina de montar el scaffold sobre el repo. Ejecutar UNA vez desde la raíz del repo
# (D:\Proyectos\P10JJ en Windows, vía Git Bash).
#
# Lo que hace:
#   1. Crea las subcarpetas de src/p10jj/ con __init__.py vacíos.
#   2. Crea .gitkeep en data/* y logs/ para que Git las versione vacías.
#   3. Verifica que uv esté instalado (si no, indica cómo instalarlo).
#   4. Lanza `uv sync` con los grupos base de desarrollo.
#
# NO toca docs/briefing/ (ya está renombrado) y NO crea git (eso lo haces aparte).

set -euo pipefail

echo "==> Verificando que estamos en la raíz del repo..."
if [[ ! -f pyproject.toml || ! -d src/p10jj ]]; then
  echo "ERROR: ejecuta este script desde la raíz del repo P10JJ, donde está pyproject.toml."
  exit 1
fi

echo "==> Creando subpaquetes de src/p10jj/ ..."
SUBPKGS=(providers prompts rag agents guardrails ui)
for s in "${SUBPKGS[@]}"; do
  mkdir -p "src/p10jj/$s"
  touch "src/p10jj/$s/__init__.py"
done

# Esqueleto de la app Streamlit para que `make run-app` no falle nada más empezar.
if [[ ! -f src/p10jj/ui/app.py ]]; then
  cat > src/p10jj/ui/app.py <<'PY'
"""Punto de entrada Streamlit. Esqueleto, se rellenará en el Nivel Esencial."""
import streamlit as st

st.set_page_config(page_title="P10JJ", page_icon="🧠")
st.title("P10JJ — Generador de contenido")
st.caption("Esqueleto inicial. La funcionalidad llegará en el Nivel Esencial.")
PY
fi

echo "==> Creando .gitkeep en carpetas vacías que queremos versionar..."
for d in data/raw data/interim data/processed data/sample logs \
         docs/design docs/decisions docs/medium \
         tests notebooks; do
  mkdir -p "$d"
  [[ -f "$d/.gitkeep" ]] || touch "$d/.gitkeep"
done

# Quitar .gitkeep de notebooks/ y tests/ si ya hay contenido (no estorba pero no hace falta).

echo "==> Comprobando uv..."
if ! command -v uv >/dev/null 2>&1; then
  cat <<'MSG'

uv NO está instalado. Instálalo con UNA de estas opciones y vuelve a ejecutar este script:

  Opción A (winget):
    winget install --id=astral-sh.uv -e

  Opción B (PowerShell):
    irm https://astral.sh/uv/install.ps1 | iex

  Verificar:  uv --version

MSG
  exit 2
fi

echo "==> uv $(uv --version) detectado."

echo "==> Sincronizando dependencias (base + dev + notebooks)..."
uv sync --group dev --group notebooks

echo
echo "==> Listo."
echo "    Siguientes pasos:"
echo "      1) cp .env.example .env   (y rellenar las claves)"
echo "      2) uv run jupyter lab     (o bien: make run-lab)"
echo "      3) Abrir notebooks/00_setup_y_bootstrap.ipynb"
