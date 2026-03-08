# Geocode SBA 7(A) Borrower and Bank Addresses with Census Geocoder

This ExecPlan is a living document. The sections `Progress`, `Surprises & Discoveries`, `Decision Log`, and `Outcomes & Retrospective` must be kept up to date as work proceeds.

This document must be maintained in accordance with `agent-docs/PLANS.md` from the repository root.

---

## ExecPlan Status

Status: Execution (In Progress)  
Owner: Codex + indermajumdar  
Created: 2026-03-08  
Last Updated: 2026-03-08  
Related Project: sba_7a_504d

Optional Metadata:  
Priority: High  
Estimated Effort: 1-2 days  
Dependencies: Census Geocoder API availability; `2_processed_data/SBA7A_combined.rds`

---

## Revision History

| Date | Change | Author |
|-----|------|------|
| 2026-03-08 | Initial ExecPlan draft for SBA 7(A) geocoding workflow | Codex |
| 2026-03-08 | Implemented geocoding script and completed check-only dry run with batch progress logs | Codex |

---

## Quick Summary

**Goal**

Build a reproducible, tidyverse-based geocoding step that enriches the combined SBA 7(A) dataset with borrower/bank latitude-longitude and borrower census tract using the U.S. Census Geocoder API.

**Deliverable**

A new script in `1_code/1_0_ingest` that reads `2_processed_data/SBA7A_combined.rds`, geocodes unique borrower/bank addresses via Census batch geocoding, and writes `2_processed_data/SBA7A_combined_geocoded.rds`.

**Success Criteria**

- Script runs end-to-end without manual intervention and writes `2_processed_data/SBA7A_combined_geocoded.rds`.
- Output includes required new columns: `borrower_lat`, `borrower_long`, `bank_lat`, `bank_long`, `borrower_census_tract`.
- Validation reports successful match counts separately for borrower and bank addresses, and borrower tract values are 11-digit strings when present.
- Terminal output includes progress logs for planned batch counts, current batch index, per-batch success/failure status, and step-level completion messages.

**Key Files**

- `agent-docs/agent_context/2026_03_08_SBA_7A_geocode.md`
- `agent-docs/execplans/2026_03_08_sba7a_geocode_execplan.md`
- `1_code/1_0_ingest/SBA_7A_combine.R`
- `1_code/1_0_ingest/SBA_7A_geocode.R` (new)
- `2_processed_data/SBA7A_combined.rds`
- `2_processed_data/SBA7A_combined_geocoded.rds` (new)
- `0_inputs/census_apikey.md` (present in repo; likely not needed for Census Geocoder endpoints in this plan)

---

## Purpose / Big Picture

After this change, the project will have an analysis-ready SBA 7(A) file with geospatial features for both borrower and lender records. This enables tract-level merges and geographic summaries without manually geocoding addresses later. A user will be able to run one script and obtain a new `.rds` artifact containing the original columns plus borrower/bank coordinates and borrower tract.

---

## Progress

- [x] (2026-03-08 18:34Z) Reviewed rough task context in `agent-docs/agent_context/2026_03_08_SBA_7A_geocode.md`.
- [x] (2026-03-08 18:36Z) Reviewed Census Geocoder API documentation and current benchmark/vintage endpoints.
- [x] (2026-03-08 18:37Z) Confirmed key local input dependencies (`SBA7A_combined.rds` and address component columns).
- [x] (2026-03-08 18:50Z) Incorporated user-provided ambiguity resolutions from `## Execution Ambiguities`.
- [x] (2026-03-08 19:03Z) Implemented `1_code/1_0_ingest/SBA_7A_geocode.R` with combine-style section structure, state expansion, batch retries, and unmatched-address artifact output.
- [x] (2026-03-08 19:04Z) Ran `--check-only` dry run and verified API-free batch progress logging.
- [ ] Run geocoding and generate `2_processed_data/SBA7A_combined_geocoded.rds`.
- [ ] Run validation checks and record evidence.

---

## Surprises & Discoveries

- Observation: Census Geocoder supports batch geocoding with explicit published limits: maximum 10,000 records per batch file and 5MB size cap.
  Evidence: Census Geocoding Services API docs (batch geocoding section).

- Observation: Geocoder API requires `benchmark` and (for `geographies`) `vintage`; current default options currently include `Public_AR_Current` benchmark and `Current_Current` vintage.
  Evidence: `https://geocoding.geo.census.gov/geocoder/benchmarks` and `https://geocoding.geo.census.gov/geocoder/vintages?benchmark=4`.

- Observation: Census Geocoder API docs do not require an API key for geocoder endpoints used here.
  Evidence: required-parameter sections for single and batch requests list `benchmark`, `vintage` (when needed), and address inputs only.

