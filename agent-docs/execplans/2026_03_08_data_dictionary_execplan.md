# Build Raw SBA Data Dictionary (7a + 504)

This ExecPlan is a living document. The sections `Progress`, `Surprises & Discoveries`, `Decision Log`, and `Outcomes & Retrospective` must be kept up to date as work proceeds.

This document must be maintained in accordance with `agent-docs/PLANS.md` from the repository root.

---

## ExecPlan Status

Status: Complete  
Owner: Codex + indermajumdar  
Created: 2026-03-08  
Last Updated: 2026-03-08  
Related Project: sba_7a_504d

Optional Metadata:  
Priority: High  
Estimated Effort: 0.5-1 day  
Dependencies: local raw files under `0_inputs/SBA`

---

## Revision History

| Date | Change | Author |
|-----|------|------|
| 2026-03-08 | Initial ExecPlan draft for raw SBA data dictionary build | Codex |
| 2026-03-08 | Implemented script, generated dictionary output, and logged execution evidence while keeping plan open | Codex |
| 2026-03-08 | Updated script rerun behavior to append net-new variables and preserve manual edits | Codex |
| 2026-03-08 | Closed ExecPlan after implementation, validation, and documentation updates | Codex |

---

## Quick Summary

**Goal**

Create a reproducible, R-based process that builds one raw-data dictionary for SBA 7(a) and 504 FOIA files in `0_inputs/SBA`, with clear variable metadata and fill-rate diagnostics.

**Deliverable**

A CSV file at `0_inputs/data_dictionary.csv` plus one R script in `1_code` that regenerates it from the six raw SBA CSV files.

**Success Criteria**

- Running the planned R script from repo root completes without error and writes `0_inputs/data_dictionary.csv`.
- The dictionary contains one row per unique variable within each source dataset (`7_A`, `504`) and includes required metadata columns.
- Validation checks confirm cross-period schema consistency for each dataset family and verify `percent_filled` is bounded in `[0, 100]`.

**Key Files**

- `agent-docs/execplans/2026_03_08_data_dictionary_execplan.md`
- `0_inputs/SBA/504/foia-504-fy1991-fy2009-asof-250630(1).csv`
- `0_inputs/SBA/504/foia-504-fy2010-present-asof-250630(1).csv`
- `0_inputs/SBA/7_A/foia-7a-fy1991-fy1999-asof-250630.csv`
- `0_inputs/SBA/7_A/foia-7a-fy2000-fy2009-asof-250630.csv`
- `0_inputs/SBA/7_A/foia-7a-fy2009-fy2019-asof-250630.csv`
- `0_inputs/SBA/7_A/foia-7a-fy2020-present-asof-250630.csv`
- `1_code/1_0_ingest/create_data_dictionary.R` (new)
- `0_inputs/data_dictionary.csv` (new)

---

## Purpose / Big Picture

After this change, a contributor can run a single R script and get a unified, machine-readable data dictionary for the raw SBA files currently used by the project. The dictionary will document provenance and variable meaning while also reporting completeness (`percent_filled`) and data characterization (`data_format`, `data_type`) so future cleaning and analysis work starts from a transparent baseline.

The user-visible behavior is simple: execute one script and inspect one CSV output in `0_inputs`.

---

## Progress

- [x] (2026-03-08 17:35Z) Reviewed planning requirements in `AGENTS.md`, `agent-docs/PLANS.md`, and `agent-docs/agent_context/2026_03_07_data_dict.md`.
- [x] (2026-03-08 17:37Z) Confirmed current raw SBA file inventory and file naming in `0_inputs/SBA/504` and `0_inputs/SBA/7_A`.
- [x] (2026-03-08 17:39Z) Verified header-level schema consistency across time-split files within each source family (7(a) and 504).
- [x] (2026-03-08 18:22Z) Finalized current dictionary column set for this spec cycle, including `source`, `percent_filled`, `data_format`, and `data_type`.
- [x] (2026-03-08 18:05Z) Implemented `1_code/1_0_ingest/create_data_dictionary.R` with schema consistency checks, `--check-only`, and non-destructive output behavior.
- [x] (2026-03-08 18:06Z) Generated `0_inputs/data_dictionary.csv` (83 rows, 14 columns).
- [x] (2026-03-08 18:08Z) Ran validation checks and recorded console evidence.
- [x] (2026-03-08 18:16Z) Implemented and verified append-only rerun mode: existing dictionary rows are preserved and only unseen `source + variable_name` rows are added.
- [x] (2026-03-08 18:24Z) Iterated based on user review by implementing append-only rerun behavior and adding instructional comments.

