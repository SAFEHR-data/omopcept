#2024-ohdsi-global.R

# try to do some new plots for ohdsi-global
# showing how visualisation can be useful

# would be good to show a hierarchy
# with multiple levels
# that is clinically interesting or useful

## example from Anna

#get one concept
gm <- omop_names("Glucose measurement", exact=TRUE)

#get relations
gmr1 <- omop_relations(gm$concept_id, nsteps = 1) #47


# maybe try an RxNorm defined hierarchy ?
# https://www.nlm.nih.gov/research/umls/rxnorm/overview.html

# 6 fluoxetine concepts before filtering to 1 RxNorm
fx <- omop_names("fluoxetine", exact=TRUE, v="RxNorm")

fxr1 <- omop_relations(fx$concept_id, nsteps = 1) #230 nice !

# check relationships
freq_fxr1 <- fxr1 |> count(relationship_id, sort=TRUE)
# 1 Has brand name        156
# 2 RxNorm ing of          52
# 3 Mapped from            15
# 4 RxNorm - ATC pr lat     2
# 5 RxNorm - SNOMED eq      2
# 6 Has form                1
# 7 Is                      1
# 8 RxNorm - Source eq      1
# 9 Value mapped from       1

# also concept_class_id has RxNorm term types which may be better to use for colour
freqcc <- fxr1 |> count(concept_class_id, sort=TRUE)

caption <- ""

omop_graph(fxr1,
           nodecolourvar = "relationship_id",
           #nodecolourvar = "concept_class_id", #initial issues too many colours
           canvas="A2",
           graphtitle = "OMOP Fluoxetine Nation",
           titletxtsize = 40,
           backcolour="white",
           titlecolour = "darkred",
           edgecolour="yellow2",
           edgewidth = 0.3,
           nodetxtsize=4,
           caption=caption,
           captiontxtsize=12,
           captionjust="centre")

# be good to get multiple levels in hierarchy
# but will probably need to filter by relationship_id
# r2 takes a good few minutes
fxr2 <- omop_relations(fx$concept_id, nsteps = 2) #3818 rows

freqrfxr2 <- fxr2 |> count(relationship_id, sort=TRUE)
freqvfxr2 <- fxr2 |> count(vocabulary_id, sort=TRUE)

# 1 RxNorm Extension  2841
# 2 RxNorm             794
# 3 SNOMED             127
# 4 ATC                 23
# 5 dm+d                18
# 6 UK Biobank          15

# try restricting to RxNorm, i.e. not Extension
fxr2rxn <- fxr2 |> filter(vocabulary_id %in% c("RxNorm"))

freqcc <- fxr2rxn |> count(concept_class_id, sort=TRUE)
# 1 Ingredient             370
# 2 Clinical Drug          128
# 3 Clinical Drug Form      52
# 4 Branded Drug Comp       45
# 5 Clinical Drug Comp      41
# 6 Clinical Dose Group     29
# 7 Branded Dose Group      28
# 8 Branded Drug            27
# 9 Branded Drug Form       24
# 10 Brand Name              15
# 11 Dose Form               14
# 12 Precise Ingredient      12
# 13 Dose Form Group          6
# 14 Multiple Ingredients     3

#also I'm probably going both up&down hierarchy
freqr <- fxr2rxn |> count(relationship_id, sort=TRUE)

# 1 Brand name of          234
# 2 ATC - RxNorm sec up    131
# 3 RxNorm inverse is a    113
# 4 RxNorm ing of           66
# 5 RxNorm has ing          55
# 6 Has tradename           50
# 7 Constitutes             32
# 8 Maps to                 18
# 9 RxNorm is a             17
# 10 RxNorm has dose form    14
# 11 Has brand name          12
# 12 ATC - RxNorm             9
# 13 Has precise ing          7
# 14 Mapped from              7
# 15 Precise ing of           7
# 16 Has dose form group      6
# 17 SNOMED - RxNorm eq       4
# 18 Concept replaces         3
# 19 ATC - RxNorm pr lat      2
# 20 Has form                 2
# 21 Concept replaced by      1
# 22 Form of                  1
# 23 Is                       1
# 24 Maps to value            1
# 25 Source - RxNorm eq       1

#filter out ATC
fxr2rxn_noatc <- fxr2rxn |> filter(!str_detect(relationship_id,"ATC"))
#then what concept_classes remain ? want 8 or less for colours
fxr2rxn_noatc |> count(concept_class_id, sort=TRUE)

#arrange by cc in RStudio to eyeball

# Dose groups look boring, can exclude 3 ccs
fxr2rxn_noatc_nodose <- fxr2rxn_noatc |> filter(!str_detect(concept_class_id,"Dose"))

fxr2rxn_noatc_nodose |> count(concept_class_id, sort=TRUE)
#down to 10
# 1 Ingredient             237
# 2 Clinical Drug          128
# 3 Branded Drug Comp       45
# 4 Clinical Drug Form      43
# 5 Clinical Drug Comp      41
# 6 Branded Drug            27
# 7 Branded Drug Form       24
# 8 Brand Name              15
# 9 Precise Ingredient      12
# 10 Multiple Ingredients     3

# remove last 2
# this is pretty good
f2 <- fxr2rxn_noatc_nodose |>
  filter(!concept_class_id %in% c("Precise Ingredient","Multiple Ingredients"))


#caption <- ""
caption <- "Relations of Fluoxetine in RxNorm. Plot made by Andy South using R, OMOP, ggplot2 & omopcept."

#pretty good
omop_graph(f2,
           ggrlayout="graphopt",
           nodecolourvar = "concept_class_id",
           canvas="A2",
           graphtitle = "OMOP RxNorm Fluoxetine Nation",
           titletxtsize = 40,
           backcolour="white",
           titlecolour = "darkred",
           edgecolour="lawngreen",
           edgewidth = 0.3,
           nodetxtsize=3,
           caption=caption,
           captiontxtsize=12,
           captionjust="centre",
           filenamecustom="ohdsi-global-24-poster-fluoxetine")

#try tree
#doesnt work well, most labels can't be plotted due to overlap
#(that is advantage of graphopt)
omop_graph(f2,
           ggrlayout="tree",
           nodecolourvar = "concept_class_id",
           canvas="A2",
           graphtitle = "OMOP RxNorm Fluoxetine Nation",
           titletxtsize = 40,
           backcolour="white",
           titlecolour = "darkred",
           edgecolour="lawngreen",
           edgewidth = 0.3,
           nodetxtsize=3,
           caption=caption,
           captiontxtsize=12,
           captionjust="centre",
           filenamecustom="ohdsi-global-24-poster-fluoxetine-tree")

# 2024-10-24 thursday OHDSI global
# have a look at Cancer Modifiers
cm <- omop_names("",v="Cancer Modifier")
#returning 6043 concepts
omopfreqdomain(cm)
#1 Measurement  6028
#2 Observation    15

omopfreqconceptclass(cm)

# 1 Staging/Grading     3281
# 2 Metastasis           579
# 3 Extension/Invasion   545
# 4 Topography           518
# 5 Histopattern         444
# 6 Margin               433
# 7 Nodes                192
# 8 Dimension             29
# 9 Morph Abnormality     15
# 10 Qualifier Value        7

cmtopo <- cm |> filter(concept_class_id=="Topography")
cmnodes <- cm |> filter(concept_class_id=="Nodes") #192

#can I filter all these cmnodes from relationship table ?
#YES :-), vquick 648 rows
cmnodes_r <- omop_concept_relationship() |>
  filter(concept_id_1 %in% cmnodes$concept_id) |>
  collect()


omop_graph(cmnodes_r)
