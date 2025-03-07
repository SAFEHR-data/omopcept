#vocab-network-ohdsi.R

# andy south 2025-01-16
# to make a plot requested by Patrick Ryan of relationships between vocabs
# for the OHDSI yearbook 2025

library(dplyr)

# nodesize number of concepts in vocab
# connections between vocabs that have inter-vocab connections

## potential stretch goals
# width of edges set by number of relationships
# ability to filter which relationships, e.g. just 'maps to'

# all relationships per vocab (not what I need)
# vocabrships <- omop_concept_relationship() |>
#                left_join(omop_concept(), by=c(concept_id_1="concept_id")) |>
#                count(vocabulary_id, sort=TRUE, name="allrelationships") |>
#                collect()

# function to count all connected vocabs for all vocabs
# ~10 secs, result ~289 rows, dependent on which vocabs downloaded from Athena
# potential to filter or count a subset of relationship types
# vocabulary_id_1, vocabulary_id_2, nrelationships, total_relationships_vocab1"
count_inter_vocabrships <- function () {

  omop_concept_relationship() |>
    # join on vocab_id for concept1
    left_join(select(omop_concept(),concept_id,vocabulary_id), by=c(concept_id_1="concept_id")) |>
    rename(vocabulary_id_1=vocabulary_id) |>
    # could filter one or more of concept1 (passed in optional arg)
    # filter(vocabulary_id_1 %in% v1) |>
    # join on vocab_id for concept2
    left_join(select(omop_concept(),concept_id,vocabulary_id), by=c(concept_id_2="concept_id")) |>
    rename(vocabulary_id_2=vocabulary_id) |>
    count(vocabulary_id_1, vocabulary_id_2, sort=FALSE, name="nrelationships") |>
    #add the total relationships per vocab1 (although may not be needed)
    collect() |>
    group_by(vocabulary_id_1) |>
      mutate(total_relationships_vocab1 = sum(nrelationships)) |>
      ungroup() |>
    arrange(vocabulary_id_1, desc(nrelationships))
}

# same as above, but divides vocabs into standard,non-standard & classification concepts
# so that each will become a separate bubble
count_inter_vocabrships_standard <- function () {

  omop_concept_relationship() |>
    # join on vocab_id for concept1
    left_join(select(omop_concept(),concept_id,vocabulary_id,standard_concept), by=c(concept_id_1="concept_id")) |>
    rename(vocabulary_id_1=vocabulary_id) |>
    rename(standard_concept_1=standard_concept) |>
    collect() |>
    mutate(standard_1 = case_match(standard_concept_1,
                                   "S"~"standard",
                                   "C"~"classification",
                                   NA~"non-standard")) |>
    mutate(vocab_standard_1=paste(vocabulary_id_1,standard_1)) |>
    mutate(vocab_s_1=paste(vocabulary_id_1,standard_concept_1)) |>
    #copying just the vocab for label (because vocabulary_id_1 is already used in omop_graph)
    mutate(vocab_only_1=vocabulary_id_1) |>
    # could filter one or more of concept1 (passed in optional arg)
    # filter(vocabulary_id_1 %in% v1) |>
    # join on vocab_id for concept2
    left_join(select(omop_concept(),concept_id,vocabulary_id,standard_concept),
              by=c(concept_id_2="concept_id"), copy=TRUE) |>
    rename(vocabulary_id_2=vocabulary_id) |>
    mutate(vocab_only_2=vocabulary_id_2) |>
    rename(standard_concept_2=standard_concept) |>
    mutate(standard_2 = case_match(standard_concept_2,
                                   "S"~"standard",
                                   "C"~"classification",
                                   NA~"non-standard")) |>
    mutate(vocab_standard_2=paste(vocabulary_id_2,standard_2)) |>
    mutate(vocab_s_2=paste(vocabulary_id_2,standard_concept_2)) |>
    #count(vocabulary_id_1, vocabulary_id_2, sort=FALSE, name="nrelationships") |>
    count(vocab_standard_1, vocab_s_1, vocab_only_1, standard_1, vocab_standard_2, vocab_s_2, vocab_only_2, standard_2, sort=FALSE, name="nrelationships") |>
    #add the total relationships per vocab1 (although may not be needed)
    #collect() |>
    group_by(vocab_standard_1) |>
    mutate(total_relationships_vocab_standard_1 = sum(nrelationships)) |>
    ungroup() |>
    arrange(vocab_standard_1, desc(nrelationships))
}

