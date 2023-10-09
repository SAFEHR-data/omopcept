#' find omop concept relations of one passed - immediate relations with indication of relationship
#'
#' @param c_id single omop concept_id or exact concept_name to get relations of, default NULL returns all
#' @param c_ids one or more concept_id to filter by, default NULL for all
#' @param d_ids one or more domain_id to filter by, default NULL for all
#' @param v_ids one or more vocabulary_id to filter by, default NULL for all
#' @param cc_ids one or more concept_class_id to filter by, default NULL for all
#' @param standard one or more standard_concept to filter by, default NULL for all, S,C
# @param itself whether to include passed concept in returned table (min_levels_of_separation==0), default=FALSE
#' @param messages whether to print info messages, default=TRUE
#' @return a dataframe of concepts and attributes
#' @export
#' @examples
#' omop_relations(1633308)
#' #omop_relations("lenalidomide")
#' #omop_relations("Non-invasive blood pressure")
#' #chemodrugs <- omop_relations("Cytotoxic chemotherapeutic",v_ids="HemOnc",d_ids="Regimen")
#' #cmde <- omop_relations(v_ids="Cancer Modifier")
omop_relations <- function(c_id=NULL,
                                c_ids=NULL,
                                d_ids=NULL,
                                v_ids=NULL,
                                cc_ids=NULL,
                                standard=NULL,
                                #separation=NULL,
                                #itself=FALSE,
                                messages=TRUE) {


  #checks c_id and gets name (ALL if c_id==NULL)
  res <- check_c_id(c_id)
  c_id <- res$c_id[1]
  name1 <- res$name1[1]

  if (messages) message("querying concept relations of: ",name1," - may take a few seconds")

  df1 <- omopcept::omop_concept_relationship()

  if (c_id != "none") df1 <- df1 |>
    filter(concept_id_1 == c_id) #TODO check whether I want to add concept_id_2 to this filter

  #get most attributes from omop_concept() to join
  #not all e.g.valid_start_date, end & invalid_reason already in relations
  concept_attributes <- omopcept::omop_concept() |>
    select(!c(concept_name,valid_start_date, valid_end_date, invalid_reason))

  df1 <- df1 |>
    left_join(concept_attributes, by = dplyr::join_by(concept_id_2 == concept_id)) |>
    omop_filter_concepts(c_ids=c_ids, d_ids=d_ids, v_ids=v_ids, cc_ids=cc_ids, standard=standard) |>
    #don't need because joined above with attributes
    omop_join_name_all() |>
    #move name column next to id to make output more readable
    #dplyr::relocate(concept_name_2, .after=concept_id_1) |>
    collect()

  #TODO do I want an itself arg, doing something with c1 & 2
  #if (!itself) df1 <- df1 |> filter(!min_levels_of_separation==0)

  if (messages) message("returning ",nrow(df1)," concepts")

  return(df1)

}


#' super short name func to find relations
#' @rdname omop_relations
#' @export
#' @examples
#' # because of R argument matching, you can just use the first unique letters of
#' # arguments e.g. v for v_ids, cc for cc_ids
#' chemodrugs <- orels("Cytotoxic chemotherapeutic", v="HemOnc", d="Regimen")
orels <- omop_relations