- Observation: Census documentation examples explicitly show valid requests with state abbreviations (for example `state=DC` and oneline address ending in `DC 20233`).
  Evidence: JSON request examples in `https://geocoding.geo.census.gov/geocoder/Geocoding_Services_API.html`.

---

## Decision Log

- Decision: Use Census batch geocoding endpoint (`/geocoder/geographies/addressbatch`) instead of one-request-per-address calls.
  Rationale: Input size is large; batch endpoint is operationally feasible and returns both coordinates and geography fields in one response.
  Date/Author: 2026-03-08 / Codex

- Decision: Deduplicate addresses before geocoding and map results back to rows.
  Rationale: Reduces API load, improves run time, and makes reruns more stable.
  Date/Author: 2026-03-08 / Codex

- Decision: Store borrower tract only (as requested), while still geocoding borrower and bank coordinates.
  Rationale: Matches explicit scope in task context.
  Date/Author: 2026-03-08 / Codex

- Decision: Convert state abbreviations to full state names before composing address strings.
  Rationale: User preference for readability and conservative standardization, even though Census geocoder examples indicate abbreviations are accepted.
  Date/Author: 2026-03-08 / Codex

- Decision: Require explicit progress/error/success terminal logging at each major stage and each geocoder batch.
  Rationale: Large-run visibility is needed to monitor runtime progress and detect failing chunks quickly.
  Date/Author: 2026-03-08 / Codex

- Decision: Use `BankCity` (not `BorrCity`) in bank address construction.
  Rationale: Explicitly resolved by user in `Execution Ambiguities`.
  Date/Author: 2026-03-08 / Codex

- Decision: Build `borrower_census_tract` as 11-digit GEOID from geocoder geography fields `STATE + COUNTY + TRACT`.
  Rationale: Explicitly resolved by user; output must be tract-length compliant and standardized as character.
  Date/Author: 2026-03-08 / Codex

- Decision: On batch failure, retry each failed batch up to 2 times with short delay, then write failed rows to a separate processed-data failure artifact and return NA outputs for those rows.
  Rationale: Explicitly resolved by user to preserve observability and row completeness.
  Date/Author: 2026-03-08 / Codex

- Decision: Restrict state-name conversion support to the 48 contiguous states plus District of Columbia.
  Rationale: Explicitly resolved analysis scope; non-supported states should be logged.
  Date/Author: 2026-03-08 / Codex

- Decision: Support append/update behavior when output already exists.
  Rationale: Explicitly resolved by user to avoid unnecessary full rebuild replacement.
  Date/Author: 2026-03-08 / Codex

---

## Outcomes & Retrospective

Execution started. Script implementation is complete and a check-only dry run succeeded, including detailed batch progress logs and API-free behavior in check mode. Full API run and artifact validation remain pending.

---

## Context and Orientation

Input data for this task is `2_processed_data/SBA7A_combined.rds`, produced by `1_code/1_0_ingest/SBA_7A_combine.R`. The combined file currently includes borrower and bank address components needed to construct geocoder inputs: `BorrStreet`, `BorrCity`, `BorrState`, `BorrZip`, `BankStreet`, `BankCity`, `BankState`, `BankZip`.

In this plan, “benchmark” means the Census address-range dataset version used for geocoding. “Vintage” means the geography vintage used for geographic lookup fields (for this plan, census tract extraction). We will use Census geocoder “geographies” return type so each successful match can return both coordinates and tract-level geography codes.

Address construction will follow user-provided guidance and use one-line address strings. Temporary composed address fields are used for geocoding and dropped before final save.

---

## Data Artifact Flow

Raw / Existing Inputs  
- `2_processed_data/SBA7A_combined.rds`

Intermediate Artifacts  
- In-memory borrower and bank one-line address strings (`address_borrower`, `address_bank`)  
- Deduplicated address tables for borrower and bank  
- Temporary chunked CSV files for Census batch submission (written to a temp directory and removed after successful run)  
- Parsed batch geocoder response tables keyed by unique address ID

Final Outputs  
- `2_processed_data/SBA7A_combined_geocoded.rds`

---

## Plan of Work

Create `1_code/1_0_ingest/SBA_7A_geocode.R` using tidyverse-style code, clear comments, and the same top-level section style used in `1_code/1_0_ingest/SBA_7A_combine.R` (for example: `0) Setup and configuration`, `1) Address construction`, `2) Geocode`, `3) Save processed data`, `4) Validation summary`). The script will read the combined SBA dataset, construct borrower and bank one-line addresses, geocode deduplicated address lists in batch mode, and merge geocode outputs back to the original rows.

Address composition will use these templates:

- borrower: `BorrStreet, BorrCity, BorrState, BorrZip`
- bank: `BankStreet, BankCity, BankState, BankZip`

