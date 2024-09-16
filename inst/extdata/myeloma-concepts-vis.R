# myeloma_concepts_vis.R
# andy south 2023-11-07

# try visualising myeloma omop concepts using omopcept
# TODO could I make this into an rmarkdown template
# so that users can give it a search term and it outputs
# a bunch of standard tables & figures
# or could even be a shiny dashboard

library(here)
library(tidyverse)

#remotes::install_github("SAFEHR-data/omopcept")
library(omopcept)

#101 myeloma concepts
mylconcepts <- omop_names("myeloma")

mylconcepts %>% count(vocabulary_id, sort=TRUE)

# vocabulary_id     n
# 1 SNOMED           53
# 2 Read             16
# 3 ICD10            13
# 4 LOINC             7
# 5 HCPCS             4
# 6 OXMIS             3
# 7 UK Biobank        2
# 8 HemOnc            1
# 9 OMOP Genomic      1
# 10 OncoTree         1

#73
mylconcepts_sil <- mylconcepts |> filter(vocabulary_id %in% c("SNOMED","ICD10","LOINC"))

#1.8m !!!
mylconcepts_sil_rel1 <- omop_relations_multiple(mylconcepts_sil$concept_id)

tst <- mylconcepts_sil_rel1 |> head()

freq_rs <- mylconcepts_sil_rel1 |> count(relationship_id, sort=TRUE)
#subsumes 14k
#Is a 272

mylconcepts_sil_rel1_isa <- mylconcepts_sil_rel1 |>  filter(relationship_id=="Is a")

omop_graph(mylconcepts_sil_rel1_isa)

omop_graph(mylconcepts_sil_rel1_isa, plot=FALSE, graphtitle=NULL, legendcm=1, node_txtsize=8)

mylconcepts_sil_rel1_isa |>
  filter(!domain_id %in% c("Spec Anatomic Site","Meas Value","Metadata")) |>
  omop_graph(plot=FALSE, graphtitle=NULL, legendcm=1, node_txtsize=8, filenameroot="myl1")

# make the plot a bit bigger to be able to see all myeloma concepts
mylconcepts_sil_rel1_isa |>
  filter(!domain_id %in% c("Spec Anatomic Site","Meas Value","Metadata")) |>
  omop_graph(plot=FALSE, graphtitle=NULL, legendcm=1, node_txtsize=8, filenameroot="myl1",
             width=70, height=40)

mylconcepts_sil_rel1_isa |>
  filter(!domain_id %in% c("Spec Anatomic Site","Meas Value","Metadata")) |>
  omop_graph(plot=FALSE, graphtitle=NULL, legendcm=1, node_txtsize=8, filenameroot="myl1",
             width=100, height=60)

# try with just Condition & Observation (partly to show sentiment measures)
mylconcepts_sil_rel1_isa |>
  filter(domain_id %in% c("Observation","Condition")) |>
  omop_graph(plot=FALSE, graphtitle=NULL, legendcm=1,
             node_txtsize=8, filenameroot="myl_con_obs",
             width=100, height=60)
