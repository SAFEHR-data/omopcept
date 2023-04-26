## code to prepare `DATASET` dataset goes here
## initially copied from omop_es preprocess_metadata.r

library(here)
library(readr)
library(tidyverse)

pathdata <- here::here("inst","extdata")

concept <- read_tsv(here::here(pathdata,"CONCEPT.csv"), col_types = "icccccciic") |>
  #unselect unecessary
  select(-valid_start_date, -valid_end_date, -invalid_reason) #|>
  #filter(!(vocabulary_id %in% c("NDC","SPL","OSM","ICD10PCS","ICD10CM","ICD9CM"))) #|>
  #write_result("concept.parquet")

#try saving whole of concept as rda
#v6.7 million rows, 61 MB, tok ~5mins to save
save(concept,file=here(pathdata,"concept_all.rda"),compress="xz")

vocab_freqs <- concept |> count(vocabulary_id, sort=TRUE)

# vocabulary_id              n
# 1 RxNorm Extension     2110429
# 2 NDC                  1138132
# 3 SNOMED               1054935
# 4 SPL                   641455
# 5 dm+d                  387449
# 6 RxNorm                304866
# 7 LOINC                 265076
# 8 OSM                   203339
# 9 ICD10PCS              194981
# 10 OMOP Genomic          120991
# 11 Read                  108945
# 12 ICD10CM                98583
# 13 UK Biobank             19337
# 14 ICD9CM                 17564
# 15 ICD10                  16519
# 16 HCPCS                  11269
# 17 OXMIS                   8118
# 18 HemOnc                  8028
# 19 ATC                     6740
# 20 Cancer Modifier         6043
# 21 ICD9Proc                4657
# 22 OMOP Extension          1240
# 23 UCUM                    1118
# 24 CDM                     1045

#GitHub max file size 100MB, warning after 50MB.
#If you attempt to add or update a file that is larger than 50 MB, you will receive a warning.
#The changes will still push to your repos, but you can consider removing the commit
#to minimize performance impact.

# as a first test could filter SNOMED,LOINC and Cancer Modifier vocabs
# only 13 MB
concept <- read_tsv(here::here(pathdata,"CONCEPT.csv"), col_types = "icccccciic") |>
  #unselect unecessary
  select(-valid_start_date, -valid_end_date, -invalid_reason) |>
  filter(vocabulary_id %in% c("SNOMED","LOINC","Cancer Modifier"))

concept |>  save(file=here(pathdata,"concept_slcm.rda"),compress="xz")
#usethis::use_data(DATASET, overwrite = TRUE)

# Maybe I want to create an SQLIte database to make it smaller ?
# e.g. by coding the domains & vocabs

# OHDSI Eunomia package contains an sqlite database that is compressed with xz
# it has both cdm data and a subset of vocabs

# To create a new SQLite database, you simply supply the filename to dbConnect():

library(DBI)
mydb <- dbConnect(RSQLite::SQLite(), here(pathdata,"concept.sqlite"))
dbWriteTable(mydb, "concept", concept)

#try reducing size by replacing chars with int. indices
#combining as.factor & as.numeric converts strings to integers
#would need to save indices in another table
#MUST be a better way of doing this
concept_n <- concept |>
  mutate(domain_id=as.factor(domain_id)) |>
  mutate(domain_id=as.integer(domain_id))

mydb2 <- dbConnect(RSQLite::SQLite(), here(pathdata,"concept_n.sqlite"))
dbWriteTable(mydb2, "concept", concept_n)
dbDisconnect(mydb2)

#to vacuum out unused space after reducing tables
DBI::dbExecute(mydb, "VACUUM;")

dbDisconnect(mydb)


# read_athena_data("CONCEPT_RELATIONSHIP.csv",col_types = "iiciic") |>
#   semi_join(concepts, by = c("concept_id_1" = "concept_id")) |>
#   semi_join(concepts, by = c("concept_id_2" = "concept_id")) |>
#   convert_valid_dates() |>
#   write_result("concept_relationship.parquet")
#
# read_athena_data("CONCEPT_ANCESTOR.csv", col_types = "iiiicc") |>
#   semi_join(concepts, by = c("ancestor_concept_id" = "concept_id")) |>
#   semi_join(concepts, by = c("descendant_concept_id" = "concept_id")) |>
#   write_result("concept_ancestor.parquet")
#
# read_athena_data("DRUG_STRENGTH.csv", col_types = "iininininiic") |>
#   semi_join(concepts, by = c("drug_concept_id" = "concept_id")) |>
#   convert_valid_dates() |>
#   write_result("drug_strength.parquet")

#usethis::use_data(DATASET, overwrite = TRUE)


