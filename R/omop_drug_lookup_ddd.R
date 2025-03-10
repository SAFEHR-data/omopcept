#' merge the drug lookup with DDD values from ATC to DDD reference table
#'
#'
#' @param df dataframe with drug concepts
#' @return data frame with drug concepts and ATC classes
#' @export table of drug concepts with DDD values, ATC administration routes
#' and units of measurement. If no dataframe is passed, the function will
#' create a drug lookup from all drugs in the OMOP vocabulary.
#' @examples

omop_drug_lookup_ddd <- function(df = NULL,
                                 outfile = NULL,
                                 messages = TRUE) {


  if (is.null(df)) {
    if (messages) message("no dataframe passed,
     creating drug lookup from all drugs")
    omop_drug_lookup <- omop_drug_lookup_create()
  }

  if (!is.null(df)) {
    omop_drug_lookup <- df
  }

  # read the atc to ddd reference table
  atc_ddd_ref <- atc_ddd_ref_table()

  # merge the drug lookup with the atc to ddd reference table
  omop_to_ddd <- dplyr::full_join(
                                  x = atc_ddd_ref,
                                  y = omop_drug_lookup,
                                  join_by("atc_code" == "ATC_code"),
                                  relationship = "many-to-many")

  return(omop_to_ddd)
}