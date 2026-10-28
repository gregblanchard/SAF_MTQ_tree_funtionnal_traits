# Première exploration des traits foliaires et de la densité du bois.
# Plan : un bloc par espèce, 12 arbres par bloc ; A/B/C = lignes, 1-4 = colonnes.
# Niveau d'agrégation : feuilles -> arbre -> espèce.
# L'ordination est descriptive et ne teste pas de lien causal avec un service.

packages <- c("here", "readxl", "dplyr", "tidyr", "purrr", "stringr", "ggplot2", "readr")
missing <- packages[!vapply(packages, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) stop("Installer d'abord : ", paste(missing, collapse = ", "))

library(dplyr)
library(stringr)

raw_dir <- here::here("data", "raw")
out_tables <- here::here("outputs", "tables")
out_figures <- here::here("outputs", "figures")
dir.create(out_tables, recursive = TRUE, showWarnings = FALSE)
dir.create(out_figures, recursive = TRUE, showWarnings = FALSE)

norm_id <- function(x) str_to_lower(str_replace_all(str_trim(as.character(x)), "_", "-"))

# Les codes du fichier de croissance fournissent un premier dictionnaire code court -> espèce.
growth <- readxl::read_excel(file.path(raw_dir, "DATA_GROWTH.xlsx"), sheet = "DATA")
code_species <- growth |>
  mutate(id = norm_id(code), prefix = str_extract(id, "^[^-]+"),
         row_position = str_match(id, "^[^-]+-([a-z])([0-9]+)$")[, 2],
         column_position = str_match(id, "^[^-]+-([a-z])([0-9]+)$")[, 3]) |>
  distinct(prefix, species = Espèce)

tree_positions <- growth |>
  mutate(id = norm_id(code),
         row_position = str_match(id, "^[^-]+-([a-z])([0-9]+)$")[, 2],
         column_position = str_match(id, "^[^-]+-([a-z])([0-9]+)$")[, 3]) |>
  distinct(id, species = Espèce, row_position, column_position)
readr::write_csv(tree_positions, file.path(out_tables, "positions_arbres.csv"), na = "")

leaf <- readxl::read_excel(file.path(raw_dir, "LEAF_TRAITS.xlsx"), sheet = "Leaf") |>
  mutate(id = norm_id(Code), prefix = str_extract(id, "^[^-]+")) |>
  left_join(code_species, by = "prefix")

leaf_numeric <- c("Nitrogen %", "Carbon %", "mean_chlorophyll", "leaf thickness (mm)",
                  "leaf area (cm2)", "leaf weight_fresh (g)", "leaf weight_dry (g)",
                  "LDMC (mg g-1)", "specific leaf area (cm2 g-1)")
leaf_tree <- leaf |>
  filter(!is.na(species)) |>
  group_by(id, species) |>
  summarise(across(all_of(leaf_numeric), ~ if (all(is.na(.x))) NA_real_ else mean(.x, na.rm = TRUE)),
            n_leaf_observations = n(), .groups = "drop")
readr::write_csv(leaf_tree, file.path(out_tables, "traits_foliaires_par_arbre.csv"), na = "")

wood <- readxl::read_excel(file.path(raw_dir, "WD_032026.xlsx"), sheet = "Feuille 1") |>
  mutate(id = norm_id(ind), prefix = str_extract(id, "^[^-]+")) |>
  left_join(code_species, by = "prefix") |>
  filter(!is.na(species))

leaf_species <- leaf_tree |>
  group_by(species) |>
  summarise(across(all_of(leaf_numeric), ~ if (all(is.na(.x))) NA_real_ else mean(.x, na.rm = TRUE)),
            n_leaf_trees = n_distinct(id), .groups = "drop")
wood_species <- wood |>
  group_by(species) |>
  summarise(wood_density_mean = mean(density, na.rm = TRUE),
            wood_density_sd = sd(density, na.rm = TRUE), n_wood_trees = n(), .groups = "drop")
species_traits <- inner_join(leaf_species, wood_species, by = "species")
readr::write_csv(species_traits, file.path(out_tables, "traits_par_espece_provisoire.csv"), na = "")

pca_traits <- c("wood_density_mean", "mean_chlorophyll", "leaf thickness (mm)",
                "LDMC (mg g-1)", "specific leaf area (cm2 g-1)")
pca_data <- species_traits |>
  select(species, all_of(pca_traits)) |>
  tidyr::drop_na()
pca <- prcomp(pca_data |> select(-species), center = TRUE, scale. = TRUE)
variance <- tibble::tibble(axis = paste0("PC", seq_along(pca$sdev)),
                           variance_explained = pca$sdev^2 / sum(pca$sdev^2),
                           cumulative_variance = cumsum(pca$sdev^2 / sum(pca$sdev^2)))
loadings <- as.data.frame(pca$rotation) |> tibble::rownames_to_column("trait")
scores <- as.data.frame(pca$x) |> tibble::rownames_to_column("row") |>
  mutate(species = pca_data$species) |> select(species, everything(), -row)
readr::write_csv(variance, file.path(out_tables, "pca_variance_expliquee.csv"))
readr::write_csv(loadings, file.path(out_tables, "pca_contributions_traits.csv"))
readr::write_csv(scores, file.path(out_tables, "pca_coordonnees_especes.csv"))

fig <- ggplot2::ggplot(scores, ggplot2::aes(PC1, PC2, label = species)) +
  ggplot2::geom_hline(yintercept = 0, colour = "grey85", linewidth = 0.3) +
  ggplot2::geom_vline(xintercept = 0, colour = "grey85", linewidth = 0.3) +
  ggplot2::geom_point(size = 2.4, colour = "#176B63") +
  ggplot2::geom_text(check_overlap = TRUE, nudge_y = 0.12, size = 3) +
  ggplot2::labs(x = sprintf("PC1 (%.1f%%)", 100 * variance$variance_explained[1]),
                y = sprintf("PC2 (%.1f%%)", 100 * variance$variance_explained[2]),
                title = "Espace fonctionnel préliminaire des 15 espèces",
                subtitle = "Moyennes par espèce : 4 traits foliaires et densité du bois") +
  ggplot2::theme_minimal(base_size = 11)
ggplot2::ggsave(file.path(out_figures, "espace_fonctionnel_preliminaire.png"), fig,
                width = 9, height = 6, dpi = 300)

message("Exploration descriptive terminée. Vérifier taxonomie, unités, identifiants et plan des blocs avant modèles.")
