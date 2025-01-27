#' Compute DDD from drug exposure
#'
#' This function computes the Daily Dose Dose from drug exposure
#'

compute_ddd <- function(mode = "atc",
                        drug_code = NULL) {
    # Check mode and return error if not valid
    if (!mode %in% c("atc", "omop")) {
        stop("Mode must be either 'atc' or 'omop'")
    }

    # Check drug_code and return error if not valid
    if (!is.null(drug_code)) {
        stop("Drug code must be NULL")
    }


    if (mode == "atc") {}
    if (mode == "omop") {}
}
