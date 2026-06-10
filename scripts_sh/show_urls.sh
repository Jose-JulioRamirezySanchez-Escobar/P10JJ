#!/usr/bin/env bash
# show_urls.sh — Imprime las URLs útiles del repo del proyecto.
# Requiere: gh CLI autenticada y este directorio dentro de un repo conectado a GitHub.
#
# Uso:
#   bash show_urls.sh                       # imprime todo
#   bash show_urls.sh raw <ruta>            # imprime URL raw de un fichero concreto
#   bash show_urls.sh raw README.md         # ejemplo

set -u

OWNER=$(gh repo view --json owner -q .owner.login 2>/dev/null || true)
REPO=$(gh repo view --json name  -q .name 2>/dev/null || true)
DEFBR=$(gh repo view --json defaultBranchRef -q .defaultBranchRef.name 2>/dev/null || true)

if [[ -z "$OWNER" || -z "$REPO" ]]; then
  echo "ERROR: este directorio no parece estar conectado a un repo de GitHub."
  echo "Asegúrate de haber ejecutado 'gh repo create ... --source=.' antes."
  exit 1
fi

BASE="https://github.com/${OWNER}/${REPO}"
RAW="https://raw.githubusercontent.com/${OWNER}/${REPO}"

# Modo "raw" — imprime solo la URL raw de un fichero concreto
if [[ "${1:-}" == "raw" && -n "${2:-}" ]]; then
  echo "${RAW}/${DEFBR}/$2"
  exit 0
fi

# Modo completo
cat <<EOF
============================================================
  P10JJ — URLs útiles del proyecto
  Owner:   $OWNER
  Repo:    $REPO
  Default: $DEFBR
============================================================

Repositorio        $BASE
Issues             $BASE/issues
Issues abiertas    $BASE/issues?q=is%3Aissue+is%3Aopen
Pull requests      $BASE/pulls
Actions (CI)       $BASE/actions
Settings           $BASE/settings
Wiki               $BASE/wiki

Branches           $BASE/branches
Tags / Releases    $BASE/releases

Labels             $BASE/labels
Milestones         $BASE/milestones

Projects (Kanban)  https://github.com/users/$OWNER/projects
  (Crea uno desde ahí con título 'P10JJ — Roadmap'.
   La URL final será:  https://github.com/users/$OWNER/projects/<n>
   También puedes crearlo por CLI:
     gh project create --owner @me --title 'P10JJ — Roadmap' --format json | jq -r .url
   Y luego añadirle todas las issues abiertas:
     gh issue list --state open --json url -q '.[].url' | while read u; do
       gh project item-add <n> --owner @me --url "\$u"
     done
  )

Filtros de issues por nivel:
  Esencial   $BASE/issues?q=is%3Aissue+is%3Aopen+label%3Anivel%3Aesencial
  Medio      $BASE/issues?q=is%3Aissue+is%3Aopen+label%3Anivel%3Amedio
  Avanzado   $BASE/issues?q=is%3Aissue+is%3Aopen+label%3Anivel%3Aavanzado
  Experto    $BASE/issues?q=is%3Aissue+is%3Aopen+label%3Anivel%3Aexperto

URLs raw (rama '$DEFBR'):
  README             $RAW/$DEFBR/README.md
  LICENSE            $RAW/$DEFBR/LICENSE
  pyproject.toml     $RAW/$DEFBR/pyproject.toml
  .gitignore         $RAW/$DEFBR/.gitignore
  Notebook bootstrap $RAW/$DEFBR/notebooks/00_setup_y_bootstrap.ipynb

  Para cualquier otro fichero:
    bash show_urls.sh raw <ruta-relativa>
  Ejemplo:
    bash show_urls.sh raw src/p10jj/ui/app.py

Clonar:
  HTTPS  git clone $BASE.git
  SSH    git clone git@github.com:$OWNER/$REPO.git

EOF
