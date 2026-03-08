#///////////////////////////////////////////////////////////////////////////////
#----                    Combine                   ----
# File name:  SBA_7(A)_504_select_combine
# Author:     Inder Majumdar
# Created:    2026-03-08
# Purpose:    Select variables with above 90% completenss , 7(A) data, then Combine SBA 7(A) Years into one RDS for further matching
#///////////////////////////////////////////////////////////////////////////////

# -----------------------------
# 0) Setup and configuration
# -----------------------------

library('tidyverse')

# Relative paths from repository root
data_dictionary_path <- file.path('0_inputs', 'data_dictionary.csv')
loans_dir <- file.path('0_inputs', 'SBA', '7_A')
output_path <- file.path('2_processed_data', 'SBA7A_combined.rds')

## Data Dictionary
datadict <- read_csv(data_dictionary_path, show_col_types = FALSE)

## 7(A) Data
loan_files <- list.files(
  path = loans_dir,
  pattern = '\\.csv$',
  full.names = TRUE
) |> sort()

if (length(loan_files) == 0) {
  stop('No 7(A) CSV files found in 0_inputs/SBA/7_A')
}

loans <- loan_files |>
  map_dfr(~ read_csv(
    .x,
    col_types = cols(.default = col_character()),
    show_col_types = FALSE
  ))


# -----------------------------
# 1) Feature Selection 
# -----------------------------

## Keep columns that are above 90% filled, in 7A Data

datadict |>
  filter(source == '7_A', percent_filled > 90) |>
  select(variable_name) -> keepcols

cols <- keepcols$variable_name

loans |>
  select(all_of(cols)) -> out


# -----------------------------
# 2) Save processed data
# -----------------------------

saveRDS(out, output_path)
