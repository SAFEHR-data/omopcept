#' string search of concepts by name in the CONCEPT_RELATIONSHIP table
#'
#' a different (and quicker) way of finding relationships than omop_relations() that gets relations of a specified concept
#' note that names are not contained in CONCEPT_RELATIONSHIP so the function joins to CONCEPT to query
#'
# @param df1 dataframe containing concept_name field, if null uses concept
#' @param findstring to search for or regex, e.g. "^a" to find those starting with A
#' @param ignore_case ignore case in string comparison, default TRUE
#' @param exact TRUE for exact string search, "start" for exact start, "end" for exact end, default=FALSE for str_detect
#' @param fixed default FALSE allows regex,TRUE uses grepl exact matching
# @param negate If TRUE, return non-matching elements, default FALSE
#' @param c_ids one or more concept_id to filter by, default NULL for all
#' @param d_ids one or more domain_id to filter by, default NULL for all
#' @param v_ids one or more vocabulary_id to filter by, default NULL for all
#' @param cc_ids one or more concept_class_id to filter by, default NULL for all
#' @param standard one or more standard_concept to filter by, default NULL for all, S,C
#' @param messages whether to print info messages, default=TRUE
#' @export
#' @examples
#' orn <- omop_relations_names("diffuse large B cell lymphoma")
#' #omop_relations_names("AJCC/UICC Stage")
#' #omop_relations_names("chemotherapy", v_ids="LOINC")
#' #omop_relations_names("chemotherapy", v_ids=c("LOINC","SNOMED"), d_ids=c("Observation","Procedure"))
#' #set the findstring to "" to get all rows satisfying the other conditions
#' #omop_relations_names("", v_ids="Gender")
#' #omop_relations_names("", d_ids="Type Concept", standard="S")

#TODO add option to filter by CONCEPT_NAME_1 & CONCEPT_NAME_2
#(remember will need to join to concept table to get them)
#
#TODO may want to remove some of filtering options because
#would have to implement them for ID1 & 2, not sure they are useful (but maybe)
#
#TODO avoid duplication from reciprocal relationships

omop_relations_names <- function(#df1 = NULL,
  findstring,
  ignore_case = TRUE,
  exact = FALSE,
  fixed = FALSE,
  #negate = FALSE,
  c_ids=NULL,
  d_ids=NULL,
  v_ids=NULL,
  cc_ids=NULL,
  standard=NULL,
  messages=TRUE) {

  #warn that fixed==TRUE overrides exact!=FALSE
  if (fixed==TRUE & exact!=FALSE)
  {
    warning("fixed==TRUE overrides non FALSE values of exact, and may generate unexpected results")
  }

  # refine search regex
  if (exact == TRUE | exact == "start")
    findstring <- paste0("^", findstring)
  if (exact == TRUE | exact == "end" )
    findstring <- paste0(findstring, "$")

  df1 <- omopcept::omop_concept_relationship() |>

    #join twice for ID1 & ID2
    left_join( select(omopcept::omop_concept(),concept_id,concept_name),
               join_by(concept_id_1 == concept_id)) |>
    rename(concept_name_1=concept_name) |>
    left_join( select(omopcept::omop_concept(),concept_id,concept_name),
               join_by(concept_id_2 == concept_id)) |>
    rename(concept_name_2=concept_name) |>

    #find rows with concept_name_1 that satisfies string search
    filter(grepl(findstring, concept_name_1, ignore.case = ignore_case, fixed = fixed)) |>

    omop_filter_concepts(c_ids=c_ids, d_ids=d_ids, v_ids=v_ids, cc_ids=cc_ids, standard=standard) |>

    collect()

    #filter(stringr::str_detect(.data$concept_name, stringr::regex(findstring, ignore_case=ignore_case), negate=negate)) |>

  if (messages) message("returning ",nrow(df1)," concepts")

  return(df1)


}


#' super short name func to search relations by concept_name
#' @rdname omop_relations_names
#' @export
ornames <- omop_relations_names


