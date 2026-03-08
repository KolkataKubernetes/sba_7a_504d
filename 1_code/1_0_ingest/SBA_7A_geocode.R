#!/usr/bin/env Rscript

#///////////////////////////////////////////////////////////////////////////////
#----                  Geocode                   ----
# File name:  SBA_7A_geocode
# Author:     Inder Majumdar + Codex
# Created:    2026-03-08
# Purpose:    Geocode borrower and bank addresses in SBA 7(A) combined data,
#             append borrower tract + borrower/bank lat-long, and save unmatched
#             addresses for review.
#///////////////////////////////////////////////////////////////////////////////

# -----------------------------
# 0) Setup and configuration
# -----------------------------

library(tidyverse)

args <- commandArgs(trailingOnly = TRUE)
check_only <- "--check-only" %in% args
overwrite <- "--overwrite" %in% args

input_path <- file.path("2_processed_data", "SBA7A_combined.rds")
output_path <- file.path("2_processed_data", "SBA7A_combined_geocoded.rds")
unmatched_path <- file.path("2_processed_data", "SBA7A_geocode_unmatched_addresses.csv")
failure_path <- file.path("2_processed_data", "SBA7A_combined_geocode_failures.csv")

geocoder_endpoint <- "https://geocoding.geo.census.gov/geocoder/geographies/addressbatch"
benchmark <- "Public_AR_Current"
vintage <- "Current_Current"
chunk_size <- 10000L
max_retries <- 2L
retry_delay_seconds <- 3

required_cols <- c(
  "BorrStreet", "BorrCity", "BorrState", "BorrZip",
  "BankStreet", "BankCity", "BankState", "BankZip"
)

abbr_to_name <- c(
  AL = "Alabama", AZ = "Arizona", AR = "Arkansas", CA = "California",
  CO = "Colorado", CT = "Connecticut", DE = "Delaware", DC = "District of Columbia",
  FL = "Florida", GA = "Georgia", ID = "Idaho", IL = "Illinois", IN = "Indiana",
  IA = "Iowa", KS = "Kansas", KY = "Kentucky", LA = "Louisiana", ME = "Maine",
  MD = "Maryland", MA = "Massachusetts", MI = "Michigan", MN = "Minnesota",
  MS = "Mississippi", MO = "Missouri", MT = "Montana", NE = "Nebraska",
  NV = "Nevada", NH = "New Hampshire", NJ = "New Jersey", NM = "New Mexico",
  NY = "New York", NC = "North Carolina", ND = "North Dakota", OH = "Ohio",
  OK = "Oklahoma", OR = "Oregon", PA = "Pennsylvania", RI = "Rhode Island",
  SC = "South Carolina", SD = "South Dakota", TN = "Tennessee", TX = "Texas",
  UT = "Utah", VT = "Vermont", VA = "Virginia", WA = "Washington",
  WV = "West Virginia", WI = "Wisconsin", WY = "Wyoming"
)
name_to_name <- setNames(unname(abbr_to_name), toupper(unname(abbr_to_name)))

clean_string <- function(x) {
  x |>
    as.character() |>
    str_squish()
}

clean_zip5 <- function(x) {
  raw <- clean_string(x)
  digits <- str_extract(raw, "\\d{5}")
  ifelse(is.na(digits), NA_character_, digits)
}

state_to_full <- function(x) {
  raw <- toupper(clean_string(x))
  out <- ifelse(raw %in% names(abbr_to_name), abbr_to_name[raw], ifelse(raw %in% names(name_to_name), name_to_name[raw], NA_character_))
  unname(out)
}

build_address <- function(street, city, state, zip) {
  s <- clean_string(street)
  c <- clean_string(city)
  st <- state_to_full(state)
  z <- clean_zip5(zip)

  invalid <- s == "" | c == "" | is.na(st) | is.na(z)
  addr <- str_c(str_to_upper(s), ", ", str_to_upper(c), ", ", st, ", ", z)
  addr[invalid] <- NA_character_
  addr
}

split_chunks <- function(n, size) {
  if (n <= 0) return(list())
  split(seq_len(n), ceiling(seq_len(n) / size))
}

