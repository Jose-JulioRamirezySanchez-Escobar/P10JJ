#!/usr/bin/env bash
# show_urls.20260610213728X.sh
# Genera docs/URLS.md (centro de navegacion del proyecto) e imprime resumen.
# Antes de sobreescribir, archiva la version anterior en docs/old_versions/
# con sufijo de fecha (sella si esta disponible, date si no).
#
# Modos de uso:
#   bash scripts_sh/show_urls.20260610213728X.sh                # regenera docs/URLS.md + resumen
#   bash scripts_sh/show_urls.20260610213728X.sh --dry-run      # NO escribe, vuelca contenido a stdout
#   bash scripts_sh/show_urls.20260610213728X.sh --stdout-only  # alias de --dry-run
#
# Variables de entorno:
#   KEEP_HISTORY=0  desactiva el archivado en docs/old_versions/ (por defecto: 1)
#
# Requisitos:
#   - gh CLI autenticada (`gh auth status`)
#   - ejecutar desde la raiz del repo P10JJ

set -u

MODE="write"
case "${1:-}" in
  --stdout-only|--dry-run) MODE="stdout" ;;
  "") : ;;
  *) echo "Uso: $0 [--dry-run | --stdout-only]"; exit 1 ;;
esac

KEEP_HISTORY="${KEEP_HISTORY:-1}"

# --- precondiciones --------------------------------------------------------
if ! command -v gh >/dev/null 2>&1; then
  echo "ERROR: gh CLI no esta instalada"; exit 1
fi
if ! gh auth status >/dev/null 2>&1; then
  echo "ERROR: gh CLI no esta autenticada. Ejecuta: gh auth login"; exit 1
fi
if [[ ! -f pyproject.toml ]]; then
  echo "ERROR: ejecuta este script desde la raiz del repo (donde esta pyproject.toml)"; exit 1
fi

# --- helper de timestamp: usa sella si esta disponible, si no date ---------
_ts() {
  if type -t sella >/dev/null 2>&1; then
    sella
  else
    date +%Y%m%d%H%M%S
  fi
}

# --- detectar owner/repo ---------------------------------------------------
OWNER=$(gh repo view --json owner -q .owner.login)
REPO=$(gh repo view --json name -q .name)
BASE="https://github.com/${OWNER}/${REPO}"
RAW="https://raw.githubusercontent.com/${OWNER}/${REPO}/develop"

