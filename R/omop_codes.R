#' string search of concept_code in omop concepts table
#'
#' @param findstring string to search for or regex
#' @param ignore_case ignore case in string comparison, default TRUE
# @param negate If TRUE, return non-matching elements, default FALSE
#' @param c_ids one or more concept_id to filter by, default NULL for all
#' @param d_ids one or more domain_id to filter by, default NULL for all
#' @param v_ids one or more vocabulary_id to filter by, default NULL for all
#' @param cc_ids one or more concept_class_id to filter by, default NULL for all
#' @param standard one or more standard_concept to filter by, default NULL for all, S,C
#' @export
#' @examples
#' omop_codes("AJCC/UICC-Stage")

omop_codes <- function( findstring,
                           ignore_case = TRUE,
                           #negate = FALSE,
                           c_ids=NULL,
                           d_ids=NULL,
                           v_ids=NULL,
                           cc_ids=NULL,
                           standard=NULL) {

  df1 <- omopcept::omop_concept() |>

    #TODO put negate back in if possible

    filter(arrow_match_substring_regex(concept_code,
                                       options=list(pattern=findstring,
                                                    ignore_case=ignore_case))) |>
    collect() |>

    omop_filter_concepts(c_ids=c_ids, d_ids=d_ids, v_ids=v_ids, cc_ids=cc_ids, standard=standard)


    #filter(grepl(findstring,.data$concept_code, ignore.case=ignore_case))
    #Error: Filter expression not supported for Arrow Datasets: grepl(pattern, .data$concept_name, ignore_case = ignore_case)
    #Call collect() first to pull data into R.
    #filter(stringr::str_detect(.data$concept_code, stringr::regex(, ignore_case=ignore_case), negate=negate)) |>


  return(df1)

}


#' super short name func to search concepts by concept_code
#' @rdname omop_codes
#' @export
#' @examples
#' ocodes("AJCC/UICC-Stage")
ocodes <- omop_codes
