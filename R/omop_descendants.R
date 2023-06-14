#' find omop concept descendants of one passed
#'
#' @param c_id single omop concept_id or exact concept_name to get descendants of
#' @param c_ids one or more concept_id to filter by, default NULL for all
#' @param d_ids one or more domain_id to filter by, default NULL for all
#' @param v_ids one or more vocabulary_id to filter by, default NULL for all
#' @param cc_ids one or more concept_class_id to filter by, default NULL for all
#' @param standard one or more standard_concept to filter by, default NULL for all, S,C
#' @return a dataframe of concepts and attributes
#' @examples
#' omop_descendants(1633308)
#' omop_descendants("lenalidomide")
#' #chemodrugs <- omop_descendants("Cytotoxic chemotherapeutic",v_ids="HemOnc",d_ids="Regimen")
omop_descendants <- function(c_id,
                                c_ids=NULL,
                                d_ids=NULL,
                                v_ids=NULL,
                                cc_ids=NULL,
                                standard=NULL) {

  #if arg is char assume it is exact name & lookup id

  #TODO protect against
  # c_id giving 0 ancestors
  # c_id giving >1 ancestor
  # put next bit into a function shared bw omop_ancestors() & omop_descendants()

  #e.g. this fails because omop_names("Cytotoxic agent") is not unique
  #chemo_sno <- omop_descendants("Cytotoxic agent")

  if (class(c_id)=="character")
  {
    name1 <- c_id
    c_id <- filter(omopcept::omop_concept(), concept_name == c_id) |>
      pull(concept_id, as_vector=TRUE)
  } else {
    name1 <- filter(omopcept::omop_concept(), concept_id == c_id) |>
      pull(concept_name, as_vector=TRUE)
  }

  message("querying concept descendants of: ",name1," - may take a few seconds")

  df <- omopcept::omop_concept_ancestor() |>
    filter(ancestor_concept_id == c_id) |>
    #renaming allows further filter of concept_id, may not be necessary
    rename(concept_id = descendant_concept_id) |>
    left_join(omopcept::omop_concept(), by = "concept_id") |>
    #left_join(omopcept::omop_concept(), by = c("descendant_concept_id" = "concept_id")) |>
    omop_filter_concepts(c_ids=c_ids, d_ids=d_ids, v_ids=v_ids, cc_ids=cc_ids, standard=standard) |>
    mutate(ancestor_name = name1) |>
    collect()

  return(df)

}


#' super short name func to find descendants
#' @rdname omop_descendants
#' @export
#' @examples
#' # because of R argument matching, you can just use the first unique letters of
#' # arguments e.g. v for v_ids, cc for cc_ids
#' chemodrugs <- odesc("Cytotoxic chemotherapeutic", v="HemOnc", d="Regimen")
odesc <- omop_descendants