parse_batch_csv <- function(csv_text) {
  raw <- read_csv(I(csv_text), col_names = FALSE, show_col_types = FALSE, na = c("", "NULL"))

  if (ncol(raw) < 8) {
    stop("Unexpected Census batch response format: fewer than 8 columns")
  }

  out <- raw |>
    transmute(
      address_id = as.character(X1),
      input_address = as.character(X2),
      match_status = as.character(X3),
      match_type = as.character(X4),
      matched_address = as.character(X5),
      coordinates = as.character(X6),
      tigerline_id = as.character(X7),
      side = as.character(X8),
      state_code = if (ncol(raw) >= 9) as.character(X9) else NA_character_,
      county_code = if (ncol(raw) >= 10) as.character(X10) else NA_character_,
      tract_code = if (ncol(raw) >= 11) as.character(X11) else NA_character_
    ) |>
    mutate(
      matched = match_status == "Match",
      lon = if_else(matched & !is.na(coordinates), str_split_fixed(coordinates, ",", 2)[, 1], NA_character_),
      lat = if_else(matched & !is.na(coordinates), str_split_fixed(coordinates, ",", 2)[, 2], NA_character_),
      lon = suppressWarnings(as.numeric(lon)),
      lat = suppressWarnings(as.numeric(lat)),
      borrower_census_tract = if_else(
        matched,
        str_c(
          str_pad(coalesce(state_code, ""), 2, side = "left", pad = "0"),
          str_pad(coalesce(county_code, ""), 3, side = "left", pad = "0"),
          str_pad(str_replace_all(coalesce(tract_code, ""), "\\.", ""), 6, side = "left", pad = "0")
        ),
        NA_character_
      ),
      borrower_census_tract = if_else(matched & nchar(borrower_census_tract) == 11, borrower_census_tract, NA_character_)
    )

  out
}

geocode_unique_addresses <- function(df_unique, role, check_only = FALSE) {
  total_unique <- nrow(df_unique)
  idx_chunks <- split_chunks(total_unique, chunk_size)
  n_batches <- length(idx_chunks)

  message(sprintf("[%s] Unique addresses to geocode: %d", role, total_unique))
  message(sprintf("[%s] Planned API batches: %d", role, n_batches))

  if (total_unique == 0) {
    return(list(
      geocoded = tibble(address_id = character(), lon = numeric(), lat = numeric(), borrower_census_tract = character(), reason = character()),
      failures = tibble(address_id = character(), address_text = character(), role = character(), reason = character())
    ))
  }

  if (check_only) {
    for (i in seq_along(idx_chunks)) {
      message(sprintf("[%s] Check-only batch %d/%d (API call skipped)", role, i, n_batches))
    }
    return(list(
      geocoded = df_unique |>
        transmute(address_id, lon = NA_real_, lat = NA_real_, borrower_census_tract = NA_character_, reason = "check_only"),
      failures = tibble(address_id = character(), address_text = character(), role = character(), reason = character())
    ))
  }

  if (!requireNamespace("httr", quietly = TRUE)) {
    stop("Package 'httr' is required for non-check geocoding runs.")
  }

  all_results <- vector("list", n_batches)
  all_failures <- list()

  for (i in seq_along(idx_chunks)) {
    batch_ids <- idx_chunks[[i]]
    batch_df <- df_unique[batch_ids, c("address_id", "address_text")]
    message(sprintf("[%s] Running batch %d/%d with %d addresses", role, i, n_batches, nrow(batch_df)))

    tmp_csv <- tempfile(pattern = paste0("geocode_", tolower(role), "_batch_"), fileext = ".csv")
    write.table(batch_df, file = tmp_csv, sep = ",", row.names = FALSE, col.names = FALSE, quote = TRUE, na = "")

    success <- FALSE
    attempt <- 0L
    last_err <- NULL

    while (!success && attempt <= max_retries) {
      attempt <- attempt + 1L
      message(sprintf("[%s] Batch %d/%d attempt %d", role, i, n_batches, attempt))

      res <- tryCatch(
        {
          httr::POST(
            url = geocoder_endpoint,
            body = list(
              addressFile = httr::upload_file(tmp_csv, type = "text/csv"),
              benchmark = benchmark,
              vintage = vintage
            ),
            encode = "multipart",
            httr::timeout(300)
          )
        },
        error = function(e) e
      )

      if (inherits(res, "error")) {
        last_err <- conditionMessage(res)
        message(sprintf("[%s] Batch %d/%d attempt %d error: %s", role, i, n_batches, attempt, last_err))
      } else if (httr::status_code(res) != 200) {
        last_err <- sprintf("HTTP %s", httr::status_code(res))
        message(sprintf("[%s] Batch %d/%d attempt %d error: %s", role, i, n_batches, attempt, last_err))
      } else {
        txt <- httr::content(res, as = "text", encoding = "UTF-8")
        parsed <- parse_batch_csv(txt) |>
          select(address_id, lon, lat, borrower_census_tract, matched) |>
          mutate(reason = if_else(matched, "matched", "no_match")) |>
          select(-matched)

        all_results[[i]] <- batch_df |>
          left_join(parsed, by = "address_id") |>
          mutate(reason = coalesce(reason, "no_response"))

        matched_n <- sum(all_results[[i]]$reason == "matched", na.rm = TRUE)
        unmatched_n <- nrow(all_results[[i]]) - matched_n
        message(sprintf("[%s] Batch %d/%d success. matched=%d unmatched=%d", role, i, n_batches, matched_n, unmatched_n))
        success <- TRUE
      }

      if (!success && attempt <= max_retries) {
        Sys.sleep(retry_delay_seconds)
      }
    }

    if (!success) {
      message(sprintf("[%s] Batch %d/%d failed after %d attempts", role, i, n_batches, max_retries + 1L))
      all_results[[i]] <- batch_df |>
        mutate(
          lon = NA_real_,
          lat = NA_real_,
          borrower_census_tract = NA_character_,
          reason = "batch_request_failed"
        )

      all_failures[[length(all_failures) + 1L]] <- batch_df |>
        transmute(
          address_id,
          address_text,
          role = role,
          reason = paste0("batch_request_failed: ", coalesce(last_err, "unknown_error"))
        )
    }

    unlink(tmp_csv)
  }

  geocoded <- bind_rows(all_results)
  failures <- if (length(all_failures) > 0) bind_rows(all_failures) else tibble(address_id = character(), address_text = character(), role = character(), reason = character())

  list(geocoded = geocoded, failures = failures)
}