The script will normalize address components (trim whitespace, uppercase text fields, normalize ZIP to five-digit if possible) before concatenation. State values will be converted from USPS abbreviations to full state names with a deterministic mapping table embedded in the script for the 48 contiguous states plus District of Columbia only.

Batch geocoding implementation details:

- endpoint: `https://geocoding.geo.census.gov/geocoder/geographies/addressbatch`
- request form fields: `addressFile`, `benchmark`, `vintage`
- benchmark target: default benchmark name `Public_AR_Current` (or current default resolved via `/benchmarks` endpoint)
- vintage target: `Current_Current` for the selected benchmark
- batch submission chunking: split unique addresses into chunks no larger than 10,000 records and conservatively below 5MB each
- retry policy: up to 2 retries per failed batch with short sleep between attempts (for example 2-5 seconds)

Logging requirements (printed with `message()` or equivalent):

- Startup log with input row count and unique borrower/bank address counts.
- Pre-geocode log with total chunk count for borrower and bank separately.
- Per-chunk progress log in the form `Borrower batch i/N` or `Bank batch i/N`.
- Per-chunk result log with matched/unmatched counts.
- Per-chunk error log with chunk index and error message, while continuing safely where possible.
- Final summary log with total borrower matches, total bank matches, and output path.

Output mapping:

- Borrower geocoder results -> `borrower_lat`, `borrower_long`, `borrower_census_tract`
- Bank geocoder results -> `bank_lat`, `bank_long`
- `borrower_census_tract` must be stored as character, built as `STATE + COUNTY + TRACT` (2 + 3 + 6 digits), zero-padded to 11 digits when present
- Temporary `address_borrower` and `address_bank` columns dropped before write

Write behavior:

- Output file path: `2_processed_data/SBA7A_combined_geocoded.rds`
- Append/update support: if output already exists, script updates geocode columns by key (preserve existing non-geocode columns) and appends any new rows if present.
- Failure artifact path: `2_processed_data/SBA7A_combined_geocode_failures.csv` capturing unresolved rows and failure reason after retries.

---

## Concrete Steps

All commands below are run from repository root: `/Users/indermajumdar/Research/sba_7a_504d`.

1. Confirm prerequisite input exists.

    test -f 2_processed_data/SBA7A_combined.rds && echo "input_exists"

Expected behavior: prints `input_exists`.

2. (Implementation) run geocoding script in check mode for schema and endpoint readiness.

    /usr/local/bin/Rscript 1_code/1_0_ingest/SBA_7A_geocode.R --check-only

Expected behavior: confirms required columns, selected benchmark/vintage, planned chunk counts, and prints stage logs without hitting the API and without writing final artifact.

3. Run full geocoding build.

    /usr/local/bin/Rscript 1_code/1_0_ingest/SBA_7A_geocode.R

Expected behavior: writes `2_processed_data/SBA7A_combined_geocoded.rds` and prints borrower/bank batch progress, per-batch status, any errors, and final match summaries.

4. Verify output schema and key columns.

    /usr/local/bin/Rscript -e 'x <- readRDS("2_processed_data/SBA7A_combined_geocoded.rds"); stopifnot(all(c("borrower_lat","borrower_long","bank_lat","bank_long","borrower_census_tract") %in% names(x))); cat("schema_ok\n")'

Expected behavior: prints `schema_ok`.

---

## Validation and Acceptance

Validation check 1 (fail-before, pass-after): output artifact creation.

1. Command(s):

    test -f 2_processed_data/SBA7A_combined_geocoded.rds && echo "exists"

2. Expected artifact(s) or output(s):

Before first geocoding run: no `exists` output.  
After successful geocoding run: prints `exists`.

3. Expected behavior or result:

Primary output file appears at the required path only after execution.

4. Why this is sufficient evidence:

Confirms deliverable production at the planned location.

Validation check 2: geocode and tract integrity checks.

1. Command(s):

    /usr/local/bin/Rscript -e 'x <- readRDS("2_processed_data/SBA7A_combined_geocoded.rds"); b_ok <- sum(!is.na(x$borrower_lat) & !is.na(x$borrower_long)); k_ok <- sum(!is.na(x$bank_lat) & !is.na(x$bank_long)); t <- x$borrower_census_tract; t_ok <- all(nchar(t[!is.na(t) & t != ""]) == 11); cat(sprintf("borrower_matches=%d\nbank_matches=%d\ntract_len_ok=%s\n", b_ok, k_ok, t_ok)); stopifnot(t_ok)'

2. Expected artifact(s) or output(s):

Prints borrower match count, bank match count, and `tract_len_ok=TRUE`.

3. Expected behavior or result:

