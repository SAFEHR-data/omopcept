#' find omop concept descendants of one passed
#'
#' @param c_id single omop concept_id or exact concept_name to get descendants of, default NULL returns all
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
#' #no filtering by descendants
#' #(expect to be same as omop_ancestors())
#' #v slight difference 19409 v 19411 concepts, not sure why, prob not important
#' #cmde <- omop_descendants(v_ids="Cancer Modifier")
#' #cmde1 <- omop_descendants(v_ids="Cancer Modifier", separation=1)
omop_descendants <- function(c_id=NULL,
                                c_ids=NULL,
                                d_ids=NULL,
                                v_ids=NULL,
                                cc_ids=NULL,
                                standard=NULL,
                                separation=NULL,
                                itself=FALSE,
                                messages=TRUE) {


  #checks c_id and gets name (ALL if c_id==NULL)
  #TODO tidy this up & check, done in a rush !!
  res <- check_c_id(c_id,"descendants")
  c_id <- res$c_id[1]
  name1 <- res$name1[1]

  if (messages) message("querying concept descendants of: ",name1," - may take a few seconds")

  df1 <- omopcept::omop_concept_ancestor()

  if (c_id != "none") df1 <- df1 |>
    filter(ancestor_concept_id == c_id)

  df1 <- df1 |>
    #renaming allows further filter of concept_id, may not be necessary
    rename(concept_id = descendant_concept_id) |>
    left_join(omopcept::omop_concept(), by = "concept_id") |>
    #left_join(omopcept::omop_concept(), by = c("descendant_concept_id" = "concept_id")) |>
    omop_filter_concepts(c_ids=c_ids, d_ids=d_ids, v_ids=v_ids, cc_ids=cc_ids, standard=standard) |>
    #don't need next because ancestor_name already in concept table
    #actually it isn't, but there is ancestor_concept_id
    #and don't want to set to ALL
    #mutate(ancestor_name = name1) |>
    omop_join_name(namestart="ancestor") |>
    #TODO this shouldn't be necessary after option to omop_join_names added
    rename(ancestor_name = ancestor_concept_name) |>
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
