#!/usr/bin/env bash
# seed_issues.sh
# Crea las issues iniciales del proyecto P10JJ, mapeadas a Esencial / Medio / Avanzado / Experto.
# Requiere: gh CLI autenticada y el repo ya creado/vinculado como remoto.
# Es idempotente con cabeza: si ya existe una issue con el mismo título, la salta.
#
# Uso:
#   bash seed_issues.sh                       # crea
#   DRY_RUN=1 bash seed_issues.sh             # solo imprime, no crea
#
# Las labels deben existir previamente. Si no existen, gh las crea con color por defecto.

set -u

DRY_RUN="${DRY_RUN:-0}"

create_issue() {
  local title="$1" labels="$2" body="$3"

  # Saltar si ya existe una issue con ese título exacto (abierta o cerrada)
  if gh issue list --search "in:title \"$title\"" --state all --json title -q '.[].title' | grep -Fxq "$title"; then
    echo "SKIP (ya existe): $title"
    return 0
  fi

  if [[ "$DRY_RUN" == "1" ]]; then
    echo "DRY-RUN: gh issue create -t '$title' -l '$labels'"
    return 0
  fi

  gh issue create --title "$title" --label "$labels" --body "$body" \
    && echo "CREADA: $title" \
    || echo "FALLO:  $title"
}

# =================================================================
# NIVEL ESENCIAL
# =================================================================

create_issue \
  "feat(core): generador de contenido base con LangChain + Groq" \
  "nivel:esencial,tipo:feature,area:providers,prioridad:alta" \
  "## Contexto
Primer entregable del Nivel Esencial: generar contenido de texto a partir de tema + plataforma + audiencia, usando un único LLM (Groq) vía LangChain.

