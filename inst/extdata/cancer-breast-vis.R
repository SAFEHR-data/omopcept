# cancer-breast-vis.R
# andy south 2023-11-23

# initially copied from myeloma-concepts-vis.R
# find/replace 'myeloma' with 'breast cancer'

# try visualising myeloma omop concepts using omopcept
# TODO could I make this into an rmarkdown template
# so that users can give it a search term and it outputs
# a bunch of standard tables & figures
# or could even be a shiny dashboard

library(here)
library(tidyverse)

#remotes::install_github("andysouth/omopcept")
library(omopcept)

#101 myeloma concepts
concepts <- omop_names("breast cancer")

concepts %>% count(vocabulary_id, sort=TRUE)

# vocabulary_id     n
# 1 LOINC             137
# 2 SNOMED             49
# 3 HCPCS              24
# 4 Read               13
# 5 HemOnc             10
# 6 OncoTree            5
# 7 UK Biobank          4
# 8 Cancer Modifier     1
# 9 OMOP Genomic        1

#49
concepts_sno <- concepts |> filter(vocabulary_id %in% c("SNOMED"))

#10
conditions_sno <- concepts_sno |> filter(domain_id %in% c("Condition"))

labc <- omop_names("Locally advanced breast cancer")

labc$concept_id

# END
# TODO see if anything after here is useful for breast

freq_rs <- concepts_sil_rel1 |> count(relationship_id, sort=TRUE)
#subsumes 14k
#Is a 272

concepts_sil_rel1_isa <- concepts_sil_rel1 |>  filter(relationship_id=="Is a")

omop_graph(concepts_sil_rel1_isa)

omop_graph(concepts_sil_rel1_isa, plot=FALSE, graphtitle=NULL, legendcm=1, node_txtsize=8)

concepts_sil_rel1_isa |>
  filter(!domain_id %in% c("Spec Anatomic Site","Meas Value","Metadata")) |>
  omop_graph(plot=FALSE, graphtitle=NULL, legendcm=1, node_txtsize=8, filenameroot="myl1")

# make the plot a bit bigger to be able to see all breast cancer concepts
concepts_sil_rel1_isa |>
  filter(!domain_id %in% c("Spec Anatomic Site","Meas Value","Metadata")) |>
  omop_graph(plot=FALSE, graphtitle=NULL, legendcm=1, node_txtsize=8, filenameroot="myl1",
             width=70, height=40)

concepts_sil_rel1_isa |>
  filter(!domain_id %in% c("Spec Anatomic Site","Meas Value","Metadata")) |>
  omop_graph(plot=FALSE, graphtitle=NULL, legendcm=1, node_txtsize=8, filenameroot="myl1",
             width=100, height=60)

# try with just Condition & Observation (partly to show sentiment measures)
concepts_sil_rel1_isa |>
  filter(domain_id %in% c("Observation","Condition")) |>
  omop_graph(plot=FALSE, graphtitle=NULL, legendcm=1,
             node_txtsize=8, filenameroot="myl_con_obs",
             width=100, height=60)
