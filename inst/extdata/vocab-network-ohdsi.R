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
    # DO I WANT TO FILTER OUT RSHIPS TO ITSELF
    # (in practice they can lead to isolated dots not in network)
    count(vocabulary_id_1, vocabulary_id_2, sort=FALSE, name="nrelationships") |>
    #add the total relationships per vocab1
    collect() |>
    group_by(vocabulary_id_1) |>
      mutate(total_relationships_vocab1 = sum(nrelationships)) |>
      ungroup() |>
    arrange(vocabulary_id_1, desc(nrelationships))

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

# think I want to size bubbles by the num concepts (not nrelationships)
# so far this only uses relationships
# query concept file & join on

nconcepts_per_vocab <- omop_concept() |>
  count(vocabulary_id, sort=TRUE, name="nconcepts") |>
  collect()

intervocab <- intervocab |>
  left_join(nconcepts_per_vocab, by=join_by(vocabulary_id_1==vocabulary_id))

# omop_graph() now copes with plotting intervocab with names vocabulary_id_1 & 2

#can't colour by vocab yet because too many vocabs
#omop_graph(intervocab, nodetxtsize = 3, nodesizevar = "nrelationships", nodecolourvar = "vocabulary_id_1")

#good start but main vocabs are cramped in middle & unconnected ones around edge
omop_graph(intervocab,
           nodetxtsize = 5,
           nodesizevar = "nrelationships",
           nodesize = c(5,20),
           legendshow=FALSE)
#trying to colour by nrelationships, doesn't work well, more connected vocabs don't get coloured
#omop_graph(intervocab, nodetxtsize = 5, nodesizevar = "nrelationships", nodecolourvar =  "nrelationships", legendshow=FALSE)

# excluding vocabs that only link to themselves
intervocab |>
  #filter(nrelationships > 30) |>
  #filter(total_relationships_vocab1 > 330 ) |>
  filter(vocabulary_id_1 != vocabulary_id_2) |>
  omop_graph(nodetxtsize = 7,
             nodesizevar = "nconcepts",
             nodesize = c(1,50),
             nodealpha = 0.5, #default 0.8
             #palettebrewer = "Accent",
             edgecolour = "gold",
             #edgecolour = "red3",
             #palettebrewer = "Reds",
             #palettedirection = -1, #to get strongest colour for single value
             graphtitle = "OMOP vocabulary relationships by omopcept",
             legendshow=FALSE)

# TODO

#
