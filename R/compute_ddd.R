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

compute_ddd <- function(drug_code = NULL,
                        drug_exposure_table = NULL,
                        atc_ddd_path = NULL) {
    # Input validation
    if (is.null(drug_code)) {
        stop("Drug code must not be NULL")
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

    # filter drug_exposure_table for the drug_concept_ids
    filtered_drug_exposure <- drug_exposure_table |>
        dplyr::filter(drug_concept_id %in% drug_code)

    # get the route of administration
    filtered_drug_exposure <- filtered_drug_exposure |>
        dplyr::left_join(omop_atc_route(filtered_drug_exposure$route_concept_id), by = c("route_concept_id" = "concept_id"))

    # get the drug strength
    filtered_drug_exposure <- filtered_drug_exposure |>
        dplyr::left_join(omop_drug_strength_units(filtered_drug_exposure), by = "drug_concept_id")

    # get the drug lookup
    filtered_drug_lookup <- omop_drug_lookup_create(filtered_drug_exposure) |>
        dplyr::filter(ATC_level == 5)

    # add back the atc_code
    filtered_drug_exposure <- filtered_drug_exposure |>
        dplyr::left_join(filtered_drug_lookup, by = "drug_concept_id")

    # load atc_ddd_table
    atc_ddd_table <- atc_ddd_ref(atc_ddd_path)

    # # convert the uom to units objects
    # atc_ddd_table <- atc_ddd_table |>
    #     dplyr::mutate(
    #         uom_as_units =
    #             tryCatch(
    #                 {
    #                     units::as_units(uom, mode = "standard")
    #                 },
    #                 error = function(e) {
    #                     warning(sprintf("Could not convert unit '%s' to units object", x))
    #                     NA
    #                 }
    #             ))

    # Final join with ATC DDD data
    filtered_drug_exposure <- filtered_drug_exposure |>
        dplyr::left_join(atc_ddd_table, by = c("ATC_code" = "atc_code", "atc_route" = "adm_r"))

    # TODO: improve this calculation
    # This works now, but it is so slow because the units package is slow
    # and it is called for each row. I think if i do some sort of grouping
    # this might work faster
    filtered_drug_exposure <- filtered_drug_exposure |>
        dplyr::mutate(
            ddd_per_exposure = vapply(seq_len(nrow(filtered_drug_exposure)), function(i) {
                qty <- as.numeric(filtered_drug_exposure$quantity[i])
                cval <- as.numeric(filtered_drug_exposure$combined_value[i])
                ddd_val <- as.numeric(filtered_drug_exposure$ddd[i])

                if (is.na(qty) || is.na(cval) || is.na(ddd_val)) {
                    return(NA_real_)
                }

                tryCatch(
                    {
                        num <- units::set_units(
                            x = (qty * cval),
                            value = filtered_drug_exposure$combined_unit[i],
                            mode = "standard"
                        )
                        den <- units::set_units(
                            x = ddd_val,
                            value = filtered_drug_exposure$uom[i],
                            mode = "standard"
                        )
                        as.numeric(num / den)
                    },
                    error = function(e) NA_real_
                )
            }, FUN.VALUE = numeric(1))
        )

    # sum the ddd_per_exposure
    ddd_per_drug <- filtered_drug_exposure |>
        dplyr::group_by(drug_concept_id) |>
        dplyr::summarize(ddd_per_drug = sum(ddd_per_exposure, na.rm = TRUE))

    return(ddd_per_drug)
}
