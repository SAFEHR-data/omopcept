#' Compute DDD from drug exposure
#'
#' This function computes the Daily Dose Dose from drug exposure
#'

compute_ddd <- function(mode = "atc",
                        drug_code = NULL,
                        drug_exposure_table = NULL) {
    # TODO: add option to input route of administration

    # Check input parameters
    if (!mode %in% c("atc", "omop")) {
        stop("Mode must be either 'atc' or 'omop'")
    }

    if (!is.null(drug_code)) {
        stop("Drug code must be NULL")
    }

    if (is.null(drug_exposure_table)) {
        stop("Drug exposure table must be provided")
    }

    # Check if drug_code is a string and convert to list if needed
    if (is.character(drug_code) && length(drug_code) == 1) {
        drug_code <- list(drug_code)
    } else if (!is.list(drug_code)) {
        stop("drug_code must be either a string or a list")
    }


    # compute DDD
    if (mode == "atc") {
        # create drug_lookup table
        drug_lookup <- omop_drug_lookup_create(drug_exposure_table, drug_concept_vocabs = c("RxNorm", "RxNorm Extension"))

        # get the OMOP concept_id for the drug code
        filtered_drug_lookup <- drug_lookup |> filter(ATC_code %in% drug_code)
    }
}