---

## Surprises & Discoveries

- Observation: The 7(a) files include quoted headers in three files but unquoted headers in the earliest file.
  Evidence: Header line inspection via `head -n 1` across all four files.

- Observation: Despite quoting differences, the 7(a) variable names are currently aligned across all four time-split files; 504 headers are aligned across both files.
  Evidence: Side-by-side header checks show identical names after quote normalization.

- Observation: Default `Rscript` in this environment failed due to a broken Anaconda-linked runtime (`libreadline.6.2.dylib` missing).
  Evidence: `dyld: Library not loaded: @rpath/libreadline.6.2.dylib` when running `Rscript`.

---

## Decision Log

- Decision: Build one dictionary file with a `source` column rather than two separate dictionary files.
  Rationale: This preserves a single "one-stop source" while still distinguishing 7(a) vs 504.
  Date/Author: 2026-03-08 / Codex

- Decision: Restrict scope to raw files in `0_inputs/SBA` and exclude any processed artifacts.
  Rationale: Matches user requirement that dictionary covers non-processed data only.
  Date/Author: 2026-03-08 / Codex

- Decision: Use R only.
  Rationale: Required by `AGENTS.md` environment rules.
  Date/Author: 2026-03-08 / Codex

- Decision: Execute with `/usr/local/bin/Rscript` for this run instead of shell-default `Rscript`.
  Rationale: Default `Rscript` binary points to a broken Anaconda runtime in this environment.
  Date/Author: 2026-03-08 / Codex

- Decision: Default rerun behavior should preserve existing dictionary rows and append only net-new variables.
  Rationale: Prevents loss of manual curation (descriptions/notes/coding comments) during refresh runs.
  Date/Author: 2026-03-08 / Codex

---

## Outcomes & Retrospective

Execution completed. The script successfully read all six raw CSV inputs, verified within-source schema consistency, and generated `0_inputs/data_dictionary.csv` with one row per source-variable combination.

Expected vs. actual: expected one dictionary output and reproducible checks; actual outcome matched that expectation. The script was improved after first pass so default reruns preserve manual curation and append only net-new variables. A notable environment caveat is that `/usr/local/bin/Rscript` must currently be used because the default `Rscript` is not runnable.

This ExecPlan is now closed for the current scope.

---

## Context and Orientation

This repository currently has raw SBA FOIA files in two source families:

1. `0_inputs/SBA/7_A` (four CSV files covering fiscal-year ranges)
2. `0_inputs/SBA/504` (two CSV files covering fiscal-year ranges)

The planned dictionary will enumerate variables from these raw files and provide metadata fields recommended by the project context and the cited Section 2.3 guidance (variable metadata plus type/format/context fields). In this plan, "schema consistency" means variable names match across time-split files within a source family after simple header normalization (for example, removing CSV quoting around header names).

No existing ingestion scripts are present under `1_code`, so this plan includes creating a new script path under `1_code/1_0_ingest`.

---

## Data Artifact Flow

Raw Inputs  
- `0_inputs/SBA/7_A/foia-7a-fy1991-fy1999-asof-250630.csv`  
- `0_inputs/SBA/7_A/foia-7a-fy2000-fy2009-asof-250630.csv`  
- `0_inputs/SBA/7_A/foia-7a-fy2009-fy2019-asof-250630.csv`  
- `0_inputs/SBA/7_A/foia-7a-fy2020-present-asof-250630.csv`  
- `0_inputs/SBA/504/foia-504-fy1991-fy2009-asof-250630(1).csv`  
- `0_inputs/SBA/504/foia-504-fy2010-present-asof-250630(1).csv`

