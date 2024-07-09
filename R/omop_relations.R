#' find omop concept relations of one passed - immediate relations with indication of relationship
#'
#' @param c_id single omop concept_id or exact concept_name to get relations of, default NULL returns all
#' @param c_ids one or more concept_id to filter by, default NULL for all
#' @param d_ids one or more domain_id to filter by, default NULL for all
#' @param v_ids one or more vocabulary_id to filter by, default NULL for all
#' @param cc_ids one or more concept_class_id to filter by, default NULL for all
#' @param standard one or more standard_concept to filter by, default NULL for all, S,C
#' @param r_ids one or more relationship_id to filter by, default NULL for all, e.g c('Is a','Subsumes')
#' @param itself whether to include relations to concept itself, default=FALSE
#' @param names2avoid concept names to avoid, defaults to generic concepts with lots relations, can be set to NULL
#' @param join_names whether to join concept names onto ids, default TRUE, FALSE used by recursive to speed up
#' @param messages whether to print info messages, default=TRUE
#' @return a dataframe of concepts and attributes
#' @export
#' @examples
#' omop_relations("Non-invasive blood pressure")
#' omop_relations("Non-invasive blood pressure",r_ids=c('Is a','Subsumes'))
#' #omop_relations("lenalidomide")
#' #omop_relations(1633308)
#' #chemodrugs <- omop_relations("Cytotoxic chemotherapeutic",v_ids="HemOnc",d_ids="Regimen")
#' #cmde <- omop_relations(v_ids="Cancer Modifier")
omop_relations <- function(c_id=NULL,
                                c_ids=NULL,
                                d_ids=NULL,
                                v_ids=NULL,
                                cc_ids=NULL,
                                standard=NULL,
                                r_ids=NULL,
                                itself=FALSE,
                                names2avoid=c("SNOMED CT core","Defined","Primitive"),
                                join_names = TRUE,
                                messages=TRUE) {


  #checks c_id and gets name (ALL if c_id==NULL)
  res <- check_c_id(c_id)
  c_id <- res$c_id[1]
  name1 <- res$name1[1]

  # default avoidance of generic concepts that have huge num relations
  if (name1 %in% names2avoid)
  {
    if (messages) message("not returning relations of ",name1," because lots of, you can change by setting names2avoid to NULL or subset of default")
    return(NULL)
  }

  if (messages) message("querying concept relations of: ",name1," - may take a few seconds")

  df1 <- omopcept::omop_concept_relationship()

  if (c_id != "none") df1 <- df1 |>
    filter(concept_id_1 == c_id) #TODO check whether I want to add concept_id_2 to this filter
    #TODO add %in% c_id to vectorise

  if (!is.null(r_ids)) {
    df1 <- df1 |>
      filter(relationship_id %in% r_ids)
  }

  #get most attributes from omop_concept() to join
  #not all e.g.valid_start_date, end & invalid_reason already in relations
  concept_attributes <- omopcept::omop_concept() |>
    select(!c(concept_name,valid_start_date, valid_end_date, invalid_reason))

  df1 <- df1 |>
    left_join(concept_attributes, by = dplyr::join_by(concept_id_2 == concept_id)) |>
    omop_filter_concepts(c_ids=c_ids, d_ids=d_ids, v_ids=v_ids, cc_ids=cc_ids, standard=standard)

  #joining names to concept ids, could make it optional & not do in recursive
  if (join_names)
  {
    df1 <- df1 |>  omop_join_name_all()
  }

  # default option remove relations to itself
  if (itself==FALSE) df1 <- df1 |> filter(concept_id_1 != concept_id_2)

  #old move name column next to id to make more readable
  #not needed now with way names are joined
  #dplyr::relocate(concept_name_2, .after=concept_id_1) |>
  df1 <- df1 |> collect()

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
