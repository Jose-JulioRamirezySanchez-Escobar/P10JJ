# ============================================================
# PASO 1: Volver a la raíz del repo y diagnosticar
# ============================================================
cd /d/Proyectos/P10JJ
pwd                         # debe decir /d/Proyectos/P10JJ
git branch                  # debe haber: main (sin commit) y develop (con commit)
git log --oneline --all     # debe verse: 93eff46 ... solo en develop

# ============================================================
# PASO 2: Hacer que main apunte al mismo commit que develop
# ============================================================
# Esto sincroniza main con develop. Ambas pasan a apuntar al commit 93eff46.
git branch -f main develop
git log --oneline --all     # ahora main y develop deben apuntar al mismo commit
git branch                  # sigues en develop, que está bien

# ============================================================
# PASO 3: Crear repo remoto DESDE LA RAÍZ, y push de ambas ramas
# ============================================================
gh auth status              # verifica autenticación (ya estaba OK)

# Importante: --source=. usa el DIRECTORIO ACTUAL = /d/Proyectos/P10JJ
gh repo create P10JJ --public --source=. --remote=origin --push
# Esto pushea la rama actual (develop). Comprobamos:
git remote -v               # debe verse: origin  https://github.com/<user>/P10JJ.git

# Subir también main:
git push -u origin main

# Vincular develop al remoto explícitamente:
git push -u origin develop

# Develop como rama por defecto del repo remoto (opcional):
gh repo edit --default-branch develop

# ============================================================
# PASO 4: Labels + seed de issues + URLs (todo desde la raíz)
# ============================================================

# Labels (idénticas a tu script anterior, sin cambios)
for L in \
  "nivel:esencial|BFD4F2|Nivel Esencial" \
  "nivel:medio|C2E0C6|Nivel Medio" \
  "nivel:avanzado|FBCA04|Nivel Avanzado" \
  "nivel:experto|D93F0B|Nivel Experto" \
  "tipo:bug|D73A4A|" \
  "tipo:feature|0E8A16|" \
  "tipo:docs|0075CA|" \
  "tipo:chore|CFD3D7|" \
  "prioridad:alta|B60205|" \
  "prioridad:media|FBCA04|" \
  "prioridad:baja|0E8A16|" \
  "estado:bloqueado|000000|" \
  "estado:en-revision|5319E7|" \
  "area:rag|1D76DB|" \
  "area:agents|1D76DB|" \
  "area:ui|1D76DB|" \
  "area:providers|1D76DB|" \
  "area:guardrails|1D76DB|" \
  "area:infra|1D76DB|"; do
  IFS='|' read -r N C D <<< "$L"
  gh label create "$N" --color "$C" --description "$D" 2>/dev/null || true
done

gh label list   # verificar que se han creado

# Seed de issues — desde la raíz, ahora sí
DRY_RUN=1 bash scripts_sh/seed_issues.sh   # vista previa
bash scripts_sh/seed_issues.sh             # crear de verdad

# URLs del proyecto
bash scripts_sh/show_urls.sh
