# AGENTS.md

## Project Purpose

Construct and maintain a reproducible data pipeline to assemble, clean, visualize, describe, and do inference on Small Business Administration data. This project is still in its early/exploratory phase, but the goal is to identify interesting variation/trends/descriptives that will eventually inform an applied economics research article (target journal examples: AEJ Applied, American Economic Review, Review of Economic Studies, Review of Economics and Statistics). This document constrains implementation and workflow; it does not authorize interpretive analysis, estimator choice, or scope expansion unless explicitly requested.

## Working Directory
- Project root: this repository.
- Data are stored in the '0_inputs' folder.
- All code that is not part of a .qmd folder should be saved in the '1_code' folder.
- Processed data that are output by any ingest scripts should be saved to the '2_processed_data' folder. No code or analysis should be in this folder.
- Any visuals (.png, .jpeg etc) and regression tables should be stored in the '3_outputs' folder. All non-data outputs should be written to the '3_outputs' folder.
- Notebooks for exploration/ideation are in '4_notebooks'. Often, we will work here first and have seperate procedures for refactoring the code included in notebooks to fully operational code.

## Environment
- We will primarily use R to explore, transform, visualize and analyze data.
- Do not introduce Python or other languages unless explicitly requested.
- Avoid network calls unless explicitly instructed; assume required data are already present locally unless told otherwise.

## Pathing Rules
- Do not hardcode user-specific paths unless asked.
- All code should use a relative pathing regime that accesses the '0_inputs' folder. Note that is either housed in '5_notebooks' or '1_code', which are directly accessed one level down from root.
- If a script already uses hardcoded paths, document this behavior instead of refactoring unless explicitly requested.

## Pipeline Order (High-Level)
1. To be populated.

## Outputs
- Document every output file written by scripts, including ad hoc outputs.
- Default to non-destructive updates; do not overwrite existing outputs unless explicitly instructed.

## Documentation
- Keep README detailed and internally focused.
- Document legacy code in `1_code/legacy` in a separate README section.
- If adding new scripts, update the README with purpose, inputs, outputs, and dependencies.

## Safety
- Never run destructive git commands unless explicitly asked.
- If unexpected changes or ambiguities appear, stop and ask before proceeding.

## Communication
- Be concise and explicit about assumptions.
- Ask before writing outside the repository or making any network calls.

## Task-Specific Docs
- Task-specific routines and planning documents are contained in `agent-docs`.

./agent-docs/PLANS.md - Use this as a template in the planning phase.

./agent-docs/execplans/. - Use this subfolder to store plans we have finalized as a .md file. During the planning phase, I'll iterate on these files with you, which will then be used to execute workplans.

## README Governance and Automation Rules

Codex is authorized to update the README **only** within the boundaries defined below.  
Codex is not authorized to reinterpret project goals, redefine scope, or infer intent beyond explicit instructions.
Codex should only update the README when asked. When the README is to be updated, please follow the instruction set provided in /agent-docs/README_update_instructset.md.


## Reasoning & Scope Control
- Optimize for correctness, transparency and reproducibility over elegance.
- Do not introduce new estimators, identification strategies, variable constructions, or sample definitions unless explicitly requested.
- Never infer research intent from file names, directory structure, or reference documents.
