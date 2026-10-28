# Traits fonctionnels et fonctions écosystémiques en agroforesterie

Projet R pour organiser les données d'une parcelle agroforestière et préparer l'analyse de traits foliaires, de bois, d'isotopes, de croissance, de sol et de litière.

## Démarrage

1. Ouvrir `traits_agroforesterie.Rproj` dans RStudio.
2. Les sept classeurs reçus sont déjà copiés dans `data/raw/`. Ajouter ici les nouveaux fichiers sans modifier les originaux.
3. Installer une fois les dépendances : `install.packages(c("here", "readr", "readxl", "dplyr", "purrr", "tibble", "janitor", "stringr", "tidyr", "ggplot2"))`.
4. Exécuter `scripts/00_inventaire_donnees.R` pour actualiser l'inventaire des feuilles, colonnes, valeurs manquantes et doublons exacts.
5. Exécuter `scripts/01_exploration.R` pour reproduire l'agrégation exploratoire feuilles → arbres → espèces et l'ACP préliminaire sur les traits foliaires et la densité du bois.
6. Les premières sorties déjà produites sont dans `outputs/tables/`, `outputs/figures/` et `docs/audit_initial.md`.

Les scripts ne modifient pas les classeurs bruts. Ils produisent des tables dérivées reproductibles. Les identifiants, taxons, unités et répétitions doivent être validés avant d'ajuster les modèles reliant traits et fonctions écosystémiques.

## Structure

- `data/raw/` : classeurs originaux reçus, conservés tels quels.
- `data/processed/` : données préparées après validation du schéma.
- `scripts/` : inventaire et analyses reproductibles.
- `outputs/tables/` et `outputs/figures/` : résultats dérivés.
- `docs/` : audit initial, dictionnaire et décisions de préparation.

## Portée de l'analyse

Le plan confirmé est un bloc par espèce, avec 12 arbres dans chaque bloc. Les lettres A/B/C et les chiffres 1–4 désignent les lignes et colonnes de la grille d'arbres. Les répétitions de feuilles sont agrégées au niveau de l'arbre. Les arbres d'un bloc ne sont pas des répétitions indépendantes de l'effet espèce : espèce et emplacement du bloc sont confondus. Une seule parcelle et un seul bloc par espèce limitent les conclusions à ce site et à ce dispositif.

L'ACP initiale utilise cinq variables et 15 moyennes d'espèces. Elle est descriptive et ne comprend pas encore les traits de litière, les isotopes ou les mesures de croissance, de sol et de couvert végétal.

## R Markdown et Git

- `article_traits_agroforesterie.Rmd` est le document de travail de l'article. L'ouvrir dans RStudio et cliquer sur **Knit** après installation de `rmarkdown` et des packages indiqués dans le document.
- Le dépôt Git local suit les scripts, le R Markdown et la documentation. Les classeurs bruts et les sorties générées restent dans le dossier local et sont exclus de Git par `.gitignore`.
- Le dépôt est local, sans dépôt distant configuré. Les prochains changements peuvent être versionnés avec les commandes Git habituelles depuis RStudio.