## Criterios de aceptación
- [ ] Función \`generar(tema, plataforma, audiencia) -> str\` en \`src/p10jj/\`
- [ ] Usa Groq (modelo llama-3.x) y temperatura configurable
- [ ] Maneja errores de API con reintentos (tenacity)
- [ ] Tests mínimos en \`tests/\`"

create_issue \
  "feat(prompts): plantillas por plataforma (Blog, X, Instagram, LinkedIn)" \
  "nivel:esencial,tipo:feature,area:providers,prioridad:alta" \
  "## Contexto
Cada plataforma tiene tono, longitud y estructura distinta. Definir plantillas reutilizables.

## Criterios de aceptación
- [ ] 4 plantillas iniciales en \`src/p10jj/prompts/\`
- [ ] Selección por parámetro (\`plataforma=\"x\" | \"blog\" | ...\`)
- [ ] Plantilla acepta variables: tema, audiencia, tono, longitud máxima
- [ ] Documentar cada plantilla con breve docstring"

create_issue \
  "feat(ui): interfaz Streamlit multipágina con selector plataforma/audiencia" \
  "nivel:esencial,tipo:feature,area:ui,prioridad:alta" \
  "## Contexto
Interfaz mínima que permita al usuario introducir tema, elegir plataforma y audiencia, y ver el contenido generado.

## Criterios de aceptación
- [ ] Streamlit funcional con \`uv run streamlit run src/p10jj/ui/app.py\`
- [ ] Inputs: tema (text), plataforma (select), audiencia (select), tono (slider/select)
- [ ] Botón 'Generar' que llama al backend
- [ ] Salida copiable, contador de palabras"

create_issue \
  "docs(notebooks): notebook 01_esencial_prompts con experimentos y comparativa" \
  "nivel:esencial,tipo:docs,prioridad:media" \
  "## Contexto
Notebook que documenta los experimentos del Esencial: combinaciones de plantilla + parámetros, comparativa de salidas.

## Criterios de aceptación
- [ ] \`notebooks/01_esencial_prompts.ipynb\` ejecutable de cabo a rabo
- [ ] Celdas Markdown explicativas entre experimentos
- [ ] Tabla final comparativa (DataFrame)"

create_issue \
  "docs(medium): redactar y publicar artículo en Medium del Nivel Esencial" \
  "nivel:esencial,tipo:docs,prioridad:media" \
  "## Contexto
Requisito de la rúbrica: artículo en Medium explicando la prueba de concepto.

## Criterios de aceptación
- [ ] Borrador en \`docs/medium/\` (no commitear el final si la licencia de Medium lo restringe)
- [ ] Publicado en Medium con URL pública
- [ ] Enlace al artículo añadido al README"

# =================================================================
# NIVEL MEDIO
# =================================================================

create_issue \
  "feat(infra): dockerizar la aplicación (Dockerfile + docker-compose)" \
  "nivel:medio,tipo:feature,area:infra,prioridad:alta" \
  "## Contexto
Requisito Nivel Medio. Ya hay placeholders en \`docker/\`; falta verificar que arrancan y publican el puerto.

## Criterios de aceptación
- [ ] \`docker build -f docker/Dockerfile -t p10jj:dev .\` exitoso
- [ ] \`docker compose -f docker/docker-compose.yml --env-file .env up\` arranca Streamlit en 8501
- [ ] Volumen para Chroma persistente
- [ ] README actualizado con instrucciones Docker"

create_issue \
  "feat(providers): soporte para ≥2 LLM providers (Groq + Gemini) con selector" \
  "nivel:medio,tipo:feature,area:providers,prioridad:alta" \
  "## Contexto
Requisito Nivel Medio. Abstracción de proveedor para poder cambiar Groq ↔ Gemini en runtime.

## Criterios de aceptación
- [ ] Interfaz común tipo \`Provider.complete(prompt) -> str\`
- [ ] Implementaciones para Groq y Gemini
- [ ] Selector en la UI (Streamlit)
- [ ] Tests de smoke para cada provider"

create_issue \
  "feat(core): personalización por empresa/persona en prompts" \
  "nivel:medio,tipo:feature,prioridad:media" \
  "## Contexto
Inyectar contexto de empresa/persona (nombre, sector, valores, tono propio) en todos los prompts.

## Criterios de aceptación
- [ ] Configuración en \`.env\` o \`config/profile.yaml\`
- [ ] Pre-prompt automático con el perfil
- [ ] UI para editar el perfil sin tocar ficheros"

create_issue \
  "feat(media): integración de imágenes en el contenido" \
  "nivel:medio,tipo:feature,area:ui,prioridad:media" \
  "## Contexto
Imágenes relevantes integradas en el texto. Pueden ser generadas con IA o desde una API gratuita (Unsplash, Pexels...).

## Criterios de aceptación
- [ ] Función \`obtener_imagen(consulta) -> URL | path\`
- [ ] Mostrar la imagen en la UI junto al texto
- [ ] Documentar la fuente (atribución cuando aplique)"

# =================================================================
# NIVEL AVANZADO
# =================================================================

create_issue \
  "feat(obs): activar trazabilidad con LangSmith" \
  "nivel:avanzado,tipo:feature,area:infra,prioridad:alta" \
  "## Contexto
Requisito Nivel Avanzado: trazabilidad de peticiones y respuestas.

## Criterios de aceptación
- [ ] LANGSMITH_API_KEY configurada en \`.env\`
- [ ] LANGCHAIN_TRACING_V2 activado solo si hay clave
- [ ] Proyecto 'P10JJ' visible en smith.langchain.com con trazas reales
- [ ] Capturas en docs/medium/ para el artículo"

create_issue \
  "feat(i18n): contenido en castellano, inglés, francés e italiano" \
  "nivel:avanzado,tipo:feature,prioridad:media" \
  "## Contexto
Multilenguaje requisito del Nivel Avanzado.

## Criterios de aceptación
- [ ] Parámetro \`idioma\` en la función generar(...)
- [ ] Plantillas que respetan el idioma de salida
- [ ] Selector de idioma en la UI
- [ ] Tests con prompt fijo y los 4 idiomas"

create_issue \
  "feat(finance): noticias financieras con APIs en tiempo real" \
  "nivel:avanzado,tipo:feature,prioridad:media" \
  "## Contexto
Funcionalidad de generación de contenido sobre mercados financieros, alimentado con datos actualizados.

## Criterios de aceptación
- [ ] Conector a API gratuita (yfinance, Alpha Vantage free, etc.)
- [ ] Cache local con TTL para no agotar cuota
- [ ] Generación de resumen diario / semanal por activo
- [ ] Plantillas específicas para contenido financiero"

create_issue \
  "feat(rag): RAG sobre arXiv para contenido científico divulgativo" \
  "nivel:avanzado,tipo:feature,area:rag,prioridad:alta" \
  "## Contexto
Pieza central del Nivel Avanzado. Tema científico concreto a definir (sugerencia: IA / física cuántica / astrofísica).

## Criterios de aceptación
- [ ] Selección de tema y descarga de papers de arXiv (filtro por categoría + fecha)
- [ ] Chunking + embeddings con sentence-transformers
- [ ] Índice en Chroma persistente
- [ ] Retriever + generación divulgativa con citas a los papers fuente
- [ ] Notebook \`03_avanzado_rag_arxiv.ipynb\` reproducible"

# =================================================================
# NIVEL EXPERTO
# =================================================================

create_issue \
  "feat(rag): Graph RAG con grafo de conocimiento" \
  "nivel:experto,tipo:feature,area:rag,prioridad:media" \
  "## Contexto
Extender el RAG científico con un grafo de conocimiento como fuente de contexto.

## Criterios de aceptación
- [ ] Extracción de entidades y relaciones de los papers
- [ ] Grafo persistente (NetworkX local o Neo4j)
- [ ] Retriever híbrido: vector + grafo
- [ ] Comparativa de calidad RAG vs Graph RAG en el notebook"

create_issue \
  "feat(agents): sistema multiagente con LangGraph o CrewAI" \
  "nivel:experto,tipo:feature,area:agents,prioridad:media" \
  "## Contexto
Agentes especializados por tarea (redactor, editor, fact-checker, traductor...) coordinados por un orquestador.

## Criterios de aceptación
- [ ] Decisión entre LangGraph y CrewAI registrada en \`docs/decisions/\`
- [ ] ≥3 agentes especializados con prompts/herramientas propias
- [ ] Orquestación visible en LangSmith
- [ ] Notebook \`06_experto_multiagente.ipynb\` con caso real de uso"

create_issue \
  "feat(quality): guardarraíles y evaluación contra alucinaciones" \
  "nivel:experto,tipo:feature,area:guardrails,prioridad:media" \
  "## Contexto
Detectar alucinaciones y evaluar calidad de contenido generado.

## Criterios de aceptación
- [ ] Conjunto de validaciones (longitud, tono, idioma, no-prohibidos)
- [ ] Evaluación automática con LLM-as-judge para subset de salidas
- [ ] Métricas reportadas en notebook de evaluación
- [ ] Decisión: descartar / reintentar / pedir revisión humana"

# =================================================================
# TRANSVERSALES
# =================================================================

create_issue \
  "chore(ci): GitHub Actions con lint + tests en cada PR" \
  "tipo:chore,area:infra,prioridad:baja" \
  "## Contexto
Workflow básico de CI para validar PRs.

## Criterios de aceptación
- [ ] \`.github/workflows/ci.yml\` con: setup-python + uv + ruff + pytest
- [ ] Trigger en push a develop y en PRs
- [ ] Badge en README"

echo
echo "Hecho. Lista actual de issues:"
gh issue list --limit 50