Intermediate Artifacts  
- In-memory combined raw data frames for 7(a) and 504 inside `create_data_dictionary.R`.
- In-memory per-variable profiling table for each source family.

Final Outputs  
- `0_inputs/data_dictionary.csv`

---

## Plan of Work

Create `1_code/1_0_ingest/create_data_dictionary.R` with functions that: discover the raw CSV files for each source family, normalize column names for comparison only (no permanent rename in output metadata), validate cross-period schema consistency within each family, row-bind files within each family, and compute one metadata row per variable per source.

The script will build the dictionary using this target column schema:

- `source`: `7_A` or `504`.
- `variable_name`: raw column name.
- `display_name`: human-readable label (initially same as `variable_name`; editable later).
- `description`: plain-language definition placeholder (`NA` at initial build unless mapping exists).
- `data_format`: storage class from R profiling (`character`, `numeric`, `integer`, `logical`, `Date`, etc.).
- `data_type`: analytic type classification (`Categorical`, `Continuous`, `Identifier`, `Date`, `FreeText`, `Unknown`) inferred by deterministic rules.
- `unit`: unit or scale if known (`USD`, `count`, `percent`, `code`, etc.; otherwise `NA`).
- `allowed_values_or_coding`: coding notes for categorical/code fields (`NA` at initial build unless defined).
- `missing_value_definition`: definition used for missingness (default: blank string or `NA` after trim).
- `percent_filled`: percent of non-missing values among all rows in the source family, rounded to 2 decimals.
- `n_non_missing`: non-missing count used to compute `percent_filled`.
- `n_total`: total row count for the source family.
- `first_seen_file`: first file (sorted order) in which variable appears.
- `notes`: free-text notes placeholder (`NA` initially).

The script will write `0_inputs/data_dictionary.csv` only if either the file does not already exist or an explicit overwrite flag is set inside the script configuration section. Default behavior is non-destructive (error if output already exists).

---

## Concrete Steps

All commands below are run from repository root: `/Users/indermajumdar/Research/sba_7a_504d`.

1. Create script scaffolding and logic.

    /usr/local/bin/Rscript 1_code/1_0_ingest/create_data_dictionary.R --check-only

Expected behavior: script runs schema checks and prints source-family summaries without writing output.

2. Build dictionary artifact.

    /usr/local/bin/Rscript 1_code/1_0_ingest/create_data_dictionary.R

Expected behavior: script writes `0_inputs/data_dictionary.csv` and prints row/column summary.

3. Preview artifact shape and columns.

    /usr/local/bin/Rscript -e "d <- read.csv('0_inputs/data_dictionary.csv', stringsAsFactors = FALSE); cat(nrow(d), 'rows\\n'); print(names(d))"

Expected behavior: required dictionary columns are present; row count equals number of unique variables across both source families (counted within-family).

---

## Validation and Acceptance

Validation check 1 (fail-before, pass-after): output artifact existence and readability.

1. Command(s):

    test -f 0_inputs/data_dictionary.csv && echo "exists"

2. Expected artifact(s) or output(s):

Before implementation/run: no `exists` output (or non-zero exit).  
After implementation/run: prints `exists`.

3. Expected behavior or result:

The output file is created only after script execution.

4. Why this is sufficient evidence:

It verifies primary deliverable creation at the required path.

Validation check 2: schema and metric sanity checks.

1. Command(s):

    /usr/local/bin/Rscript -e 'd <- read.csv("0_inputs/data_dictionary.csv", stringsAsFactors = FALSE); stopifnot(all(c("source","variable_name","percent_filled","data_format","data_type") %in% names(d))); stopifnot(all(d$percent_filled >= 0 & d$percent_filled <= 100)); cat("validation_ok\n")'

