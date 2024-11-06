#vocab-network-ohdsi.R

# andy south 2024-10-30
# to make a plot requested by Patrick Ryan of relationships between vocabs
# for the OHDSI yearbook 2025

# nodesize number of concepts in vocab
# connections between vocabs that have inter-vocab connections
# will probably need to modify omop_graph() so that it can accept
# different column names, and use existing ones as default

## potential stretch goals
# width of edges set by number of relationships
# ability to filter which relationships, e.g. just 'maps to'

vocabrships <- omop_concept_relationship() |>
               left_join(omop_concept(),by=c(concept_id_1="concept_id")) |>
               count(vocabulary_id,sort=TRUE) |>
               collect()

# I could calculate in a for loop
# for (id1 in concept_id_1)

# but still not quite sure what I want to end up with ...
# maybe I want
# vocab1 nconcepts vocab2 nrshipsbw
# will be multiple rows of vocab1 & nconcepts will be same for each & repeated

# function to count all connected vocabs for one vocab (v1)
count_inter_vocabrships <- function (v1) {

  omop_concept_relationship() |>
    # join on vocab_id for concept1
    left_join(select(omop_concept(),vocabulary_id), by=c(concept_id_1="concept_id")) |>
    rename(vocabulary_id_1=vocabulary_id) |>
    # filter just one of concept1 (passed in arg)
    filter(vocabulary_id_1 == v1) |>
    # join on vocab_id for concept1
    left_join(select(omop_concept(),vocabulary_id), by=c(concept_id_2="concept_id")) |>
    rename(vocabulary_id_2=vocabulary_id) |>

    count(vocabulary_id,sort=TRUE) |>
    collect()

}