#takes ~10 secs, result ~289 rows, dependent on which vocabs downloaded from Athena
intervocab <- count_inter_vocabrships()
intervocabstandard <- count_inter_vocabrships_standard()

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

# to be able to size bubbles by num concepts (not nrelationships)
nconcepts_per_vocab <- omop_concept() |>
  count(vocabulary_id, sort=TRUE, name="nconcepts") |>
  collect()
nconcepts_per_vocab_standard <- omop_concept() |>
  collect() |>
  mutate(standard = case_match(standard_concept,
                                 "S"~"standard",
                                 "C"~"classification",
                                 NA~"non-standard")) |>
  mutate(vocab_standard=paste(vocabulary_id,standard)) |>
  count(vocab_standard, sort=TRUE, name="nconcepts") |>
  collect()

#joining on noncepts for vocab1 & 2
intervocab <- intervocab |>
  left_join(nconcepts_per_vocab, by=join_by(vocabulary_id_1==vocabulary_id)) |>
  rename(nconcepts1=nconcepts) |>
  left_join(nconcepts_per_vocab, by=join_by(vocabulary_id_2==vocabulary_id)) |>
  rename(nconcepts2=nconcepts)

intervocabstandard <- intervocabstandard |>
  left_join(nconcepts_per_vocab_standard, by=join_by(vocab_standard_1==vocab_standard)) |>
  rename(nconcepts1=nconcepts) |>
  left_join(nconcepts_per_vocab_standard, by=join_by(vocab_standard_2==vocab_standard)) |>
  rename(nconcepts2=nconcepts)


# omop_graph() now copes with plotting intervocab with names vocabulary_id_1 & 2
# can't colour by vocab yet because too many vocabs (I need to improve palette options)
# omop_graph(intervocab, nodetxtsize = 3, nodesizevar = "nrelationships", nodecolourvar = "vocabulary_id_1")

# good start but main vocabs are cramped in middle & unconnected ones around edge
omop_graph(intervocab,
           nodetxtsize = 5,
           nodesizevar = "nrelationships",
           nodesize = c(5,20),
           legendshow=FALSE)

# trying to colour by nrelationships, doesn't work well, more connected vocabs don't get coloured
# omop_graph(intervocab, nodetxtsize = 5, nodesizevar = "nrelationships", nodecolourvar =  "nrelationships", legendshow=FALSE)

# excluding vocabs that only link to themselves
# in practice they seem to lead a cramped network in centre with isolated dots on edge
intervocab |>
  #filter(nrelationships > 30) |>
  #filter(total_relationships_vocab1 > 330 ) |>
  filter(vocabulary_id_1 != vocabulary_id_2) |>
  omop_graph(nodetxtsize = 7,
             nodesizevar = "nconcepts2",
             nodesize = c(1,50),
             nodealpha = 0.7, #default 0.8
             #default palette Dark2 looks better, try later to get blue of OHDSI logo :-)
             #palettebrewer = "PRGn", #"RdBu",
             #palettedirection = -1, #fails to get strongest colour for single value
             edgecolour = "gold",
             graphtitle = "OMOP vocabulary relationships by omopcept",
             legendshow=FALSE)


# olour by standard - see above
# for some vocabs standard is consistent across whole vocab
# but in some, there are standard, non-standard & classification ids
# nconcepts_per_vocab_and_standard <- omop_concept() |>
#   count(vocabulary_id, standard_concept, sort=TRUE, name="nconcepts") |>
#   collect()
# #e.g. RxNorm has all 3
# nconcepts_per_vocab_and_standard  |> filter(vocabulary_id=="RxNorm")
# vocabulary_id standard_concept nconcepts
# 1 RxNorm        S                   152812
# 2 RxNorm        NA                  120119
# 3 RxNorm        C                    35778


#remove some vocabs that only link to themselves standard to non stand
#because they take up space & squish the other vocabs into a corner

