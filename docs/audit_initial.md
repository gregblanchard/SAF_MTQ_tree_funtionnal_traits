# Audit initial des fichiers reçus

Les classeurs sources ont été copiés tels quels dans `data/raw/`. Aucun classeur source n'a été modifié.

## Structure apparente

- `DATA_GROWTH.xlsx` contient 276 lignes de données et 23 noms d'espèces. Le chercheur précise qu'il y a un bloc par espèce, 12 arbres par bloc ; dans les codes, A/B/C indiquent les lignes et 1–4 les colonnes d'arbres. La structure attendue pour une espèce est donc une grille de 3 × 4 arbres, et non trois blocs. Quinze espèces sont couvertes par les données de traits et de bois ; le fichier de croissance contient huit espèces supplémentaires dont le statut dans l'article reste à préciser.
- Quatre codes `Lh-B1` à `Lh-B4` apparaissent chacun deux fois dans la croissance, avec des mesures différentes. Pour `Lonchocarpus heptaphylus`, il y a 12 lignes mais seulement 8 positions distinctes. Il faut retrouver les identifiants individuels ou déterminer si ces lignes sont des erreurs de code avant d'analyser cette espèce.
- `WD_032026.xlsx` comprend 42 arbres pour 15 espèces. Deux espèces ont moins de trois individus mesurés (Guazuma : 2 ; Pimenta : 1).
- `LEAF_TRAITS.xlsx` contient 330 mesures de feuilles, généralement cinq feuilles par arbre. Une partie correspond aux 15 espèces focales ; le fichier inclut aussi des codes de Gliricidia et des groupes Banabio / Gliceridia Aubery qui ne se raccordent pas aux codes de croissance.
- `LEAF_ISOTOPY.xlsx` comprend 57 échantillons avec δ13C et δ15N. Les deux isotopes sont bien présents.
- `SOIL_CN.xlsx` comprend 48 lignes, et `BULK_DENSITY.xlsx` 47 codes. Les identifiants se recouvrent presque entièrement.
- `Litterfall.xlsx` est en format large avec dates en colonnes, annotations mêlées aux mesures et deux séries de lignes portant les mêmes codes d'espèces. Les lignes pourraient représenter des répétitions de pièges ou d'arbres, mais leur identité n'est pas indiquée.

## Implications du plan d'échantillonnage

Il y a un seul bloc spatial par espèce. Les 12 arbres sont des sous-échantillons de ce bloc, pas 12 répétitions indépendantes de l'effet espèce. Toute différence entre espèces est donc aussi potentiellement une différence entre blocs/emplacements. Pour une réponse mesurée au niveau du bloc, l'effectif est le nombre d'espèces/blocs (15 pour le jeu focal), et l'effet espèce ne peut pas être séparé de l'effet bloc. Pour les réponses par arbre, les arbres peuvent informer les relations intra-bloc et intra-espèce ; les modèles doivent tenir compte de leur regroupement par bloc et la portée des conclusions doit rester prudente. Les positions ligne/colonne A–C × 1–4 peuvent aider à examiner des gradients spatiaux, mais ne créent pas de répétition de bloc.

## Première exploration des traits

Une ACP exploratoire a été calculée sur les moyennes par espèce de cinq variables : densité du bois, chlorophylle moyenne, épaisseur foliaire, LDMC et SLA. Les 15 espèces présentes dans les fichiers de feuilles et de bois sont représentées. Les deux premiers axes expliquent environ 80,4 % de la variance (PC1 : 59,4 % ; PC2 : 21,0 %). Cette ordination est provisoire : elle ne comprend pas encore les traits de litière, les isotopes, les traits racinaires ni les fonctions de l'écosystème. Le SLA et le LDMC sont des variables mathématiquement liées aux masses surfaciques/hydriques et leur redondance devra être examinée.

Les moyennes de densité du bois sont fondées sur seulement 1 à 3 arbres par espèce. Les valeurs foliaires sont d'abord moyennées sur les feuilles, puis sur les arbres disponibles par espèce. Cette ACP décrit donc une première structure interspécifique, avec une incertitude d'échantillonnage qui n'est pas représentée sur le graphique.

## Points à résoudre avant les modèles

1. Les identifiants codent les positions ligne A–C et colonne 1–4 dans chaque bloc-espèce. Comme il n'y a qu'un bloc par espèce, l'effet espèce est confondu avec l'emplacement du bloc.
2. Préciser si les huit espèces supplémentaires du classeur de croissance entrent dans l'article ou sont hors du jeu focal de 15 espèces.
3. Clarifier les quatre identifiants dupliqués de Lonchocarpus heptaphylus.
4. Confirmer l'orthographe taxonomique et les correspondances de codes entre fichiers : plusieurs noms varient légèrement (par exemple Cordia alliodora / aliodora, Lonchocarpus puntatus / punctatus, Ochroma pyramidales / pyramidale, Trema micrantha / micranthum).
5. Vérifier les unités et valeurs extrêmes des traits foliaires, ainsi que les 28 valeurs manquantes des colonnes d'azote et de carbone foliaires.
6. Identifier le poids/unité et la structure des deux séries de litterfall, puis interpréter les dates et notes de collecte.
7. Pour estimer une fraction d'azote dérivée de l'atmosphère, les δ15N seuls ne suffisent pas : références non fixatrices et protocole de calcul doivent être documentés. Les δ13C du sol et les concentrations C/N ne donnent pas directement un stock de carbone sans profondeur, densité apparente et éléments grossiers.
8. Harmoniser les méthodes de croissance : le diamètre est parfois mesuré à la base, parfois sous forme de circonférence à la base ou à 130 cm. Ne pas comparer les colonnes D1-D5 sans tenir compte des dates, unités et méthodes.
