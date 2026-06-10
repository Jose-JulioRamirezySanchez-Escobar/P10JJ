# Flujos de alto nivel — P10JJ

> Documento vivo. Visión a vista de pájaro del sistema completo. Las SPECs individuales (`SPEC_*.md`) profundizan en cada feature.
> Estado: Draft  |  Última revisión: 2026-06-08

---

## 1. Mapa del repositorio (qué hay dónde)

```mermaid
graph TD
    R["P10JJ/"]
    R --> NB["notebooks/<br/>00..06 ipynb por nivel"]
    R --> SRC["src/p10jj/<br/>código reutilizable"]
    R --> DOCS["docs/"]
    R --> DK["docker/<br/>Dockerfile + compose"]
    R --> TT["tests/"]
    R --> DT["data/<br/>raw / interim / processed / sample"]
    R --> LG["logs/"]

    SRC --> SP["providers/<br/>groq, gemini, ollama"]
    SRC --> SPR["prompts/<br/>plantillas .md"]
    SRC --> SR["rag/"]
    SRC --> SA["agents/"]
    SRC --> SG["guardrails/"]
    SRC --> SU["ui/<br/>app.py Streamlit"]

    DOCS --> DB["briefing/<br/>material bootcamp (gitignored)"]
    DOCS --> DD["design/<br/>SPEC_*.md y este documento"]
    DOCS --> DDE["decisions/<br/>ADRs"]
    DOCS --> DM["medium/<br/>borradores artículo"]
```

---

## 2. Arquitectura general

Componentes y sus relaciones. Las flechas continuas indican uso obligatorio en el nivel Esencial; las discontinuas son extensiones de niveles superiores.

```mermaid
flowchart TB
    subgraph FE["Frontend (Nivel Esencial)"]
        UI["Streamlit UI<br/>src/p10jj/ui/app.py"]
    end

    subgraph CORE["Núcleo (src/p10jj)"]
        GEN["generar()<br/>core.py"]
        PROMPTS["Plantillas de prompt<br/>prompts/*.md"]
        RAG_M["RAG<br/>rag/"]
        AG["Agentes<br/>agents/"]
        GR["Guardarraíles<br/>guardrails/"]
    end

    subgraph PROV["Proveedores LLM"]
        GROQ["Groq (cloud)"]
        GEMINI["Gemini (cloud)"]
        OLLAMA["Ollama (local)"]
    end

    subgraph DATA["Datos y embeddings"]
        CHROMA[("Chroma DB<br/>persistente")]
        EMB["sentence-transformers<br/>embeddings locales"]
        ARXIV[("arXiv API")]
    end

    subgraph OBS["Observabilidad (Avanzado)"]
        LS["LangSmith"]
    end

    UI --> GEN
    GEN --> PROMPTS
    GEN --> GROQ
    GEN -.-> GEMINI
    GEN -.-> OLLAMA
    GEN -.-> RAG_M
    GEN -.-> AG
    AG -.-> GR
    RAG_M --> CHROMA
    RAG_M --> EMB
    RAG_M --> ARXIV
    GEN -.->|trazas| LS
    AG -.->|trazas| LS
```

---

## 3. Flujo principal — generación de contenido (Nivel Esencial)

El camino mínimo desde que el usuario escribe un tema hasta que ve texto en pantalla.

```mermaid
sequenceDiagram
    actor U as Usuario
    participant UI as Streamlit UI
    participant C as generar()
    participant T as Plantilla
    participant P as Provider (Groq)

    U->>UI: tema + plataforma + audiencia + tono
    UI->>C: generar(tema, plataforma, audiencia, tono)
    C->>T: cargar plantilla por plataforma
    T-->>C: prompt con marcadores {tema} {audiencia} {tono}
    C->>C: rellenar marcadores con valores
    C->>P: invoke(prompt)
    P-->>C: texto generado
    C-->>UI: string
    UI-->>U: mostrar resultado (con copiable + contador palabras)
```

---

## 4. Evolución por niveles — qué se activa en cada uno

