#' find omop concept descendants of one passed
#'
#' @param c_id single omop concept_id or exact concept_name to get descendants of
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
#' omop_descendants(1633308)
#' #omop_descendants("lenalidomide")
#' #omop_descendants("Non-invasive blood pressure")
#' #omop_descendants("Non-invasive blood pressure",separation=c(1,2))
#' #chemodrugs <- omop_descendants("Cytotoxic chemotherapeutic",v_ids="HemOnc",d_ids="Regimen")
omop_descendants <- function(c_id,
                                c_ids=NULL,
                                d_ids=NULL,
                                v_ids=NULL,
                                cc_ids=NULL,
                                standard=NULL,
                                separation=NULL,
                                itself=FALSE,
                                messages=TRUE) {

  #if arg is char assume it is exact name & lookup id
  if (is.character(c_id))
  {
    name1 <- c_id
    c_id <- filter(omopcept::omop_concept(), concept_name == c_id) |>
      pull(concept_id, as_vector=TRUE)
  } else {
    name1 <- filter(omopcept::omop_concept(), concept_id == c_id) |>
      pull(concept_name, as_vector=TRUE)
  }

  #TODO protect against
  # c_id giving 0 ancestors
  # c_id giving >1 ancestor
  # put next bit into a function shared bw omop_ancestors() & omop_descendants()

  #e.g. this fails because omop_names("Cytotoxic agent") is not unique
  #chemo_sno <- omop_descendants("Cytotoxic agent")

  if (length(c_id) != 1)
  {
    msg <- paste0("will only find descendants of a single concept, you have ",length(c_id),
                 ". Please modify your query to get a single starting concept.")
    stop(msg)
  }

  if (messages) message("querying concept descendants of: ",name1," - may take a few seconds")

  df1 <- omopcept::omop_concept_ancestor() |>
    filter(ancestor_concept_id == c_id) |>
    #renaming allows further filter of concept_id, may not be necessary
    rename(concept_id = descendant_concept_id) |>
    left_join(omopcept::omop_concept(), by = "concept_id") |>
    #left_join(omopcept::omop_concept(), by = c("descendant_concept_id" = "concept_id")) |>
    omop_filter_concepts(c_ids=c_ids, d_ids=d_ids, v_ids=v_ids, cc_ids=cc_ids, standard=standard) |>
    mutate(ancestor_name = name1) |>
    collect()

  if (!itself) df1 <- df1 |> filter(!min_levels_of_separation==0)

  if(!is.null(separation)) df1 <- df1 |>  filter(min_levels_of_separation %in% separation)

  if (messages) message("returning ",nrow(df1)," concepts")

  return(df1)

}


#' super short name func to find descendants
#' @rdname omop_descendants
#' @export
#' @examples
#' # because of R argument matching, you can just use the first unique letters of
#' # arguments e.g. v for v_ids, cc for cc_ids
#' chemodrugs <- odesc("Cytotoxic chemotherapeutic", v="HemOnc", d="Regimen")
odesc <- omop_descendants
