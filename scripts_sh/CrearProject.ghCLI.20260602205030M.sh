cd /d/Proyectos/P10JJ

# 1) Crear el Project y capturar su número
PROJECT_URL=$(gh project create --owner @me --title "P10JJ — Roadmap" --format json | jq -r .url)
echo "Project creado: $PROJECT_URL"

# Extraer el número del Project de la URL (último segmento)
PROJECT_NUM=$(basename "$PROJECT_URL")
echo "Número: $PROJECT_NUM"

# 2) Añadir todas las issues abiertas al Project
gh issue list --state open --limit 100 --json url -q '.[].url' | while read -r u; do
  gh project item-add "$PROJECT_NUM" --owner @me --url "$u"
done

# 3) Comprobar
gh project item-list "$PROJECT_NUM" --owner @me --limit 100
