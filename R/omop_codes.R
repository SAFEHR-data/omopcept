#' string search of concept_code in omop concepts table
#'
#' @param findstring string to search for or regex
#' @param ignore_case ignore case in string comparison, default TRUE
#' @param exact TRUE for exact string search, "start" for exact start, "end" for exact end, default=TRUE because user likely to look for whole code
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
#' omop_codes("81752-8")
#' omop_codes("AJCC/UICC-Stage",exact=FALSE)

omop_codes <- function( findstring,
                           ignore_case = TRUE,
                           #negate = FALSE,
                           exact = TRUE,
                           fixed = FALSE,
                           c_ids=NULL,
                           d_ids=NULL,
                           v_ids=NULL,
                           cc_ids=NULL,
                           standard=NULL,
                           messages=TRUE) {


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

    #note only difference to omop_names() is concept_code rather than concept_name on next line
    #and that exact arg default is TRUE
    filter(grepl(findstring, concept_code, ignore.case = ignore_case, fixed = fixed)) |>

    collect() |>

    omop_filter_concepts(c_ids=c_ids, d_ids=d_ids, v_ids=v_ids, cc_ids=cc_ids, standard=standard)


  if (messages) message("returning ",nrow(df1)," concepts")

  return(df1)

}


#' super short name func to search concepts by concept_code
#' @rdname omop_codes
#' @export
#' @examples
#' ocodes("AJCC/UICC-Stage")
ocodes <- omop_codes
