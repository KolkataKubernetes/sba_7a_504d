# Codex Execution Plans (ExecPlans):

This document describes the requirements for an execution plan ("ExecPlan"), a design document that a coding agent can follow to deliver a working feature or system change. Treat the reader as a complete beginner to this repository: they have only the current working tree and the single ExecPlan file you provide. There is no memory of prior plans and no external context. However, the reader is technically competent in R, Python, and Julia.

## How to use ExecPlans and PLANS.md

When authoring an executable specification (ExecPlan), follow PLANS.md _to the letter_. If it is not in your context, refresh your memory by reading the entire PLANS.md file. Be thorough in reading (and re-reading) source material to produce an accurate specification. When creating an ExecPlan, start from a skeleton (see Skeleton of a Good ExecPlan section, below.) and flesh it out as you do your research.

When implementing an executable specification (ExecPlan), do not prompt the user for "next steps"; simply proceed to the next milestone. Keep all sections up to date, add or split entries in the list at every stopping point to affirmatively state the progress made and next steps. Resolve ambiguities autonomously only when they concern implementation details, not research design, variable construction, or identification choices. when ambiguity affects those areas, pause and record a decision request instead.

When discussing an executable specification (ExecPlan), record decisions in a log in the ExecPlan for posterity; it should be unambiguously clear why any change to the specification was made. ExecPlans are living documents, and it should always be possible to restart from _only_ the ExecPlan and no other work.

When requirements are challenging or feasibility is uncertain, use milestones and the smallest possible proof-of-concept to de-risk the approach. Default to using existing project patterns and official docs; do not “research deeply” or read third-party library source code unless explicitly necessary to resolve a blocking ambiguity. Limit prototypes to only answer specific feasibility 
questions, then proceed to the full implementation.

## Requirements

NON-NEGOTIABLE REQUIREMENTS:

* Every ExecPlan must be fully self-contained. Self-contained means that in its current form it contains all knowledge and instructions needed for a novice to succeed.
* Every ExecPlan is a living document. Contributors are required to revise it as progress is made, as discoveries occur, and as design decisions are finalized. Each revision must remain fully self-contained.
* Every ExecPlan must enable a complete novice to implement the feature/analysis end-to-end without prior knowledge of this repo. Again, it's to assume functioning knowledge of R, Python and Julia.
* Every ExecPlan must produce a demonstrably working behavior, not merely code changes to "meet a definition".
* Every ExecPlan must define every term of art in plain language or do not use it.

Purpose and intent come first. Begin by explaining, in a few sentences, why the work matters from a user's perspective: what someone can do after this change that they could not do before, and how to see it working. Then guide the reader through the exact steps to achieve that outcome, including what to edit, what to run, and what they should observe.

Every ExecPlan must include a **Quick Summary** section near the beginning of the document. This section allows a reader to quickly understand the plan without reading the full specification.

The Quick Summary must contain four short subsections:

Goal — 1–2 sentences describing the objective of the ExecPlan and why it matters.

Deliverable — 1–2 sentences describing the artifact that will exist when the plan is complete (dataset, script, figure, table, etc.).

Success Criteria — a small list of observable outcomes that demonstrate success.

Key Files — the most important repository paths involved in the plan.

The agent executing your plan can list files, read files, search, run the project, and run tests. It does not know any prior context and cannot infer what you meant from earlier milestones. Repeat any assumption you rely on. Do not point to external blogs or docs; if knowledge is required, embed it in the plan itself in your own words. If an ExecPlan builds upon a prior ExecPlan and that file is checked in, incorporate it by reference. If it is not, you must include all relevant context from that plan.

## Formatting

Format and envelope are simple and strict. Each ExecPlan must be one single fenced code block labeled as `md` that begins and ends with triple backticks. Do not nest additional triple-backtick code fences inside; when you need to show commands, transcripts, diffs, or code, present them as indented blocks within that single fence. Use indentation for clarity rather than code fences inside an ExecPlan to avoid prematurely closing the ExecPlan's code fence. Use two newlines after every heading, use # and ## and so on, and correct syntax for ordered and unordered lists.

Every ExecPlan must begin with a **Status block** and **Revision History** section.

The Status block must include:

Status: Planning | Execution (In Progress) | Paused | Complete  
Owner  
Created date  
Last Updated date  
Related Project (repository or workstream)

Revision History must record dated changes to the plan so future contributors can understand how the specification evolved.

When writing an ExecPlan to a Markdown (.md) file where the content of the file *is only* the single ExecPlan, you should omit the triple backticks.

Write in plain prose. Prefer sentences over lists. Avoid checklists, tables, and long enumerations unless brevity would obscure meaning. Checklists are permitted only in the `Progress` section, where they are mandatory. Checklists are permitted in execution-heavy sections (Plan of Work, Concrete Steps) when clarity improves. Narrative sections must remain prose-first.

## Guidelines

