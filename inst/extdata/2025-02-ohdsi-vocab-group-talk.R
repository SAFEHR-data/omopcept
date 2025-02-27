#2025-02-ohdsi-vocab-group-talk.R

# go back to using omop_relations properly
# start from a granular drug & go up the hierarchy

#4 concepts
vin <- omop_names("vincristine", exact=TRUE)
vinr <- omop_names("vincristine", exact=TRUE, v="RxNorm")

vinr_r1 <- omop_relations(vinr$concept_id, nsteps = 1)

omopfreqrelationship(vinr_r1)
# relationship_id         n
# 1 Cytotox chemo RX of   301
# 2 Has brand name         21
# 3 RxNorm ing of          18
# 4 Mapped from            14
# 5 Is a                    7

va <- omop_names("Vinca alkaloid", exact=TRUE, v="HemOnc")

#375
va_r1 <- omop_relations(va$concept_id, nsteps = 1)
omopfreqrelationship(va_r1)

va_r2sel <- omop_relations(va$concept_id, nsteps = 2, r=c('Subsumes','Has brand name'))

omop_graph(va_r2sel,
           nodecolourvar = "vocabulary_id",
           nodetxtsize = 6) #default 9

#vincristine & vinblastine
va_r2sel |> filter(str_to_lower(concept_name_1) %in% c("vinca alkaloid","vincristine","vinblastine")) |>
            omop_graph(nodecolourvar = "vocabulary_id",
                       nodetxtsize = 6) #default 9
#vincristine alone
va_r2sel |> filter(str_to_lower(concept_name_1) %in% c("vinca alkaloid","vincristine")) |>
  omop_graph(nodecolourvar = "vocabulary_id",
             nodetxtsize = 6) #default 9
#colour by relationship (but tricky cos concepts have multiple rships)
va_r2sel |> filter(str_to_lower(concept_name_1) %in% c("vinca alkaloid","vincristine")) |>
  omop_graph(nodecolourvar = "relationship_id",
             nodetxtsize = 6) #default 9

#can I go upwards from a Hemonc chemo regimen
rchop <- omop_names("R-CHOP", exact=TRUE, v="HemOnc")

rchop_r1 <- omop_relations(rchop$concept_id, nsteps = 1)

omopfreqrelationship(rchop_r1)

rchop_r1 |> filter(vocabulary_id=="HemOnc") |>
  omop_graph(nodecolourvar = "relationship_id",
             nodetxtsize = 6) #default 9

rchop_r1 |> filter(relationship_id %in% c("Has accepted use","Has cytotoxic chemo","Has steroid tx",
                                          "Has supportive med","Has local therapy","Has targeted therapy")) |>
  omop_graph(graphtitle = "HemOnc Regimen example",
             nodecolourvar = "relationship_id",
             nodetxtsize = 8) #default 9

#try starting with an ATC level5 & getting all relations in the ATC hierarchy

vina <- omop_names("vincristine; parenteral",exact=TRUE)

vina_rh3 <- omop_relations(vina$concept_id,v=("ATC"),nsteps=3)

vina_rh3 |> omop_graph(graphtitle = "ATC hierarchy example",
           nodecolourvar = "concept_class_id",
           nodetxtsize = 8) #default 9

vina_rh4 <- omop_relations(vina$concept_id,v=("ATC"),nsteps=4)

vina_rh4 |> omop_graph(graphtitle = "ATC hierarchy example",
                       nodecolourvar = "concept_class_id",
                       nodetxtsize = 8) #default 9

alk <- omop_names("PLANT ALKALOIDS AND OTHER NATURAL PRODUCTS")

alk_rh3 <- omop_relations(alk$concept_id,v=("ATC"),r="Subsumes",nsteps=3)

#plant alkaloid tree
alk_rh3 |> omop_graph(graphtitle = "ATC plant alkaloid tree",
                       nodecolourvar = "concept_class_id",
                       nodetxtsize = 8) #default 9
alk_rh3 |> omop_graph(graphtitle = "ATC plant alkaloid tree",
                      ggrlayout = "tree",
                      nodecolourvar = "concept_class_id",
                      nodetxtangle = 90,
                      nodetxtsize = 7) #default 9



# looking at atc hierarchy
#atc_descendants <- omop_concept_ancestor() |>
atc1 <- omop_concept_relationship() |>
  omop_join_name(namefull = "concept_id_1", columns = c("concept_name","vocabulary_id","concept_class_id")) |>
  rename(concept_class_id_1 = concept_class_id,
         vocabulary_id_1 = vocabulary_id) |>
  omop_join_name(namefull = "concept_id_2", columns = c("concept_name","vocabulary_id","concept_class_id")) |>
  rename(concept_class_id_2 = concept_class_id,
         vocabulary_id_2 = vocabulary_id) |>
  #filter(vocabulary_id %in% c("RxNorm","RxNorm Extension")) |>
  #head(100000) |>
  filter(stringr::str_starts(concept_class_id_1,"ATC")) |>
  collect()

atc1_1 <- atc1 |> filter(concept_class_id_1=="ATC 1st")
atc1_2 <- atc1 |> filter(concept_class_id_1=="ATC 2nd")

