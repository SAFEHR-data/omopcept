#' string search of concept_name in omop concepts table
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
#' omop_names("AJCC/UICC Stage")
#' #omop_names("chemotherapy", v_ids="LOINC")
#' #omop_names("chemotherapy", v_ids=c("LOINC","SNOMED"), d_ids=c("Observation","Procedure"))
#' #set the findstring to "" to get all rows satisfying the other conditions
#' #omop_names("", v_ids="Gender")
#' #omop_names("", d_ids="Type Concept", standard="S")
#' #exact= options
#' #t1 <- onames("tobacco")
#' #returning 616 concepts
#' #t2 <- onames("tobacco",exact=TRUE)
#' #returning 2 concepts
#' #t3 <- onames("tobacco",exact="start")
#' #returning 229 concepts
#' #t4 <- onames("tobacco",exact="end")
#' #returning 54 concepts

omop_names <- function(#df1 = NULL,
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

  df1 <- omopcept::omop_concept() |>

    filter(grepl(findstring, concept_name, ignore.case = ignore_case, fixed = fixed)) |>

    #old way, see below about arrow_match_substring_regex
    # filter(arrow_match_substring_regex(concept_name,
    #                                    options=list(pattern=findstring,
    #                                                 ignore_case=ignore_case))) |>

    omop_filter_concepts(c_ids=c_ids, d_ids=d_ids, v_ids=v_ids, cc_ids=cc_ids, standard=standard) |>

    collect()

    #filter(stringr::str_detect(.data$concept_name, stringr::regex(findstring, ignore_case=ignore_case), negate=negate)) |>

  if (messages) message("returning ",nrow(df1)," concepts")

  return(df1)

  # this allowed passing dataframe instead of concepts
  # but caused confusing behaviour when omop_names("test")
  # if (is.null(df1)) df1 <- concept
  #
  # if (!is.null(findstring))
  # {
  #   df1 <- df1 |>
  #     filter(str_detect(concept_name, findstring)) |>
  #     omop_filter_concepts(c_ids=c_ids, d_ids=d_ids, v_ids=v_ids, cc_ids=cc_ids, standard=standard)
  # }

}


#' super short name func to search concepts by concept_name
#' @rdname omop_names
#' @export
#' @examples
#' # onames("chemotherapy", v_ids="LOINC")
#' # because of R argument matching, you can just use the first unique letters of
#' # arguments e.g. v for v_ids, cc for cc_ids
#' # to get all clinical drugs starting with A
#' onames("^a", d="DRUG", v="SNOMED", cc="Clinical Drug")
#' # to get all 'chop' cancer regimens
#' #chops <- onames("chop", d="Regimen")
onames <- omop_names



#old issue couldn't pass a string varible within a function - its not recognised by arrow
#seems to be OK now
#https://arrow.apache.org/docs/r/articles/developers/writing_bindings.html
#apache arrow R cookbook is good on this with list of C++ functions
#https://arrow.apache.org/cookbook/r/manipulating-data---tables.html#use-r-functions-in-dplyr-verbs-in-arrow
#list_compute_functions() gives list of C++ functions
#C++ func doc : https://arrow.apache.org/docs/cpp/compute.html#available-functions
#looking at the output without collect() shows the C++ code
#omop_concept() |> filter(str_detect(str_to_lower(concept_name),str_to_lower(stringvar)))

