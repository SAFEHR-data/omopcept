#' Compute DDD from drug exposure
#'
#' This function computes the Daily Defined Dose (DDD) from drug exposure data
#'
#' @param mode Character string specifying calculation mode - either "atc" or "omop"
#' @param drug_code Drug code(s) to filter on - either ATC code(s) or OMOP concept ID(s)
#' @param drug_exposure_table Data frame containing drug exposure data
#' @param atc_ddd_path Optional path to ATC DDD reference data
#' @return Data frame with DDD calculations per drug exposure
#' @export

compute_ddd <- function(mode = "atc",
                        drug_code = NULL,
                        drug_exposure_table = NULL,
                        atc_ddd_path = NULL) {
    # Input validation
    if (!mode %in% c("atc", "omop")) {
        stop("Mode must be either 'atc' or 'omop'")
    }

    if (is.null(drug_exposure_table)) {
        stop("Drug exposure table must be provided")
    }

    if (is.null(drug_code)) {
        stop("Drug code must be provided") # Fixed reversed logic
    }

    # Standardize drug_code input
    drug_code <- if (is.character(drug_code) && length(drug_code) == 1) {
        list(drug_code)
    } else if (is.list(drug_code)) {
        drug_code
    } else {
        stop("drug_code must be either a string or a list")
    }

    # Process based on mode
    filtered_drug_lookup <- if (mode == "atc") {
        # Create drug lookup table
        drug_lookup <- omop_drug_lookup_create(
            drug_exposure_table,
            drug_concept_vocabs = c("RxNorm", "RxNorm Extension")
        )

        # Filter for specified drug codes
        filtered <- drug_lookup |>
            dplyr::filter(ATC_code %in% unlist(drug_code))

        # Check for and warn about duplicates
        duplicates <- filtered |>
            dplyr::group_by(drug_concept_id) |>
            dplyr::filter(dplyr::n() > 1)

        if (nrow(duplicates) > 0) {
            warning_msg <- duplicates |>
                dplyr::group_by(drug_concept_id) |>
                dplyr::summarise(
                    atc_codes = paste(ATC_code, collapse = ", "),
                    .groups = "drop"
                ) |>
                dplyr::mutate(
                    msg = sprintf(
                        "drug_concept_id %d appears for ATC codes: %s",
                        drug_concept_id, atc_codes
                    )
                ) |>
                dplyr::pull(msg) |>
                paste(collapse = "\n")

            warning(
                "Duplicate drug_concept_ids found for ATC codes. ",
                "This may cause issues in the DDD computation:\n",
                warning_msg
            )
        }
        dplyr::distinct(filtered, drug_concept_id)
    } else {
        drug_code
    }

    # Join all required data
    result <- drug_exposure_table |>
        dplyr::filter(drug_concept_id %in% filtered_drug_lookup$drug_concept_id) |>
        dplyr::left_join(
            omop_atc_route(.$route_concept_id),
            by = c("route_concept_id" = "concept_id")
        ) |>
        dplyr::left_join(
            omop_drug_strength_units(.),
            by = "drug_concept_id"
        ) |>
        dplyr::left_join(
            filtered_drug_lookup,
            by = "drug_concept_id"
        )

    # Get and process ATC DDD reference data
    atc_ddd_table <- atc_ddd_ref(atc_ddd_path) |>
        dplyr::mutate(
            uom_as_units = sapply(uom, function(x) {
                tryCatch(
                    {
                        units::as_units(x, mode = "standard")
                    },
                    error = function(e) {
                        warning(sprintf("Could not convert unit '%s' to units object", x))
                        NA
                    }
                )
            }, simplify = FALSE)
        )

    # Final join with ATC DDD data
    result <- result |>
        dplyr::left_join(atc_ddd_table, by = c("ATC_code" = "atc_code"))

    # TODO: Implement DDD calculation
    # Possible approach using units package:
    # result <- result |>
    #     dplyr::mutate(
    #         ddd = units::set_units(quantity * combined_value, combined_unit) /
    #               units::set_units(ddd, uom_as_units)
    #     )

    return(result)
}
