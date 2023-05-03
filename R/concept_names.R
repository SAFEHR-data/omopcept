#' string search of concept_name in omop concepts table
#'
# @param df1 dataframe containing concept_name field, if null uses concept
#' @param pattern string to search for or regex
#' @param ignore_case ignore case in string comparison, default TRUE
#' @param negate If TRUE, return non-matching elements, default FALSE
#' @param c_ids one or more concept_id to filter by, default NULL for all
#' @param d_ids one or more domain_id to filter by, default NULL for all
#' @param v_ids one or more vocabulary_id to filter by, default NULL for all
#' @param cc_ids one or more concept_class_id to filter by, default NULL for all
#' @param standard one or more standard_concept to filter by, default NULL for all, S,C
#' @export
#' @examples
#' concept_names("AJCC/UICC Stage")
#' concept_names("chemotherapy", v_ids="LOINC")
#' concept_names("chemotherapy", v_ids=c("LOINC","SNOMED"), d_ids=c("Observation","Procedure"))

concept_names <- function(#df1 = NULL,
  pattern,
  ignore_case = TRUE,
  negate = FALSE,
  c_ids=NULL,
  d_ids=NULL,
  v_ids=NULL,
  cc_ids=NULL,
  standard=NULL) {

  df1 <- omopcepts::open_concept() |>

    #TODO put negate & ignore_case back in
    #TODO arrow str_detect() weirdly fails due to arg being called pattern

    filter_concepts(c_ids=c_ids, d_ids=d_ids, v_ids=v_ids, cc_ids=cc_ids, standard=standard) |>
    filter(str_detect(concept_name, pattern)) |>

    #filter(str_detect(concept_name, regex(pattern, ignore_case=ignore_case))) |>

    collect()
    #filter(grepl(pattern,.data$concept_name, ignore.case=ignore_case))
    #filter(stringr::str_detect(.data$concept_name, stringr::regex(pattern, ignore_case=ignore_case), negate=negate)) |>


  return(df1)

  # this allowed passing dataframe instead of concepts
  # but caused confusing behaviour when concept_names("test")
  # if (is.null(df1)) df1 <- concept
  #
  # if (!is.null(pattern))
  # {
  #   df1 <- df1 |>
  #     filter(str_detect(concept_name, pattern)) |>
  #     filter_concepts(c_ids=c_ids, d_ids=d_ids, v_ids=v_ids, cc_ids=cc_ids, standard=standard)
  # }

}

#' string search of concept_code in omop concepts table
#'
#' @param pattern string to search for or regex
#' @param ignore_case ignore case in string comparison, default TRUE
#' @param negate If TRUE, return non-matching elements, default FALSE
#' @param c_ids one or more concept_id to filter by, default NULL for all
#' @param d_ids one or more domain_id to filter by, default NULL for all
#' @param v_ids one or more vocabulary_id to filter by, default NULL for all
#' @param cc_ids one or more concept_class_id to filter by, default NULL for all
#' @param standard one or more standard_concept to filter by, default NULL for all, S,C
#' @export
#' @examples
#' concept_codes("AJCC/UICC-Stage")

concept_codes <- function( pattern,
                           ignore_case = TRUE,
                           negate = FALSE,
                           c_ids=NULL,
                           d_ids=NULL,
                           v_ids=NULL,
                           cc_ids=NULL,
                           standard=NULL) {

  df1 <- omopcepts::open_concept() |>

    #TODO put negate and ignore_case back in
    #TODO arrow str_detect() weirdly fails due to arg being called pattern

    filter_concepts(c_ids=c_ids, d_ids=d_ids, v_ids=v_ids, cc_ids=cc_ids, standard=standard) |>
    filter(str_detect(concept_code, pattern)) |>
    collect()

    #filter(grepl(pattern,.data$concept_code, ignore.case=ignore_case))
    #Error: Filter expression not supported for Arrow Datasets: grepl(pattern, .data$concept_name, ignore_case = ignore_case)
    #Call collect() first to pull data into R.
    #filter(stringr::str_detect(.data$concept_code, stringr::regex(pattern, ignore_case=ignore_case), negate=negate)) |>


  return(df1)

}
