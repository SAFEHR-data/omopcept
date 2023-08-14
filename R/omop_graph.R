#' ggraph omop hierarchy
#'
#' @param c_id single omop concept_id or exact concept_name to get ancestors of
#' @param c_ids one or more concept_id to filter by, default NULL for all
#' @param d_ids one or more domain_id to filter by, default NULL for all
#' @param v_ids one or more vocabulary_id to filter by, default NULL for all
#' @param cc_ids one or more concept_class_id to filter by, default NULL for all
#' @param standard one or more standard_concept to filter by, default NULL for all, S,C
#' @param separation levels of separation to filter by, default NULL for all
#' @param itself whether to include passed concept in returned table (min_levels_of_separation==0), default=FALSE
#' @param messages whether to print info messages, default=TRUE
#' @return a dataframe of concepts and attributes
#' @export
#' @examples
#' #TODO enable example when working
#' #ggr1 <- omop_graph(v_ids="Cancer Modifier", separation=1)
#' #omop_graph(1633308)
#' #omop_graph("Non-invasive blood pressure")
#' #omop_graph("Non-invasive blood pressure",separation=c(1,2))
#' #epoch_ance <- omop_graph("EPOCH, dose-escalated")
omop_graph <- function(c_id=NULL,
                              c_ids=NULL,
                              d_ids=NULL,
                              v_ids=NULL,
                              cc_ids=NULL,
                              standard=NULL,
                              separation=NULL,
                              itself=FALSE,
                              messages=TRUE
                           ) {

  # TODO add omop_ancestors & option to do both


  df1 <- omop_descendants( c_id=c_id,
                           c_ids=c_ids,
                           d_ids=d_ids,
                           v_ids=v_ids,
                           cc_ids=cc_ids,
                           standard=standard,
                           separation=separation,
                           itself=itself)

  #ancestor_name, concept_name, min_levels_of_separation

  dffigo <- df1 |> filter(str_detect(concept_name,"FIGO"))

  grapho <- dffigo |>
    dplyr::select(ancestor_name,
           concept_name,
           vocabulary_id,
           domain_id) |>
    dplyr::rename(from = ancestor_name,
                  to = concept_name) |>
    as_tbl_graph(nodes=dffigo)

  ggr <- ggraph(grapho, layout='graphopt') +
  ggr <- ggraph(grapho,  layout = "centrality", cent = graph.strength(grapho)) +
    geom_edge_link() +
    #geom_edge_link(aes(colour = factor(min_levels_of_separation))) +
    geom_node_point() +
    #label = name works & concept_name doesn't - not sure why !!
    geom_node_text(aes(label=name), repel=TRUE)

  plot(ggr)

  ##########################
  #trying to get node labels

  #simple example from help
  simple <- create_notable('bull') %>%
    mutate(name = c('Thomas', 'Bob', 'Hadley', 'Winston', 'Baptiste')) %>%
    activate(edges) %>%
    mutate(type = sample(c('friend', 'foe'), 5, TRUE))

  ggraph(simple, layout = 'graphopt') +
         geom_edge_link(aes(start_cap = label_rect(node1.name),
                            end_cap = label_rect(node2.name)),
                            arrow = arrow(length = unit(4, 'mm'))) +
         geom_node_text(aes(label = name))

  plot(ggr)





  #if (messages) message("returning ",nrow(df1)," concepts")

  return(ggr)

}

#' super short name graph func
#' @rdname omop_graph
#' @export
#' @examples
#' # because of R argument matching, you can just use the first unique letters of
#' # arguments e.g. v for v_ids, cc for cc_ids
#' disabled to try to fix error : 'omop_concept_ancestor' is not an exported object from 'namespace:omopcept'
#omgr <- omop_graph


# ggraph requires two data frames, one for nodes and one for edges.
#I think that was the old version
# nodes <- df1 |>
#   select(ancestor_name,concept_name,vocabulary_id,domain_id) |>
#   mutate(id=row_number())

# old way
# nodes <- c(df1$ancestor_name, df1$concept_name) |>
#   unique() |>
#   tibble::tibble(label = .) |>
#   tibble::rowid_to_column("id")

# character names need to be node IDs.
# done by 2 joins to node dataframe.

# edges <- df1 |>
#   left_join(nodes, by = c("ancestor_name"="ancestor_name")) |>
#   rename(from = "id") |>
#   left_join(nodes, by = c("concept_name"="concept_name")) |>
#   rename(to = "id") |>
#   select(from, to, min_levels_of_separation,vocabulary_id,domain_id)

# old way
# edges <- df1 |>
#   left_join(nodes, by = c("ancestor_name"="label")) |>
#   rename(from = "id") |>
#   left_join(nodes, by = c("concept_name"="label")) |>
#   rename(to = "id") |>
#   select(from, to, min_levels_of_separation)

# grapho <- tbl_graph(nodes = nodes, edges = edges, directed = FALSE)
#
# nodes <- df1 |>
#   select(ancestor_name,concept_name,vocabulary_id,domain_id) |>
#   mutate(id=row_number())
