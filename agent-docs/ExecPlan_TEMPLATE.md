# <Short, action-oriented description>

This ExecPlan is a living document. The sections `Progress`, `Surprises & Discoveries`, `Decision Log`, and `Outcomes & Retrospective` must be kept up to date as work proceeds.

This document must be maintained in accordance with `agent-docs/PLANS.md` from the repository root.

---

## ExecPlan Status

Status: Planning | Execution (In Progress) | Paused | Complete  
Owner: <name>  
Created: YYYY-MM-DD  
Last Updated: YYYY-MM-DD  
Related Project: <repo / workstream>

Optional Metadata:
Priority: High / Medium / Low  
Estimated Effort: <hours or days>  
Dependencies: <datasets / other ExecPlans>

---

## Revision History

| Date | Change | Author |
|-----|------|------|
| YYYY-MM-DD | Initial plan created | <name> |
| YYYY-MM-DD | <revision description> | <name> |

---

## Quick Summary

**Goal**

Describe in 1–2 sentences what this ExecPlan aims to accomplish. Focus on the concrete objective and why it matters for the project. A reader should understand the purpose of the plan without reading the rest of the document.

**Deliverable**

Describe in 1–2 sentences what artifact will exist once the plan is complete. This should be something observable such as a dataset, figure, script, analysis result, or report section.

**Success Criteria**

List the specific observable outcomes that indicate success. These should be concrete conditions that can be verified (e.g., a dataset is produced, a pipeline runs without errors, a figure matches expected values).

- <Observable success condition>
- <Observable success condition>
- <Observable success condition>

**Key Files**

List the most important files or directories involved in the plan. Include full repository paths.

- `<path/to/script>`
- `<path/to/dataset>`
- `<path/to/output>`

---

## Purpose / Big Picture

Explain in a few sentences what someone gains after this change and how they can see it working. State the user-visible behavior you will enable.

---

## Progress

Use a list with checkboxes to summarize granular steps. Every stopping point must be documented here, even if it requires splitting a partially completed task into two (“done” vs. “remaining”). This section must always reflect the actual current state of the work.

- [ ] (YYYY-MM-DD HH:MMZ) Example incomplete step.
- [ ] Example partially completed step (completed: X; remaining: Y).

---

## Surprises & Discoveries

Document unexpected behaviors, bugs, optimizations, or insights discovered during implementation. Provide concise evidence.

- Observation: ...
  Evidence: ...

---

## Decision Log

Record every decision made while working on the plan in the format:

- Decision: ...
  Rationale: ...
  Date/Author: ...

---

## Outcomes & Retrospective

Complete this section when major milestones are reached or when the plan is finished. The goal is to capture what actually happened during execution and how the results compare to the original intent.

**Summary of Outcome**

Provide a brief 2–4 sentence summary describing what was accomplished and whether the plan achieved its intended goal.

**Expected vs. Actual Result**

- Expected outcome: <What the plan intended to produce>
- Actual outcome: <What was actually produced>
- Difference (if any): <Explain any discrepancy>

**Key Challenges Encountered**

List the most significant implementation challenges or blockers encountered.

- Challenge: <description>  
  Resolution: <how it was addressed>

**Lessons Learned**

Document any insights that would improve future plans or workflows.

- Lesson: <description>

**Follow-up Work**

If the execution revealed additional work that should be done later, list it here.

- Follow-up task: <description>

---

## Context and Orientation

Describe the current state relevant to this task as if the reader knows nothing. Name the key files and modules by full path. Define any non-obvious term you will use. Do not refer to prior plans.

---

## Data Artifact Flow

Describe how data moves through the pipeline associated with this plan.

Raw Inputs  
- `<path/to/raw/input>`

Intermediate Artifacts  
- `<path/to/intermediate/data>`

Final Outputs  
- `<path/to/final/dataset>`
- `<path/to/figure>`
- `<path/to/table>`

---

## Plan of Work

Describe, in prose, the sequence of edits and additions. For each edit, name the file and location (function, module) and what to insert or change. Keep it concrete and minimal.

---

## Concrete Steps

State the exact commands to run and where to run them (working directory). When a command generates output, show a short expected transcript so the reader can compare. This section must be updated as work proceeds.

---

## Validation and Acceptance

This section must define **at least one test** that verifies the plan worked correctly.  
Tests must be **observable and reproducible**, and at least **one test must fail before the change and pass after the change**.

Each test should clearly state:

1. The command used to run the test
2. The expected behavior or output
3. How the result demonstrates correctness

---

## Idempotence and Recovery

If steps can be repeated safely, say so. If a step is risky, provide a safe retry or rollback path. Keep the environment clean after completion.

---

## Artifacts and Notes

Include the most important transcripts, diffs, or snippets as indented examples. Keep them concise and focused on what proves success.

---

## Data Contracts, Inputs, and Dependencies

Be explicit about concrete dependencies and observable contracts, not abstract interfaces.

For each dependency, specify (1) the library or tool to use (and version constraints if relevant), (2) where it is used in the repository (file paths), (3) what concrete inputs it consumes (files, tables, data frames, parameters), and (4) what concrete outputs or side effects it produces.

When a script or function is central to the plan, specify its contract in operational terms: (1) required inputs (file paths, column names, schemas, assumptions), (2) outputs (files written, tables updated, objects returned), and (3) invariants that must hold (e.g., row counts preserved, keys unique, CRS unchanged).

Prefer describing contracts through data artifacts rather than code structure. Do not introduce new abstraction layers, interfaces, or class hierarchies unless explicitly requested.

If a dependency choice affects results (e.g., GeoPandas vs. Shapely operations, DuckDB vs. pandas), state the reason for the choice and the expected behavioral implications.

---

## Completion Checklist

Before marking the ExecPlan **Complete**, verify:

- [ ] All planned steps have been executed
- [ ] Validation and acceptance checks passed
- [ ] Artifacts are written to the correct repository locations
- [ ] Data contracts remain satisfied
- [ ] Progress log reflects the final state
- [ ] ExecPlan Status updated to **Complete**

---

## Change Notes

If this plan is revised, add a dated note here describing what changed and why.
