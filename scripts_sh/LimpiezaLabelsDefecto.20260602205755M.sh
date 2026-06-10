cd /d/Proyectos/P10JJ

for L in bug documentation duplicate enhancement "help wanted" invalid question wontfix "good first issue"; do
  gh label delete "$L" --yes 2>/dev/null
done
gh label list  # debe quedar limpio