#separate bubbles by standard, classification & NS, adding full 'standard' etc to names
intervocabstandard |>
  #filter low concept numbers to make plot clearer
  filter(nconcepts1 > 1000) |>
  filter(nrelationships > 10) |>
  rename(vocabulary_id_1=vocab_standard_1) |>
  rename(vocabulary_id_2=vocab_standard_2) |>
  filter(vocabulary_id_1 != vocabulary_id_2) |>
  omop_graph(nodecolourvar = "standard_1",
             nodetxtsize = 7,
             nodesizevar = "nconcepts2",
             nodesize = c(1,50),
             nodealpha = 0.7, #default 0.8
             #default palette Dark2 looks better, try later to get blue of OHDSI logo :-)
             #palettebrewer = "PRGn", #"RdBu",
             #palettedirection = -1, #fails to get strongest colour for single value
             edgecolour = "gold",
             graphtitle = "OMOP vocabulary relationships by omopcept",
             legendshow=TRUE)

#separate bubbles by standard, add S, C, NA to names
intervocabstandard |>
  #filter low concept numbers to make plot clearer
  filter(nconcepts1 > 5000) |>
  filter(nrelationships > 10) |>
  rename(vocabulary_id_1=vocab_s_1) |>
  rename(vocabulary_id_2=vocab_s_2) |>
  filter(vocabulary_id_1 != vocabulary_id_2) |>
  omop_graph(nodecolourvar = "standard_1",
             nodetxtsize = 7,
             nodesizevar = "nconcepts2",
             nodesize = c(1,50),
             nodealpha = 0.7, #default 0.8
             filenamecustom = "wrongatcall",
             #default palette Dark2 looks better, try later to get blue of OHDSI logo :-)
             #palettebrewer = "PRGn", #"RdBu",
             edgecolour = "gold",
             graphtitle = "OMOP vocabulary relationships by omopcept",
             legendshow=TRUE)

#separate bubbles by standard, but try setting label to just vocab name
intervocabstandard |>
  #filter low concept numbers to make plot clearer
  filter(nconcepts1 > 5000) |>
  filter(nrelationships > 10) |>
  rename(vocabulary_id_1=vocab_s_1) |>
  rename(vocabulary_id_2=vocab_s_2) |>
  filter(vocabulary_id_1 != vocabulary_id_2) |>
  omop_graph(nodecolourvar = "standard_2",
             nodetxtvar = "vocab_only_2",
             nodetxtsize = 7,
             nodesizevar = "nconcepts2",
             nodesize = c(1,50),
             nodealpha = 0.7, #default 0.8
             #default palette Dark2 looks better, try later to get blue of OHDSI logo :-)
             #palettebrewer = "PRGn", #"RdBu",
             edgecolour = "lightpink",
             graphtitle = "OMOP vocabulary relationships by omopcept",
             legendshow=TRUE)

# troubleshooting issue with colouring
# e.g. ATC NA got coloured as a C
#atcfail <- intervocabstandard |>
atcfail <- intervocabstandard |>
  #filter(vocab_only_1 %in% c("ATC","Cancer Modifier")) |>  #ooh this one has lots of problems !!
  #filter(vocab_only_1 %in% c("ATC"))
  filter(vocab_s_1 %in% c("ATC C")) |>
  #arrange(standard_2) |>
  rename(vocabulary_id_1=vocab_s_1) |>
  rename(vocabulary_id_2=vocab_s_2)
atcfail |>
  #filter(vocabulary_id_1 != vocabulary_id_2) |>
  omop_graph(nodecolourvar = "standard_2",
             nodetxtsize = 7,
             nodesizevar = "nconcepts2",
             nodesize = c(1,50),
             nodealpha = 0.7, #default 0.8
             filenamecustom = "wrongatc2",
             #default palette Dark2 looks better, try later to get blue of OHDSI logo :-)
             #palettebrewer = "PRGn", #"RdBu",
             edgecolour = "gold",
             graphtitle = "OMOP vocabulary relationships by omopcept",
             legendshow=TRUE)

# merely rearranging rows fixed the plot problem ??
# I should look at output from omop_graph_calc() which is list of nodes & edges

ne <- atcfail |> omop_graph_calc()



#TODO
##from ATCFAIL example work out what colours I want bubbles to be
###&what is going wrong ??


# TODO
# make colour palette more flexible from omop_graph() e.g. allow single colour choice
# look into edge width setting