# ===========================================================================
# Funcion: imprime el contenido completo del URLS.md a stdout
# ===========================================================================
generate_urls_md() {
  local now
  now=$(date +%Y-%m-%d)

  cat <<MD
# P10JJ — Mapa de URLs

> Centro de navegacion del proyecto.
> Generado automaticamente por \`scripts_sh/show_urls.20260610213728X.sh\`.
> Ultima revision: ${now}

---

## Repositorio

- Repo: ${BASE}
- Rama main: ${BASE}/tree/main
- Rama develop: ${BASE}/tree/develop
- Configuracion: ${BASE}/settings

---

## Pull Requests

- Todos: ${BASE}/pulls
- Abiertos: ${BASE}/pulls?q=is%3Apr+is%3Aopen
- Mergeados: ${BASE}/pulls?q=is%3Apr+is%3Amerged

### Historico de PRs mergeados
MD

  if ! gh pr list --state merged --limit 100 \
        --json number,title,url \
        --jq 'sort_by(.number) | .[] | "- **#\(.number)** \(.title) — \(.url)"' 2>/dev/null; then
    echo "_(no hay PRs mergeados aun)_"
  fi

  cat <<MD

---

## Issues

- Todas: ${BASE}/issues
- Abiertas: ${BASE}/issues?q=is%3Aissue+is%3Aopen
- Cerradas: ${BASE}/issues?q=is%3Aissue+is%3Aclosed

### Por nivel

- Esencial: ${BASE}/issues?q=is%3Aissue+label%3A%22nivel%3Aesencial%22
- Medio: ${BASE}/issues?q=is%3Aissue+label%3A%22nivel%3Amedio%22
- Avanzado: ${BASE}/issues?q=is%3Aissue+label%3A%22nivel%3Aavanzado%22
- Experto: ${BASE}/issues?q=is%3Aissue+label%3A%22nivel%3Aexperto%22

### Por area

- area:rag — ${BASE}/issues?q=is%3Aissue+label%3A%22area%3Arag%22
- area:agents — ${BASE}/issues?q=is%3Aissue+label%3A%22area%3Aagents%22
- area:ui — ${BASE}/issues?q=is%3Aissue+label%3A%22area%3Aui%22
- area:providers — ${BASE}/issues?q=is%3Aissue+label%3A%22area%3Aproviders%22
- area:guardrails — ${BASE}/issues?q=is%3Aissue+label%3A%22area%3Aguardrails%22
- area:infra — ${BASE}/issues?q=is%3Aissue+label%3A%22area%3Ainfra%22

### Por prioridad

- prioridad:alta — ${BASE}/issues?q=is%3Aissue+label%3A%22prioridad%3Aalta%22
- prioridad:media — ${BASE}/issues?q=is%3Aissue+label%3A%22prioridad%3Amedia%22
- prioridad:baja — ${BASE}/issues?q=is%3Aissue+label%3A%22prioridad%3Abaja%22

---

## Milestones

- Lista completa: ${BASE}/milestones
MD

  if ! gh api "repos/{owner}/{repo}/milestones?state=all&per_page=100" \
        --jq '.[] | "- **#\(.number) \(.title)** — \(.html_url) — abiertas=\(.open_issues), cerradas=\(.closed_issues)"' \
        2>/dev/null; then
    echo "_(no hay milestones)_"
  fi

  cat <<MD

---

## Project Kanban

- Project #11 — P10JJ — Roadmap: https://github.com/users/${OWNER}/projects/11
- Vista 1: https://github.com/users/${OWNER}/projects/11/views/1
- Vista 2: https://github.com/users/${OWNER}/projects/11/views/2

---

## Etiquetas (labels)

- Listado completo: ${BASE}/labels

---

## Archivos clave (RAW desde \`develop\`)

> Las URLs RAW devuelven el fichero plano (sin envoltura GitHub). Utiles para curl/wget/scripts.

### Documentacion

- README: ${RAW}/README.md
- LICENSE: ${RAW}/LICENSE

### Diseno (\`docs/design/\`)

- Plantilla SPEC: ${RAW}/docs/design/_TEMPLATE.md
- Plantilla SPEC con comentarios: ${RAW}/docs/design/_TEMPLATE.concepts.md
- SPEC ejemplo (issue #1): ${RAW}/docs/design/SPEC_feat-core-generador-base.md
- Flujos de alto nivel del sistema: ${RAW}/docs/design/01-flujos-alto-nivel.md

### Configuracion

- pyproject.toml: ${RAW}/pyproject.toml
- .pre-commit-config.yaml: ${RAW}/.pre-commit-config.yaml
- .gitignore: ${RAW}/.gitignore
- .env.example: ${RAW}/.env.example

### Scripts (\`scripts_sh/\`)

MD

  if [[ -d scripts_sh ]]; then
    for f in $(ls -1 scripts_sh/*.sh 2>/dev/null | sort); do
      bn=$(basename "$f")
      echo "- ${bn}: ${RAW}/${f}"
    done
  fi

  cat <<MD

### Notebooks (\`notebooks/\`)

MD

  if [[ -d notebooks ]]; then
    for f in $(ls -1 notebooks/*.ipynb 2>/dev/null | sort); do
      bn=$(basename "$f")
      echo "- ${bn}: ${RAW}/${f}"
    done
  fi

  cat <<MD

---

## Recursos externos

- Roadmap del bootcamp: https://roadmap-mad-ai-p4.coderf5.es/
- Conventional Commits: https://www.conventionalcommits.org/
- Documentacion uv: https://docs.astral.sh/uv/
- LangChain docs: https://python.langchain.com/docs/
- Groq console: https://console.groq.com/
- Google AI Studio: https://aistudio.google.com/
- arXiv API: https://info.arxiv.org/help/api/

---

> Este archivo se regenera con \`bash scripts_sh/show_urls.20260610213728X.sh\`.
> Las versiones anteriores se archivan en \`docs/old_versions/\` (gitignored).
MD
}

# ===========================================================================
# Funcion: imprime resumen corto a stdout
# ===========================================================================
print_summary() {
  echo
  echo "==> Resumen del proyecto"
  echo "  Repo:        ${BASE}"
  echo "  Milestones:  ${BASE}/milestones"
  echo "  Issues:      ${BASE}/issues"
  echo "  PRs:         ${BASE}/pulls"
  echo "  Kanban:      https://github.com/users/${OWNER}/projects/11"
  echo
  echo "==> Milestones actuales:"
  gh api "repos/{owner}/{repo}/milestones?state=all&per_page=100" \
    --jq '.[] | "  #\(.number) [\(.state)] \(.title): \(.open_issues) open / \(.closed_issues) closed"' \
    2>/dev/null || echo "  (no hay milestones)"
  echo
}

# ===========================================================================
# Main
# ===========================================================================
if [[ "$MODE" == "stdout" ]]; then
  generate_urls_md
  echo
  echo "_(modo dry-run: no se ha escrito docs/URLS.md)_"
  exit 0
fi

# Archivar version anterior (solo si existe y KEEP_HISTORY=1)
if [[ "$KEEP_HISTORY" == "1" && -f docs/URLS.md ]]; then
  mkdir -p docs/old_versions
  archive_path="docs/old_versions/URLS.$(_ts).md"
  mv docs/URLS.md "$archive_path"
  echo "==> Archivado anterior en: $archive_path"
fi

mkdir -p docs
generate_urls_md > docs/URLS.md
echo "==> Generado docs/URLS.md ($(wc -l < docs/URLS.md) lineas)"

print_summary
