#' find omop concept ancestors of one passed
#'
#' @param c_id single omop concept_id or exact concept_name to get ancestors of, default NULL returns all
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
#' omop_ancestors(1633308)
#' #omop_ancestors("Non-invasive blood pressure")
#' #omop_ancestors("Non-invasive blood pressure",separation=c(1,2))
#' #epoch_ance <- omop_ancestors("EPOCH, dose-escalated")
#' #no filtering by ancestors
#' #cman <- omop_ancestors(v_ids="Cancer Modifier")
omop_ancestors <- function(c_id=NULL,
                              c_ids=NULL,
                              d_ids=NULL,
                              v_ids=NULL,
                              cc_ids=NULL,
                              standard=NULL,
                              separation=NULL,
                              itself=FALSE,
                              #TODO implement a vocab_same arg
                              messages=TRUE
                           ) {

  #checks c_id and gets name (ALL if c_id==NULL)
  res <- check_c_id(c_id)
  #TODO tidy this up & check, done in a rush !!
  c_id <- res$c_id
  name1 <- res$name1

  # TODO 2 add arg about separation whether to use min, max. or both

  # TODO 3 protect against
  # c_id giving 0 ancestors
  # c_id giving >1 ancestor
  # put next bit into a function shared bw omop_ancestors() & omop_descendants()
  #e.g. this fails because omop_names("Cytotoxic agent") is not unique
  #chemo_sno <- omop_descendants("Cytotoxic agent")

  if (messages) message("querying concept ancestors of: ",name1," - may take a few seconds")

  df1 <- omopcept::omop_concept_ancestor()

  if (c_id != "none") df1 <- df1 |>
    filter(descendant_concept_id == c_id)

  df1 <- df1 |>
    rename(concept_id = ancestor_concept_id) |>
    left_join(omopcept::omop_concept(), by = "concept_id") |>
    omop_filter_concepts(c_ids=c_ids, d_ids=d_ids, v_ids=v_ids, cc_ids=cc_ids, standard=standard) |>
    omop_join_name(namestart="descendant") |>
    collect()

  if (!itself) df1 <- df1 |> filter(!min_levels_of_separation==0)

  if(!is.null(separation)) df1 <- df1 |>  filter(min_levels_of_separation %in% separation)

  if (messages) message("returning ",nrow(df1)," concepts")

  return(df1)

}

#' super short name func to find ancestors
#' @rdname omop_ancestors
#' @export
#' @examples
#' # because of R argument matching, you can just use the first unique letters of
#' # arguments e.g. v for v_ids, cc for cc_ids
#' chemodrugs <- odesc("Cytotoxic chemotherapeutic", v="HemOnc", d="Regimen")
oance <- omop_ancestors