Self-containment and plain language are paramount. If you introduce a phrase that is not ordinary English ("daemon", "middleware", "RPC gateway", "filter graph"), define it immediately and remind the reader how it manifests in this repository (for example, by naming the files or commands where it appears). Do not say "as defined previously" or "according to the architecture doc." Include the needed explanation here, even if you repeat yourself.

Avoid common failure modes. Do not rely on undefined jargon. Do not describe "the letter of a feature" so narrowly that the resulting code compiles but does nothing meaningful. Do not outsource key decisions to the reader. When ambiguity exists, resolve it in the plan itself and explain why you chose that path. Err on the side of over-explaining user-visible effects and under-specifying incidental implementation details.

Anchor the plan with observable outcomes. State what the user can do after implementation, the commands or scripts to run, and the concrete artifacts they should see (e.g., new output files, updated tables, figures, or log messages). Acceptance should be phrased as behavior a human can verify (e.g., a script runs without error and produces a new CSV with N rows), rather than internal code attributes. If a change is internal, explain how its impact can be demonstrated (for example, by a script that fails before and succeeds after, or by a before/after comparison of outputs).

Specify repository context explicitly. Name files with full repository-relative paths, name functions and modules precisely, and describe where new files should be created. If touching multiple areas, include a short orientation paragraph that explains how those parts fit together so a novice can navigate confidently. When running commands, show the working directory and exact command line. When outcomes depend on environment, state the assumptions and provide alternatives when reasonable.

ExecPlans that create, transform, or analyze datasets must include a **Data Artifact Flow** section. This section explains how data moves through the pipeline, including raw inputs, intermediate artifacts, and final outputs with repository-relative paths.

Be idempotent and safe. Write the steps so they can be run multiple times without causing damage or drift. If a step can fail halfway, include how to retry or adapt. If a migration or destructive operation is necessary, spell out backups or safe fallbacks. Prefer additive, testable changes that can be validated as you go.

Validation is required. Every ExecPlan must define 1–2 concrete validation checks appropriate to the task.

When the plan introduces or changes executable logic, these checks should usually include at least one reproducible test that fails before the change and passes after it.

When the plan primarily produces analytical or visual artifacts, validation may instead consist of artifact creation checks, data integrity checks, or specification-conformance checks.

Each validation check must specify:
1. The exact command(s) to run
2. The expected artifact(s) or output(s)
3. The expected behavior or result
4. Why this check is sufficient evidence of correctness

At least **one test must fail before the change and pass after the change**. Tests should be lightweight and reproducible. When code behavior changes, these should usually be tests. When the task is analytical or visual, these may be artifact, data, or spec-conformance checks instead. Evidence should include a short excerpt (≤10 lines) or a diff that directly proves success.

## Milestones

Milestones are narrative, not bureaucracy. If you break the work into milestones, introduce each with a brief paragraph that describes the scope, what will exist at the end of the milestone that did not exist before, the commands to run, and the acceptance you expect to observe. Keep it readable as a story: goal, work, result, proof. Progress and milestones are distinct: milestones tell the story, progress tracks granular work. Both must exist. Never abbreviate a milestone merely for the sake of brevity, do not leave out details that could be crucial to a future implementation.

Each milestone must be independently verifiable and incrementally implement the overall goal of the execution plan.

## Living plans and design decisions

* ExecPlans are living documents. As you make key design decisions, update the plan to record both the decision and the thinking behind it. Record all decisions in the `Decision Log` section.
* ExecPlans must contain and maintain a `Progress` section, a `Surprises & Discoveries` section, a `Decision Log`, and an `Outcomes & Retrospective` section. These are not optional.
* When you discover optimizer behavior, performance tradeoffs, unexpected bugs, or inverse/unapply semantics that shaped your approach, capture those observations in the `Surprises & Discoveries` section with short evidence snippets (test output is ideal).
* If you change course mid-implementation, document why in the `Decision Log` and reflect the implications in `Progress`. Plans are guides for the next contributor as much as checklists for you.
* At completion of a major task or the full plan, write an `Outcomes & Retrospective` entry summarizing what was achieved, what remains, and lessons learned.

Every ExecPlan must include a **Completion Checklist**. A plan may only be marked `Status: Complete` once all checklist items pass, including validation tests and artifact verification.

# Prototyping milestones and parallel implementations

It is acceptable—-and often encouraged—-to include explicit prototyping milestones when they de-risk a larger change. Examples: adding a low-level operator to a dependency to validate feasibility, or exploring two composition orders while measuring optimizer effects. Keep prototypes additive and testable. Clearly label the scope as “prototyping”; describe how to run and observe results; and state the criteria for promoting or discarding the prototype.

Prefer additive code changes followed by subtractions that keep tests passing. Parallel implementations (e.g., keeping an adapter alongside an older path during migration) are fine when they reduce risk or enable tests to continue passing during a large migration. Describe how to validate both paths and how to retire one safely with tests. When working with multiple new libraries or feature areas, consider creating spikes that evaluate the feasibility of these features _independently_ of one another, proving that the external library performs as expected and implements the features we need in isolation.

