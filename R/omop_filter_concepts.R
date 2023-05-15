#' filter omop concepts by standard attributes
#'
#' Works on a dataframe or an arrow object. Can filter by one or more of : concept_id, domain_id, vocabulary_id, concept_class_id, standard_concept
#' used by other functions
#'
#' @param df dataframe with standard omop concept table columns
#' @param c_ids one or more concept_id to filter by, default NULL for all
#' @param d_ids one or more domain_id to filter by, default NULL for all
#' @param v_ids one or more vocabulary_id to filter by, default NULL for all
#' @param cc_ids one or more concept_class_id to filter by, default NULL for all
#' @param standard one or more standard_concept to filter by, default NULL for all, S,C
#' @return a filtered dataframe of concepts and attributes
#' @export
#' @examples
#' open_concept() |>
#'   omop_filter_concepts(d_ids=c("measurement","drug"),v_ids="SNOMED") |>
#'   dplyr::collect() |>
#'   dplyr::count(domain_id,vocabulary_id)
#' open_concept() |> omop_filter_concepts(v_ids="Gender") |> dplyr::collect()

omop_filter_concepts <- function(df,
                            c_ids=NULL,
                            #r_ids=NULL, #only in relationships table
                            d_ids=NULL,
                            v_ids=NULL,
                            cc_ids=NULL,
                            standard=NULL) {

    #tolower to make case insensitive
    #here because arrow can't cope with it in filter
    if(!is.null(c_ids)) c_ids <- tolower(c_ids)
    if(!is.null(d_ids)) d_ids <- tolower(d_ids)
    if(!is.null(v_ids)) v_ids <- tolower(v_ids)
    if(!is.null(cc_ids)) cc_ids <- tolower(cc_ids)
    if(!is.null(standard)) standard <- tolower(standard)

    df1 <- df

    if(!is.null(c_ids)) df1 <- df1 |>  filter(concept_id %in% c_ids)

    #tolower() to make case insensitive, but arrow fussy
    if(!is.null(d_ids)) df1 <- df1 |> filter(tolower(domain_id) %in% d_ids)
    if(!is.null(v_ids)) df1 <- df1 |> filter(tolower(vocabulary_id) %in% v_ids)
    if(!is.null(cc_ids)) df1 <- df1 |> filter(tolower(concept_class_id) %in% cc_ids)
    if(!is.null(standard)) df1 <- df1 |> filter(tolower(standard_concept) %in% standard)
  #dplyr::collect()

  # made this simpler above because arrow is fussy and somewhat unpredictable
  # df1 <- df |>
  #   pipe_if(!is.null(c_ids), \(d) d |> filter(.data$concept_id %in% c_ids) ) |>
  #   #pipe_if(!is.null(r_ids), \(d) d |> filter(relationship_id %in% r_ids) ) |>
  #   #tolower() to make case insensitive
  #   pipe_if(!is.null(d_ids), \(d) d |> filter(tolower(.data$domain_id) %in% tolower(d_ids)) ) |>
  #   pipe_if(!is.null(v_ids), \(d) d |> filter(tolower(.data$vocabulary_id) %in% tolower(v_ids)) ) |>
  #   pipe_if(!is.null(cc_ids), \(d) d |> filter(tolower(.data$concept_class_id) %in% tolower(cc_ids)) ) |>
  #   pipe_if(!is.null(standard), \(d) d |> filter(tolower(.data$standard_concept) %in% tolower(standard)) ) #|>
  #   #dplyr::collect()

  return(df1)

}