| Nivel | Frontend | Providers | Datos / RAG | Agentes | Observabilidad |
|---|---|---|---|---|---|
| Esencial | Streamlit simple | Groq | — | — | — |
| Medio | + selector provider, imágenes, dockerizado | + Gemini | — | — | — |
| Avanzado | + selector idioma | (igual) | + Chroma + arXiv + embeddings + multilenguaje + finanzas | — | **LangSmith** |
| Experto | (igual) | (igual) | + Graph RAG (grafo de conocimiento) | **multiagente + guardarraíles** | LangSmith |

Cada fila *suma* a la anterior; lo que se añade en un nivel no se quita en el siguiente.

### 4.1 Flujo RAG (Nivel Avanzado)

Cómo viaja una pregunta científica desde el usuario hasta una respuesta con citas a papers de arXiv.

```mermaid
flowchart LR
    Q["Pregunta del usuario"] --> EMBQ["Embedding de la pregunta"]
    EMBQ --> SRCH[("Chroma:<br/>buscar k vecinos")]
    SRCH --> CTX["Contexto:<br/>top-k chunks + metadatos"]
    CTX --> PRM["Prompt = pregunta + contexto + plantilla divulgativa"]
    PRM --> LLM["LLM (Groq/Gemini)"]
    LLM --> RES["Respuesta divulgativa<br/>con citas a papers"]

    subgraph ING["Ingesta previa (offline, una vez por tema)"]
        AX["arXiv API<br/>filtro por categoría + fecha"] --> PDF["Descargar PDFs"]
        PDF --> CHK["Chunking<br/>(tamaño + overlap)"]
        CHK --> EMBI["Embedding<br/>sentence-transformers"]
        EMBI --> SRCH
    end
```

### 4.2 Flujo Multiagente (Nivel Experto)

Varios agentes especializados colaboran. El orquestador decide el orden; los guardarraíles validan antes de publicar.

```mermaid
flowchart TB
    U["Usuario:<br/>petición de contenido"] --> ORQ["Orquestador<br/>(LangGraph o CrewAI)"]
    ORQ --> R["Agente Redactor<br/>(LLM + plantillas)"]
    R --> E["Agente Editor<br/>(estilo + tono)"]
    E --> F["Agente Fact-Checker<br/>(RAG + LLM)"]
    F -- "encuentra errores" --> R
    F -- "OK" --> T["Agente Traductor<br/>(si se pide otro idioma)"]
    T --> GR["Guardarraíles<br/>(longitud, prohibidos, alucinación)"]
    GR -- "pasa" --> OUT["Salida final<br/>al usuario"]
    GR -- "rechaza" --> R
```

---

## 5. Flujo de desarrollo (cómo se construye cada feature)

El ciclo Gitflow simplificado del proyecto. Esto es lo que harás cada vez que abordes una issue.

```mermaid
flowchart LR
    I["Issue en GitHub<br/>(con label nivel:* y tipo:*)"] --> B["git checkout -b feature/slug"]
    B --> SP["Escribir SPEC_slug.md<br/>en docs/design/"]
    SP --> C["Codificar guiado por la SPEC"]
    C --> T["Tests + pre-commit local<br/>en verde"]
    T --> PUSH["git push"]
    PUSH --> PR["Abrir PR a develop<br/>(usa la plantilla)"]
    PR --> CI["pre-commit + CI<br/>en verde"]
    CI --> MERGE["Merge a develop"]
    MERGE --> CLOSE["Issue se cierra automáticamente<br/>(si el PR contiene 'Closes #N')"]
    CLOSE --> TAG{"¿Nivel completo?"}
    TAG -- "sí" --> REL["git tag v0.X.0-nivel<br/>+ push --tags"]
    TAG -- "no" --> NEXT["Siguiente issue"]
```

---

## Notas

- Los diagramas evolucionan: si una decisión técnica cambia, actualizamos este documento.
- Las flechas discontinuas indican componentes opcionales/avanzados.
- Cada feature relevante tendrá su propia `SPEC_*.md` con su diagrama de flujo específico (más detallado).
