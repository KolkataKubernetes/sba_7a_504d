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

#Codex: Please remove hardcoded paths and replace with relative pathing

## Data Dictionary 

datadict <- read_csv('/Users/indermajumdar/Research/sba_7a_504d/0_inputs/data_dictionary.csv')

## 7(A) Data

path <- '/Users/indermajumdar/Research/sba_7a_504d/0_inputs/SBA/7_A'
loans <- tibble()

loansdir <- dir(path )

for (file in loansdir) {
  temp <- read.csv(paste(path, file, sep = "/"))
  loans <- rbind(loans, temp)
}


# -----------------------------
# 1) Feature Selection 
# -----------------------------

## Keep columns that are above 90% filled, in 7A Data

datadict |>
  filter(source == '7_A', percent_filled > 0.90) |>
  select(variable_name) -> keepcols

cols <- keepcols$variable_name

loans |>
  select(all_of(cols)) -> out


# -----------------------------
# 2) Save processed data
# -----------------------------

saveRDS(out, '/Users/indermajumdar/Research/sba_7a_504d/2_processed_data/SBA7A_combined.rds')

