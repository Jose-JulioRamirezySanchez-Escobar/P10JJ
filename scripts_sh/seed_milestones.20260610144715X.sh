#!/usr/bin/env bash
# seed_milestones.sh
# Crea 4 milestones (Esencial / Medio / Avanzado / Experto) en GitHub
# y asigna las issues a su milestone segun su label `nivel:*`.
#
# Requisitos:
#   - gh CLI autenticada (scope `repo`)
#   - jq
#   - ejecutar desde la raiz del repo P10JJ (gh detecta owner/repo solo)
#
# Uso:
#   bash scripts_sh/seed_milestones.sh                    # crear y asignar
#   DRY_RUN=1 bash scripts_sh/seed_milestones.sh          # vista previa, no toca nada

set -u

DRY_RUN="${DRY_RUN:-0}"

# --- Definicion de los 4 milestones ---
# El orden importa: respeta la secuencia natural del proyecto.
MS_TITLES=("Esencial" "Medio" "Avanzado" "Experto")
declare -A MS_DESC=(
  ["Esencial"]="Nivel Esencial — prompts + Streamlit + >=1 LLM. Cierre = tag v0.1.0-esencial."
  ["Medio"]="Nivel Medio — Docker + >=2 LLMs + personalizacion + imagenes. Cierre = tag v0.2.0-medio."
  ["Avanzado"]="Nivel Avanzado — LangSmith + multilenguaje + finanzas + RAG arXiv. Cierre = tag v0.3.0-avanzado."
  ["Experto"]="Nivel Experto — Graph RAG + Multiagente + guardarrailes. Cierre = tag v0.4.0-experto."
)

# Mapeo label nivel:* -> milestone title
declare -A LABEL_TO_MS=(
  ["nivel:esencial"]="Esencial"
  ["nivel:medio"]="Medio"
  ["nivel:avanzado"]="Avanzado"
  ["nivel:experto"]="Experto"
)

# ============================================================
# 1) Crear los milestones (idempotente)
# ============================================================
echo "==> Fase 1: crear milestones"

create_milestone() {
  local title="$1" desc="$2"
  local existing
  existing=$(gh api "repos/{owner}/{repo}/milestones?state=all&per_page=100" \
              --jq ".[] | select(.title==\"$title\") | .number" 2>/dev/null || true)

  if [[ -n "$existing" ]]; then
    echo "  SKIP (#$existing ya existe): $title"
    return 0
  fi

  if [[ "$DRY_RUN" == "1" ]]; then
    echo "  DRY-RUN crearia milestone: $title"
    return 0
  fi

  local num
  num=$(gh api repos/{owner}/{repo}/milestones \
          --method POST \
          --field title="$title" \
          --field description="$desc" \
          --field state="open" \
          --jq '.number' 2>/dev/null) || { echo "  FALLO crear: $title"; return 1; }
  echo "  CREADO (#$num): $title"
}

for t in "${MS_TITLES[@]}"; do
  create_milestone "$t" "${MS_DESC[$t]}"
done

# ============================================================
# 2) Asignar cada issue a su milestone segun su label nivel:*
# ============================================================
echo
echo "==> Fase 2: asignar issues a milestones"

assign_label_to_milestone() {
  local label="$1" ms="$2"
  echo
  echo "  Label '$label' -> Milestone '$ms'"

  # Obtener issues (abiertas y cerradas) con esta label
  local issues
  issues=$(gh issue list --label "$label" --state all --limit 100 \
            --json number,title -q '.[] | "\(.number)|\(.title)"' 2>/dev/null || true)

  if [[ -z "$issues" ]]; then
    echo "    (no hay issues con esta label)"
    return 0
  fi

  while IFS='|' read -r num title; do
    [[ -z "$num" ]] && continue
    if [[ "$DRY_RUN" == "1" ]]; then
      echo "    DRY-RUN asignaria #$num -> $ms : $title"
      continue
    fi
    if gh issue edit "$num" --milestone "$ms" >/dev/null 2>&1; then
      echo "    #$num -> $ms : $title"
    else
      echo "    FALLO al asignar #$num"
    fi
  done <<< "$issues"
}

for label in "${!LABEL_TO_MS[@]}"; do
  assign_label_to_milestone "$label" "${LABEL_TO_MS[$label]}"
done

# ============================================================
# 3) Resumen
# ============================================================
echo
echo "==> Resumen final de milestones:"
gh api "repos/{owner}/{repo}/milestones?state=all&per_page=100" \
  --jq '.[] | "  #\(.number) [\(.state)] \(.title): abiertas=\(.open_issues), cerradas=\(.closed_issues), url=\(.html_url)"'

echo
echo "==> URLs utiles:"
OWNER=$(gh repo view --json owner -q .owner.login)
REPO=$(gh repo view --json name -q .name)
echo "  Milestones:   https://github.com/$OWNER/$REPO/milestones"
echo "  Issues por hito (ejemplo): https://github.com/$OWNER/$REPO/issues?q=is%3Aissue+milestone%3A%22Esencial%22"