Both borrower and bank geocode success counts are observable; borrower tract values present in output meet required 11-digit format.

4. Why this is sufficient evidence:

Directly tests the two required geocoding outcomes (coordinate enrichment and tract formatting).

Validation check 3: log coverage check (progress visibility).

1. Command(s):

    /usr/local/bin/Rscript 1_code/1_0_ingest/SBA_7A_geocode.R --check-only

2. Expected artifact(s) or output(s):

Console output includes at least: total planned borrower/bank batches and explicit batch index format (`i/N`) for dry-run batch traversal.

3. Expected behavior or result:

User can observe run progress and identify failure location by batch index from terminal logs.

4. Why this is sufficient evidence:

Confirms required operational transparency for long API-driven runs.

Validation check 4: failure artifact behavior (only if failures occur).

1. Command(s):

    test -f 2_processed_data/SBA7A_combined_geocode_failures.csv && echo \"failures_logged\"

2. Expected artifact(s) or output(s):

If any batches remain failed after retries, prints `failures_logged` and CSV contains failed row identifiers plus reason.

3. Expected behavior or result:

Failures are explicitly documented instead of silently dropped.

4. Why this is sufficient evidence:

Confirms traceable error handling and row-level accountability for unresolved geocodes.

---

## Idempotence and Recovery

Given unchanged input and the same benchmark/vintage parameters, reruns should produce stable output for successfully matched addresses. The script should be safe to rerun because geocoding is based on deduplicated addresses and deterministic merge keys.

If a run fails mid-batch, recovery is to rerun the script; temporary chunk files should be written in a temp directory and cleaned up on normal completion. Failed rows after retry exhaustion are written to `2_processed_data/SBA7A_combined_geocode_failures.csv` with NA geocode outputs in the main output so row count remains preserved.

Check mode is safe and API-free by design.

---

## Artifacts and Notes

Evidence to record during execution:

    <check-only summary excerpt>
    <borrower/bank match summary excerpt>
    <artifact existence check excerpt>
    <schema_ok and tract_len_ok excerpt>
    <retry log excerpt, if any>
    <failure artifact excerpt, if any>

External reference used while drafting this plan (limited to user-provided Census geocoder docs scope):

- https://geocoding.geo.census.gov/geocoder/Geocoding_Services_API.html
- https://geocoding.geo.census.gov/geocoder/benchmarks
- https://geocoding.geo.census.gov/geocoder/vintages?benchmark=4

---

## Data Contracts, Inputs, and Dependencies

Dependencies:

- R with tidyverse stack for data wrangling.
- HTTP request utility in R (`httr2` or `httr`) for multipart batch submissions.
- Input dataset: `2_processed_data/SBA7A_combined.rds`.

Input contract:

- Required columns in input: `BorrStreet`, `BorrCity`, `BorrState`, `BorrZip`, `BankStreet`, `BankCity`, `BankState`, `BankZip`.
- Each row represents one SBA 7(A) loan record.

Script contract (`1_code/1_0_ingest/SBA_7A_geocode.R`):

- Inputs: combined SBA 7(A) RDS file and Census geocoder endpoint parameters.
- Outputs: `2_processed_data/SBA7A_combined_geocoded.rds` with all original columns plus five new columns.
- Invariants: row count preserved exactly; original columns unchanged; temporary address columns removed in final artifact.

Output contract:

- New columns must exist: `borrower_lat`, `borrower_long`, `bank_lat`, `bank_long`, `borrower_census_tract`.
- `borrower_census_tract` is character and 11 digits for non-missing values.
- Success diagnostics for borrower and bank matching are printed.
- If unresolved rows remain after retries, failure CSV artifact is written with reason field.

---

## Completion Checklist

Before marking the ExecPlan **Complete**, verify:

- [ ] All planned steps have been executed.
- [ ] Validation and acceptance checks passed.
- [ ] `2_processed_data/SBA7A_combined_geocoded.rds` is created and readable.
- [ ] Row count is preserved from input to output.
- [ ] Progress log reflects final state.
- [ ] ExecPlan Status updated to **Complete**.

---

## Change Notes

2026-03-08: Created initial planning-phase geocoding ExecPlan from rough context + Census Geocoder documentation, including concrete endpoint choices, chunking strategy, and validation criteria.
2026-03-08: Revised plan to require `SBA_7A_combine.R`-style script structure, abbreviation-to-full-state-name conversion, and explicit batch progress/error/success logging.
2026-03-08: Integrated user ambiguity resolutions for bank city field, tract construction rule, retry policy, check-only API behavior, contiguous+DC scope, and append/update output behavior.
2026-03-08: Updated to `Execution (In Progress)` after implementing `SBA_7A_geocode.R` and verifying `--check-only` dry run output.
