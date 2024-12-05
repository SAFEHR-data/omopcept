#vocab-network-ohdsi.R

# andy south 2024-10-30
# to make a plot requested by Patrick Ryan of relationships between vocabs
# for the OHDSI yearbook 2025

library(dplyr)

# nodesize number of concepts in vocab
# connections between vocabs that have inter-vocab connections
# will probably need to modify omop_graph() so that it can accept
# different column names, and use existing ones as default

## potential stretch goals
# width of edges set by number of relationships
# ability to filter which relationships, e.g. just 'maps to'

# count number of concepts in each vocab
vocabrships <- omop_concept_relationship() |>
               left_join(omop_concept(),by=c(concept_id_1="concept_id")) |>
               count(vocabulary_id,sort=TRUE, name="allrelationships") |>
               collect()

# I could calculate in a for loop
# for (id1 in concept_id_1)

# but still not quite sure what I want to end up with ...
# maybe I want
# vocab1 nconcepts vocab2 nrshipsbw
# will be multiple rows of vocab1 & nconcepts will be same for each & repeated

# function to count all connected vocabs for all vocabs
# only takes ~10s, produces 289 rows, seems low, maybe its not doing exactly what I think ?
# potential to filter or count a subset of relationship types
count_inter_vocabrships <- function () {

  omop_concept_relationship() |>
    # join on vocab_id for concept1
    left_join(select(omop_concept(),concept_id,vocabulary_id), by=c(concept_id_1="concept_id")) |>
    rename(vocabulary_id_1=vocabulary_id) |>
    # could filter just one of concept1 (passed in arg)
    # filter(vocabulary_id_1 == v1) |>
    # join on vocab_id for concept2
    left_join(select(omop_concept(),concept_id,vocabulary_id), by=c(concept_id_2="concept_id")) |>
    rename(vocabulary_id_2=vocabulary_id) |>

    count(vocabulary_id_1, vocabulary_id_2, sort=FALSE, name="nrelationships") |>
    arrange(vocabulary_id_1, desc(nrelationships)) |>
    collect()
}

#takes ~ 10 secs, result 289 rows
intervocab <- count_inter_vocabrships()

# cool :-)
# vocabulary_id_1 vocabulary_id_2    nrelationships
# 1 ABMS            ABMS                          216
# 2 ABMS            Medicare Specialty            109
# 3 ABMS            NUCC                           92
# 4 ABMS            HES Specialty                  35
# 5 ABMS            UK Biobank                     29
# 6 ABMS            SNOMED                         25
# 7 ATC             RxNorm Extension           165075
# 8 ATC             RxNorm                      81703
# 9 ATC             ATC                         13548
# 10 ATC             SNOMED                       1794
# ...

# TODO
# 1. get omop_graph() to cope with plotting intervocab
# 2.