## Skeleton of a Good ExecPlan

    # <Short, action-oriented description>

    This ExecPlan is a living document. The sections `Progress`, `Surprises & Discoveries`, `Decision Log`, and `Outcomes & Retrospective` must be kept up to date as work proceeds.

    If PLANS.md file is checked into the repo, reference the path to that file here from the repository root and note that this document must be maintained in accordance with PLANS.md.

    ## Purpose / Big Picture

    Explain in a few sentences what someone gains after this change and how they can see it working. State the user-visible behavior you will enable.

    ## Progress

    Use a list with checkboxes to summarize granular steps. Every stopping point must be documented here, even if it requires splitting a partially completed task into two (“done” vs. “remaining”). This section must always reflect the actual current state of the work.

    - [x] (2025-10-01 13:00Z) Example completed step.
    - [ ] Example incomplete step.
    - [ ] Example partially completed step (completed: X; remaining: Y).

    Use timestamps to measure rates of progress.

    ## Surprises & Discoveries

    Document unexpected behaviors, bugs, optimizations, or insights discovered during implementation. Provide concise evidence.

    - Observation: …
      Evidence: …

    ## Decision Log

    Record every decision made while working on the plan in the format:

    - Decision: …
      Rationale: …
      Date/Author: …

    ## Outcomes & Retrospective

    Summarize outcomes, gaps, and lessons learned at major milestones or at completion. Compare the result against the original purpose.

    ## Context and Orientation

    Describe the current state relevant to this task as if the reader knows nothing. Name the key files and modules by full path. Define any non-obvious term you will use. Do not refer to prior plans.

    ## Plan of Work

    Describe, in prose, the sequence of edits and additions. For each edit, name the file and location (function, module) and what to insert or change. Keep it concrete and minimal.

    ## Concrete Steps

    State the exact commands to run and where to run them (working directory). When a command generates output, show a short expected transcript so the reader can compare. This section must be updated as work proceeds.

    ## Validation and Acceptance
    
    This section must define 1–2 concrete validation checks appropriate to the task.
    
    When the plan changes executable logic, prefer reproducible tests.
    When the plan produces analytical or visual artifacts, validation may instead consist of artifact checks, data checks, or specification checks.
    
    At least one validation check must directly verify that the primary deliverable was produced correctly.
    
    Examples of acceptable validation for visual tasks:
    - confirm the figure file is created at the expected path
    - confirm the plotted dataset has the expected row count or filtering logic
    - confirm key plotted values match the source data
    - confirm titles, labels, legends, scales, and exclusions match the specification
    - compare against a benchmark figure, summary table, or expected intermediate data extract

    ## Idempotence and Recovery

    If steps can be repeated safely, say so. If a step is risky, provide a safe retry or rollback path. Keep the environment clean after completion.

    ## Artifacts and Notes

    Include the most important transcripts, diffs, or snippets as indented examples. Keep them concise and focused on what proves success.



## Data Contracts, Inputs, and Dependencies

Be explicit about concrete dependencies and observable contracts, not abstract interfaces.

For each dependency, specify (1) the library or tool to use (and version constraints if relevant), (2) where it is used in the repository (file paths), (3) what concrete inputs it consumes (files, tables, data frames, parameters), and (4) what concrete outputs or side effects it produces.

When a script or function is central to the plan, specify its contract in operational terms: (1) required inputs (file paths, column names, schemas, assumptions), (2) outputs (files written, tables updated, objects returned), and (3) invariants that must hold (e.g., row counts preserved, keys unique, CRS unchanged).

Prefer describing contracts through data artifacts rather than code structure. Do not introduce new abstraction layers, interfaces, or class hierarchies unless explicitly requested.

Examples of acceptable specifications:
- “`1_code/1_1_4_PLSS_transaction_match.py` reads `transactions_clean.csv` and `plss_sections.gpkg` and writes `transactions_with_plss.parquet`; output must preserve one row per transaction.”
- “The function `assign_treatment_flags(df)` requires columns `{plss_id, sale_date}` and adds `{treat_A, treat_B, treat_C}` without altering existing columns.”

If a dependency choice affects results (e.g., GeoPandas vs. Shapely operations, DuckDB vs. pandas), state the reason for the choice and the expected behavioral implications.

If you follow the guidance above, a single, stateless agent -- or a human novice -- can read your ExecPlan from top to bottom and produce a working, observable result. That is the bar: SELF-CONTAINED, SELF-SUFFICIENT, NOVICE-GUIDING, OUTCOME-FOCUSED.

When you revise a plan, you must ensure your changes are comprehensively reflected across all sections, including the living document sections, and you must write a note at the bottom of the plan describing the change and the reason why. ExecPlans must describe not just the what but the why for almost everything.