# -----------------------------
# 1) Load and validate input
# -----------------------------

if (!file.exists(input_path)) {
  stop(sprintf("Input file not found: %s", input_path))
}

loans <- readRDS(input_path)

missing_cols <- setdiff(required_cols, names(loans))
if (length(missing_cols) > 0) {
  stop(sprintf("Input is missing required columns: %s", paste(missing_cols, collapse = ", ")))
}

message(sprintf("Loaded input with %d rows and %d columns", nrow(loans), ncol(loans)))

# -----------------------------
# 2) Build address fields
# -----------------------------

loans <- loans |>
  mutate(
    address_borrower = build_address(BorrStreet, BorrCity, BorrState, BorrZip),
    address_bank = build_address(BankStreet, BankCity, BankState, BankZip)
  )

borrower_invalid <- loans |>
  filter(is.na(address_borrower)) |>
  transmute(row_id = row_number(), role = "borrower", address_text = NA_character_, reason = "missing_or_non_contiguous_state_or_zip")

bank_invalid <- loans |>
  filter(is.na(address_bank)) |>
  transmute(row_id = row_number(), role = "bank", address_text = NA_character_, reason = "missing_or_non_contiguous_state_or_zip")

borrower_unique <- loans |>
  filter(!is.na(address_borrower)) |>
  distinct(address_borrower) |>
  mutate(address_id = str_c("BORR_", row_number())) |>
  transmute(address_id, address_text = address_borrower)

bank_unique <- loans |>
  filter(!is.na(address_bank)) |>
  distinct(address_bank) |>
  mutate(address_id = str_c("BANK_", row_number())) |>
  transmute(address_id, address_text = address_bank)

message(sprintf("Borrower unique addresses: %d", nrow(borrower_unique)))
message(sprintf("Bank unique addresses: %d", nrow(bank_unique)))

# -----------------------------
# 3) Optional append/update cache
# -----------------------------

borrower_cache <- tibble(address_text = character(), borrower_lat = numeric(), borrower_long = numeric(), borrower_census_tract = character())
bank_cache <- tibble(address_text = character(), bank_lat = numeric(), bank_long = numeric())

if (file.exists(output_path) && !overwrite) {
  message("Existing geocoded output found. Running append/update mode.")
  existing <- readRDS(output_path)

  if (all(c("borrower_lat", "borrower_long", "borrower_census_tract") %in% names(existing))) {
    existing <- existing |>
      mutate(address_borrower = build_address(BorrStreet, BorrCity, BorrState, BorrZip),
             address_bank = build_address(BankStreet, BankCity, BankState, BankZip))

    borrower_cache <- existing |>
      filter(!is.na(address_borrower), !is.na(borrower_lat), !is.na(borrower_long)) |>
      distinct(address_text = address_borrower, borrower_lat, borrower_long, borrower_census_tract)

    bank_cache <- existing |>
      filter(!is.na(address_bank), !is.na(bank_lat), !is.na(bank_long)) |>
      distinct(address_text = address_bank, bank_lat, bank_long)

    message(sprintf("Cached borrower geocodes: %d", nrow(borrower_cache)))
    message(sprintf("Cached bank geocodes: %d", nrow(bank_cache)))
  }
}

