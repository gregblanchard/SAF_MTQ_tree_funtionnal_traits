# Inventaire initial des données : aucune modification des fichiers sources.
# Formats pris en charge : CSV, TSV, TXT délimité, XLSX et XLS.

packages <- c("here", "readr", "readxl", "dplyr", "purrr", "tibble", "janitor", "stringr")
missing <- packages[!vapply(packages, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) {
  stop("Installer d'abord les packages manquants : ", paste(missing, collapse = ", "))
}

library(dplyr)
library(purrr)
library(tibble)

raw_dir <- here::here("data", "raw")
out_dir <- here::here("outputs", "tables")
log_dir <- here::here("outputs")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(log_dir, recursive = TRUE, showWarnings = FALSE)

files <- list.files(raw_dir, recursive = TRUE, full.names = TRUE,
                    pattern = "\\.(csv|tsv|txt|xlsx|xls)$", ignore.case = TRUE)
if (!length(files)) {
  stop("Aucun fichier tabulaire trouvé dans data/raw/. Ajoute les fichiers sources puis relance.")
}

read_delimited <- function(path) {
  ext <- tolower(tools::file_ext(path))
  if (ext == "tsv") return(readr::read_tsv(path, show_col_types = FALSE, name_repair = "minimal"))
  # Détection du séparateur (virgule, point-virgule, tabulation, etc.).
  lines <- readr::read_lines(path, n_max = 100)
  delim <- readr::guess_delim(lines)
  readr::read_delim(path, delim = delim, show_col_types = FALSE, name_repair = "minimal",
                    guess_max = 10000, progress = FALSE)
}

read_one <- function(path) {
  ext <- tolower(tools::file_ext(path))
  if (ext %in% c("xlsx", "xls")) {
    sheets <- readxl::excel_sheets(path)
    return(set_names(map(sheets, ~ readxl::read_excel(path, sheet = .x, .name_repair = "minimal")), sheets))
  }
  set_names(list(read_delimited(path)), "data")
}

safe_read <- purrr::safely(read_one)
imports <- purrr::map(files, safe_read)
names(imports) <- files

file_inventory <- purrr::imap_dfr(imports, function(result, file_name) {
  path <- file_name
  file_name <- basename(file_name)
  if (!is.null(result$error)) {
    return(tibble(file = file_name, path = path, sheet = NA_character_,
                  n_rows = NA_integer_, n_columns = NA_integer_,
                  read_error = conditionMessage(result$error)))
  }
  purrr::imap_dfr(result$result, function(dat, sheet_name) {
    tibble(file = basename(file_name), path = file_name, sheet = sheet_name,
           n_rows = nrow(dat), n_columns = ncol(dat), read_error = NA_character_)
  })
})

column_inventory <- purrr::imap_dfr(imports, function(result, file_name) {
  if (!is.null(result$error)) return(tibble())
  purrr::imap_dfr(result$result, function(dat, sheet_name) {
    tibble(file = basename(file_name), sheet = sheet_name,
           column_position = seq_along(dat), column_name = names(dat),
           class = map_chr(dat, ~ paste(class(.x), collapse = "/")),
           n_missing = map_int(dat, ~ sum(is.na(.x))),
           pct_missing = if (nrow(dat) == 0) NA_real_ else 100 * n_missing / nrow(dat),
           n_distinct_nonmissing = map_int(dat, ~ dplyr::n_distinct(.x, na.rm = TRUE)))
  })
})

readr::write_csv(file_inventory, file.path(out_dir, "inventaire_fichiers.csv"), na = "")
readr::write_csv(column_inventory, file.path(out_dir, "inventaire_colonnes.csv"), na = "")

# Le contrôle de doublons est descriptif et porte sur les lignes entières de chaque feuille.
duplicate_inventory <- purrr::imap_dfr(imports, function(result, file_name) {
  if (!is.null(result$error)) return(tibble())
  purrr::imap_dfr(result$result, function(dat, sheet_name) {
    tibble(file = basename(file_name), sheet = sheet_name, n_rows = nrow(dat),
           n_exact_duplicate_rows = sum(duplicated(dat)))
  })
})
readr::write_csv(duplicate_inventory, file.path(out_dir, "controle_doublons_exacts.csv"), na = "")

capture.output(sessionInfo(), file = file.path(log_dir, "sessionInfo.txt"))
message("Inventaire terminé. Vérifier les fichiers dans outputs/tables/ avant toute harmonisation.")
