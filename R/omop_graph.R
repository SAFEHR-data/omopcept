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

  #TODO fix these errors
  #! Failed to load R/omop_graph.R
  #Caused by error in `check_c_id()`: ! could not find function "check_c_id"

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

  # ggraph requires two data frames, one for nodes and one for edges.

  nodes <- c(df1$ancestor_name, df1$concept_name) %>%
    unique() %>%
    tibble(label = .) %>%
    rowid_to_column("id")

  # character names need to be node IDs.
  # done by 2 joins to node dataframe.

  edges <- df1 %>%
    left_join(nodes, by = c("ancestor_name"="label")) %>%
    rename(from = "id") %>%
    left_join(nodes, by = c("concept_name"="label")) %>%
    rename(to = "id") %>%
    select(from, to, min_levels_of_separation)

  grapho <- tbl_graph(nodes = nodes, edges = edges, directed = FALSE)

  ggr <- ggraph(grapho) +
    geom_edge_link(aes(colour = factor(min_levels_of_separation))) +
    geom_node_point()


  #if (messages) message("returning ",nrow(df1)," concepts")

  return(ggr)

}

#' super short name func to find ancestors
#' @rdname omop_graph
#' @export
#' @examples
#' # because of R argument matching, you can just use the first unique letters of
#' # arguments e.g. v for v_ids, cc for cc_ids
#' disabled to try to fix error : 'omop_concept_ancestor' is not an exported object from 'namespace:omopcept'
#omgr <- omop_graph