borrower_to_geocode <- borrower_unique |>
  anti_join(borrower_cache |> select(address_text), by = "address_text")

bank_to_geocode <- bank_unique |>
  anti_join(bank_cache |> select(address_text), by = "address_text")

message(sprintf("Borrower addresses requiring API geocode: %d", nrow(borrower_to_geocode)))
message(sprintf("Bank addresses requiring API geocode: %d", nrow(bank_to_geocode)))

# -----------------------------
# 4) Geocode batch processing
# -----------------------------

borrower_res <- geocode_unique_addresses(borrower_to_geocode, role = "Borrower", check_only = check_only)
bank_res <- geocode_unique_addresses(bank_to_geocode, role = "Bank", check_only = check_only)

if (check_only) {
  message("Check-only mode complete. No API calls were made and no files were written.")
  quit(save = "no", status = 0)
}

borrower_lookup_new <- borrower_to_geocode |>
  left_join(borrower_res$geocoded, by = "address_id") |>
  transmute(
    address_text,
    borrower_long = lon,
    borrower_lat = lat,
    borrower_census_tract,
    borrower_reason = reason
  )

bank_lookup_new <- bank_to_geocode |>
  left_join(bank_res$geocoded, by = "address_id") |>
  transmute(
    address_text,
    bank_long = lon,
    bank_lat = lat,
    bank_reason = reason
  )

borrower_lookup <- borrower_cache |>
  mutate(borrower_reason = "cached") |>
  bind_rows(borrower_lookup_new) |>
  distinct(address_text, .keep_all = TRUE)

bank_lookup <- bank_cache |>
  mutate(bank_reason = "cached") |>
  bind_rows(bank_lookup_new) |>
  distinct(address_text, .keep_all = TRUE)

# -----------------------------
# 5) Merge geocodes + create unmatched logs
# -----------------------------

out <- loans |>
  left_join(borrower_lookup, by = c("address_borrower" = "address_text")) |>
  left_join(bank_lookup, by = c("address_bank" = "address_text"))

unmatched_borrower <- out |>
  filter(is.na(borrower_lat) | is.na(borrower_long) | is.na(borrower_census_tract)) |>
  transmute(
    role = "borrower",
    address_text = address_borrower,
    reason = coalesce(borrower_reason, "missing_or_non_contiguous_state_or_zip")
  ) |>
  distinct()

unmatched_bank <- out |>
  filter(is.na(bank_lat) | is.na(bank_long)) |>
  transmute(
    role = "bank",
    address_text = address_bank,
    reason = coalesce(bank_reason, "missing_or_non_contiguous_state_or_zip")
  ) |>
  distinct()

unmatched_invalid <- bind_rows(borrower_invalid, bank_invalid) |>
  select(role, address_text, reason) |>
  distinct()

unmatched_all <- bind_rows(unmatched_borrower, unmatched_bank, unmatched_invalid) |>
  distinct()

write_csv(unmatched_all, unmatched_path)
message(sprintf("Wrote unmatched-address review file: %s (%d rows)", unmatched_path, nrow(unmatched_all)))

failure_rows <- bind_rows(borrower_res$failures, bank_res$failures)
if (nrow(failure_rows) > 0) {
  write_csv(failure_rows, failure_path)
  message(sprintf("Wrote batch-failure file: %s (%d rows)", failure_path, nrow(failure_rows)))
} else {
  if (file.exists(failure_path)) {
    file.remove(failure_path)
  }
  message("No exhausted batch failures; failure artifact not created.")
}

# -----------------------------
# 6) Save processed data + summary logs
# -----------------------------

out <- out |>
  select(-address_borrower, -address_bank, -borrower_reason, -bank_reason)

saveRDS(out, output_path)

borrower_matches <- sum(!is.na(out$borrower_lat) & !is.na(out$borrower_long), na.rm = TRUE)
bank_matches <- sum(!is.na(out$bank_lat) & !is.na(out$bank_long), na.rm = TRUE)
tract_len_ok <- all(nchar(out$borrower_census_tract[!is.na(out$borrower_census_tract) & out$borrower_census_tract != ""]) == 11)

message(sprintf("Success: wrote %s", output_path))
message(sprintf("Borrower matches: %d / %d", borrower_matches, nrow(out)))
message(sprintf("Bank matches: %d / %d", bank_matches, nrow(out)))
message(sprintf("Borrower tract 11-digit check: %s", tract_len_ok))
