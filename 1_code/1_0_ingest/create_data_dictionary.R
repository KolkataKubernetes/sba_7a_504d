#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = TRUE)
check_only <- "--check-only" %in% args
overwrite <- "--overwrite" %in% args

normalize_names <- function(x) {
  trimws(gsub('^"|"$', "", x))
}

is_missing_value <- function(x) {
  x_chr <- as.character(x)
  is.na(x) | trimws(x_chr) == ""
}

infer_data_type <- function(var_name, values) {
  n <- tolower(var_name)

  if (grepl("date", n)) return("Date")
  if (grepl("name|street|city|description", n)) return("FreeText")
  if (grepl("id$|_id$|locationid|number|zip|code|district", n)) return("Identifier")
  if (grepl("status|type|state|program|subprogram|method|ind$|indicator|franchise|county", n)) return("Categorical")

  non_miss <- values[!is_missing_value(values)]
  if (!length(non_miss)) return("Unknown")

  suppressWarnings(num_vals <- as.numeric(non_miss))
  if (all(!is.na(num_vals))) return("Continuous")

  uniq_n <- length(unique(non_miss))
  if (uniq_n <= 20) return("Categorical")
  "Unknown"
}

infer_unit <- function(var_name) {
  n <- tolower(var_name)
  if (grepl("dollar|amount|approval|chargeoff|guaranteed", n)) return("USD")
  if (grepl("rate|percent", n)) return("percent")
  if (grepl("month|jobs|count|year", n)) return("count")
  if (grepl("code|zip|id|number", n)) return("code")
  NA_character_
}

read_header <- function(path) {
  header <- names(read.csv(path, nrows = 0, check.names = FALSE))
  normalize_names(header)
}

read_full <- function(path) {
  df <- read.csv(path, check.names = FALSE, stringsAsFactors = FALSE)
  names(df) <- normalize_names(names(df))
  df
}

collect_source <- function(source_name, dir_path) {
  files <- sort(list.files(dir_path, pattern = "\\.csv$", full.names = TRUE))
  if (!length(files)) {
    stop(sprintf("No CSV files found for source '%s' in %s", source_name, dir_path))
  }

  headers <- lapply(files, read_header)
  base_header <- headers[[1]]

  for (i in seq_along(headers)) {
    if (!identical(headers[[i]], base_header)) {
      missing_in_i <- setdiff(base_header, headers[[i]])
      extra_in_i <- setdiff(headers[[i]], base_header)
      stop(
        sprintf(
          paste0(
            "Schema mismatch in source '%s' at file %s\\n",
            "Missing columns: %s\\n",
            "Extra columns: %s"
          ),
          source_name,
          files[[i]],
          paste(missing_in_i, collapse = ", "),
          paste(extra_in_i, collapse = ", ")
        )
      )
    }
  }

  dfs <- lapply(files, read_full)
  combined <- do.call(rbind, dfs)

  first_seen <- setNames(rep(basename(files[[1]]), length(base_header)), base_header)

  list(
    source = source_name,
    files = files,
    data = combined,
    first_seen = first_seen
  )
}

build_dictionary <- function(source_obj) {
  df <- source_obj$data
  n_total <- nrow(df)
  cols <- names(df)

  rows <- lapply(cols, function(col) {
    v <- df[[col]]
    non_missing <- sum(!is_missing_value(v))
    pct_filled <- if (n_total == 0) NA_real_ else round(100 * non_missing / n_total, 2)

    data.frame(
      source = source_obj$source,
      variable_name = col,
      display_name = col,
      description = NA_character_,
      data_format = class(v)[1],
      data_type = infer_data_type(col, v),
      unit = infer_unit(col),
      allowed_values_or_coding = NA_character_,
      missing_value_definition = "NA or blank string after trim",
      percent_filled = pct_filled,
      n_non_missing = non_missing,
      n_total = n_total,
      first_seen_file = unname(source_obj$first_seen[[col]]),
      notes = NA_character_,
      stringsAsFactors = FALSE
    )
  })

  do.call(rbind, rows)
}

merge_append_new <- function(existing, generated) {
  required_keys <- c("source", "variable_name")
  if (!all(required_keys %in% names(existing))) {
    stop("Existing dictionary is missing required key columns: source, variable_name")
  }

  existing_keys <- paste(existing$source, existing$variable_name, sep = "||")
  generated_keys <- paste(generated$source, generated$variable_name, sep = "||")
  is_new <- !(generated_keys %in% existing_keys)
  new_rows <- generated[is_new, , drop = FALSE]

  if (nrow(new_rows) == 0) {
    return(list(merged = existing, n_new = 0))
  }

  all_cols <- union(names(existing), names(new_rows))
  for (col in setdiff(all_cols, names(existing))) {
    existing[[col]] <- NA
  }
  for (col in setdiff(all_cols, names(new_rows))) {
    new_rows[[col]] <- NA
  }

  merged <- rbind(existing[, all_cols, drop = FALSE], new_rows[, all_cols, drop = FALSE])
  merged <- merged[order(merged$source, merged$variable_name), , drop = FALSE]
  list(merged = merged, n_new = nrow(new_rows))
}

source_map <- list(
  `7_A` = file.path("0_inputs", "SBA", "7_A"),
  `504` = file.path("0_inputs", "SBA", "504")
)

collected <- lapply(names(source_map), function(src) collect_source(src, source_map[[src]]))

for (obj in collected) {
  cat(sprintf("Source %s: %d files, %d rows, %d columns\\n", obj$source, length(obj$files), nrow(obj$data), ncol(obj$data)))
}

if (check_only) {
  cat("Check-only mode complete. No output file written.\\n")
  quit(save = "no", status = 0)
}

all_dict <- do.call(rbind, lapply(collected, build_dictionary))
all_dict <- all_dict[order(all_dict$source, all_dict$variable_name), ]

out_path <- file.path("0_inputs", "data_dictionary.csv")
if (file.exists(out_path) && !overwrite) {
  existing_dict <- read.csv(out_path, check.names = FALSE, stringsAsFactors = FALSE)
  merged <- merge_append_new(existing_dict, all_dict)
  if (merged$n_new == 0) {
    cat(sprintf("No new variables found. Kept existing %s unchanged.\\n", out_path))
    quit(save = "no", status = 0)
  }
  write.csv(merged$merged, out_path, row.names = FALSE, na = "")
  cat(sprintf("Appended %d new variable rows to %s (now %d rows, %d columns).\\n",
              merged$n_new, out_path, nrow(merged$merged), ncol(merged$merged)))
  quit(save = "no", status = 0)
}

write.csv(all_dict, out_path, row.names = FALSE, na = "")
cat(sprintf("Wrote %s with %d rows and %d columns.\\n", out_path, nrow(all_dict), ncol(all_dict)))
