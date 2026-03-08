## README Governance and Automation Rules (Codex-Enforced)

### Scope of Codex Authority (README)

Codex is authorized to update the README **only** within the boundaries defined below.  
Codex is not authorized to reinterpret project goals, redefine scope, or infer intent beyond explicit instructions.

---

### Sections Codex May Update Automatically

Codex may update the following README sections **without additional approval**, provided changes are purely descriptive and mechanically verifiable from the repository:

- Repository Orientation  
  - High-Level Structure  
  - Data Definitions, Location and Pathing
- Pipeline Summary  
  - Pipeline Order (High-Level)
- Scripts and Outputs (Inventory)  
  - Ingest Scripts  
  - Transform/Clean Scripts  
  - Visualization Scripts  
  - Output Files and Directories  
  - TEMP/TEST Outputs
- Versioning and Change Log  
  - Change log entries describing README or pipeline updates

Rules:
- Changes must reflect **observable repository state** only.
- Do not summarize script logic beyond stated inputs, outputs, and role in pipeline.
- Do not restate code comments or internal function behavior.

---

### Sections Codex May **Not** Modify Without Explicit Approval

The following sections are **human-governed** and must not be altered, reworded, expanded, or summarized unless explicitly instructed:

- Project Overview  
  - Title  
  - Purpose and Scope  
  - Reference Report Alignment
- Reproducibility
- Known Issues and Limitations
- Methodology and Processing Notes (conceptual descriptions)
- Access, Licensing, and Restrictions (interpretive or legal content)
- Funding
- Any language that defines:
  - project intent
  - analytical boundaries
  - alignment meaning
  - limitations or exclusions

If these sections become inconsistent with the repository, Codex must **flag the inconsistency and stop**, not correct it.

---

### Alignment and Claims Discipline

When updating the README:

- Do **not** introduce new claims about:
  - policy relevance
  - economic interpretation
  - causal meaning
  - data completeness or representativeness
- The phrase *“aligned with the CORI reference report”* must:
  - refer only to **structure, scope, definitions, and aggregation**
  - never imply validation, endorsement, or analytical equivalence

If alignment becomes ambiguous, Codex must ask for clarification.

---

### Script Enumeration Rules

- Enumerate **only pipeline-defining scripts**.
- Exclude:
  - exploratory scripts
  - deprecated scripts
  - scratch files
  - scripts marked TEMP unless explicitly promoted
- TEMP/TEST scripts may be listed **only** under the TEMP/TEST Outputs section.

Codex must not infer importance from file names alone.

---

### Data Dictionary and Appendix Policy

- The README must **not** contain full variable-level data dictionaries.
- The README may only:
  - point to schema or dictionary files
  - describe their scope at a high level

If detailed schema information is required, it must live outside the README (e.g., `agent-docs/`).

---

### Reproducibility Language (Hard Constraint)

Codex must not assert full reproducibility unless explicitly instructed.

Default language assumption:

> “This repository is conditionally reproducible given access to external input data referenced via `input_root.txt`.”

Any stronger claim requires explicit approval.

---

### Negative Scope Statements

Codex must preserve and not weaken statements of what the repository **does not do**, including but not limited to:
- causal inference
- estimator selection
- interpretive analysis
- scope expansion beyond Wisconsin

If such statements are missing, Codex may suggest adding them but must not insert them autonomously.

---

### Change Logging Rules

Every automated README update must:
- Add a brief entry to the Change Log
- State:
  - what was updated
  - whether changes were mechanical (inventory/pathing) or structural

Do not bundle unrelated updates into a single change log entry.

---

### Failure Mode Protocol

If Codex encounters:
- ambiguity about scope
- conflict between README and AGENTS.md
- unclear script role in pipeline
- uncertainty about whether content is descriptive vs. interpretive

Codex must:
1. Stop
2. State the ambiguity explicitly
3. Ask for instruction before proceeding

---

### README Philosophy (Binding)

The README is:
- a **system-level map**, not a substitute for code comments
- internally focused and maintainer-oriented
- authoritative only where explicitly stated

Codex must optimize for **accuracy, restraint, and durability**, not completeness.
