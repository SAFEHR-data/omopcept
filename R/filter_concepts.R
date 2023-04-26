#' filter omop concepts by standard attributes
#'
#' one or more of : concept_id, domain_id, vocabulary_id, concept_class_id, standard_concept
#' used by other functions
#'
#' @param df dataframe with standard omop concept table columns
#' @param c_ids one or more concept_id to filter by, default NULL for all
#' @param d_ids one or more domain_id to filter by, default NULL for all
#' @param v_ids one or more vocabulary_id to filter by, default NULL for all
#' @param cc_ids one or more concept_class_id to filter by, default NULL for all
#' @param standard one or more standard_concept to filter by, default NULL for all, S,C
#' @return a filtered dataframe of concepts and attributes
#' @examples
#' concept |> filter_concepts(d_ids=c("measurement","drug"),v_ids="SNOMED") |> count(domain_id,vocabulary_id)

filter_concepts <- function(df,
                            c_ids=NULL,
                            #r_ids=NULL, #only in relationships table
                            d_ids=NULL,
                            v_ids=NULL,
                            cc_ids=NULL,
                            standard=NULL) {

  df1 <- df |>
    pipe_if(!is.null(c_ids), \(d) d |> filter(concept_id %in% c_ids) ) |>
    #pipe_if(!is.null(r_ids), \(d) d |> filter(relationship_id %in% r_ids) ) |>
    #tolower() to make case insensitive
    pipe_if(!is.null(d_ids), \(d) d |> filter(tolower(domain_id) %in% tolower(d_ids)) ) |>
    pipe_if(!is.null(v_ids), \(d) d |> filter(tolower(vocabulary_id) %in% tolower(v_ids)) ) |>
    pipe_if(!is.null(cc_ids), \(d) d |> filter(tolower(concept_class_id) %in% tolower(cc_ids)) ) |>
    pipe_if(!is.null(standard), \(d) d |> filter(tolower(standard_concept) %in% tolower(standard)) )

  return(df1)

}