2. Expected artifact(s) or output(s):

Prints `validation_ok` with zero exit code.

3. Expected behavior or result:

Dictionary includes required columns and valid fill-rate bounds.

4. Why this is sufficient evidence:

It confirms core structural requirements and the correctness range for a key computed field.

---

## Idempotence and Recovery

Script execution is idempotent with respect to input data: re-running against unchanged raw files yields the same dictionary content. Output writing is non-destructive by default; if `0_inputs/data_dictionary.csv` already exists, script should exit with a clear message unless overwrite is explicitly enabled.

If execution fails after partial processing, no intermediate files remain (processing is in-memory). Recovery is to fix the reported issue and re-run the same command.

---

## Artifacts and Notes

Planned evidence to paste during execution:

    test -f 0_inputs/data_dictionary.csv && echo exists || echo missing
    missing

    /usr/local/bin/Rscript 1_code/1_0_ingest/create_data_dictionary.R --check-only
    Source 7_A: 4 files, 1885378 rows, 43 columns
    Source 504: 2 files, 221405 rows, 40 columns
    Check-only mode complete. No output file written.

    /usr/local/bin/Rscript 1_code/1_0_ingest/create_data_dictionary.R
    Source 7_A: 4 files, 1885378 rows, 43 columns
    Source 504: 2 files, 221405 rows, 40 columns
    Wrote 0_inputs/data_dictionary.csv with 83 rows and 14 columns.

    /usr/local/bin/Rscript -e 'd <- read.csv("0_inputs/data_dictionary.csv", stringsAsFactors = FALSE); stopifnot(all(c("source","variable_name","percent_filled","data_format","data_type") %in% names(d))); stopifnot(all(d$percent_filled >= 0 & d$percent_filled <= 100)); cat("validation_ok\n")'
    validation_ok

---

## Data Contracts, Inputs, and Dependencies

Dependency set:

- R (base) and tidyverse-compatible CSV handling (`readr` or base `read.csv`; final implementation will choose one and document it in script header).
- Script location: `1_code/1_0_ingest/create_data_dictionary.R`.

Input contract:

- Required input files are the six CSVs listed in `Data Artifact Flow`.
- Each source family (`7_A`, `504`) must have internally consistent variable names across its time-split files after quote normalization.
- Missingness rule for profiling: missing if value is `NA` or empty string after whitespace trimming.

Output contract:

- Script writes exactly one CSV: `0_inputs/data_dictionary.csv`.
- One output row per `source` x `variable_name`.
- `percent_filled = 100 * n_non_missing / n_total`, rounded to 2 decimals.
- `n_total` is constant within a source family and equals the row count of the row-bound source data.

Invariants:

- No modification to raw files in `0_inputs/SBA`.
- No writes to `2_processed_data` or `3_outputs` for this task.
- Output path remains inside `0_inputs` as explicitly requested.

---

## Completion Checklist

Before marking the ExecPlan **Complete**, verify:

- [x] All planned steps have been executed.
- [x] Validation and acceptance checks passed.
- [x] Artifact is written to `0_inputs/data_dictionary.csv`.
- [x] Data contracts remain satisfied.
- [x] Progress log reflects the final state.
- [x] ExecPlan Status updated to **Complete**.

---

## Change Notes

2026-03-08: Created initial planning-phase ExecPlan from `agent-docs/PLANS.md` template and `agent-docs/agent_context/2026_03_07_data_dict.md`; added concrete dictionary schema proposal, validation design, and non-destructive output behavior for iteration before execution.
2026-03-08: Updated status to `Execution (In Progress)`, logged implementation outputs, and documented `/usr/local/bin/Rscript` requirement so iterative revisions can continue from a working baseline.
2026-03-08: Updated `create_data_dictionary.R` to preserve existing dictionary rows and append only net-new variables on default reruns; retained `--overwrite` for full rebuilds.
2026-03-08: Closed plan with `Status: Complete` after finalizing implementation, validation, and explanatory code comments.
