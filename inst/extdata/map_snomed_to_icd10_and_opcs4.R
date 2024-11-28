# map_snomed_to_icd10_and_opcs4.R

# andy south 2024-11-28
# request from Stef that users can map back from SNOMED to icd10 & opcs4

library(dplyr)
library(omopcept)

#seems opcs4 vocab not in by default
##or is it just that there are no relationships
#snomed_to_icd10_opcs4_lookup <-   omop_concept_relationship() |>

#19k rows
snomed_to_icd10_lookup <-   omop_concept_relationship() |>
  # join on vocab_id for concept1
  left_join(select(omop_concept(),concept_id,concept_name,vocabulary_id), by=c(concept_id_1="concept_id")) |>
  rename(vocabulary_id_1=vocabulary_id,
         concept_name_1=concept_name) |>
  filter(vocabulary_id_1 == "SNOMED") |>
  # join on vocab_id for concept2
  left_join(select(omop_concept(),concept_name,concept_id,vocabulary_id), by=c(concept_id_2="concept_id")) |>
  rename(vocabulary_id_2=vocabulary_id,
         concept_name_2=concept_name) |>
  filter(vocabulary_id_2 %in% c("ICD10","OPCS4")) |>
  #exclude "Value mapped from"
  filter(relationship_id == "Mapped from") |>
  #move names to front for easier view
  relocate(concept_name_1, concept_name_2, relationship_id) |>
  collect()

#before filtering of relationship_id
# snomed_to_icd10_lookup |> count(relationship_id)
# 1 Mapped from       18957
# 2 Value mapped from   293
