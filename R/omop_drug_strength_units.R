#' Create a table of drug strength with standardized units
#'
#' @param df A dataframe of drug exposure from the OMOP CDM containing drug_concept_id
#' @return A dataframe with columns:
#'   - drug_concept_id: The OMOP concept ID for the drug
#'   - ingredient_concept_id: The OMOP concept ID for the active ingredient
#'   - combined_value: The standardized strength value
#'   - combined_unit: The standardized unit (as a units object)
#' @examples
#' drug_exposures <- data.frame(drug_concept_id = c(1127078, 1127433))
#' drug_strengths <- omop_drug_strength_units(drug_exposures)
omop_drug_strength_units <- function(df) {
    # Validate input
    if (!("drug_concept_id" %in% names(df))) {
        stop("Input dataframe must contain drug_concept_id column")
    }

    # suppress Warnings for invalid units
    options(warn = -1)

    filepath <- file.path(tools::R_user_dir("omopcept", which = "cache"), "drug_strength.parquet")

    if (!file.exists(filepath) &&
        !file.exists("DRUG_STRENGTH.csv")) {
        stop("drug_strength.parquet not found in cache and
         DRUG_STRENGTH.csv not found in working directory
         please download DRUG_STRENGTH.csv from Athena
         and save in working directory")
    }

    if (!file.exists(filepath)) omop_vocabs_preprocess("DRUG_STRENGTH.csv")

    drug_strength <- arrow::open_dataset(filepath)

    # Get unique drug IDs from input and filter drug strength table
    drug_ids <- df |>
        dplyr::select(drug_concept_id) |>
        dplyr::distinct() |>
        dplyr::compute() |>
        dplyr::collect()

    filtered_drug_strength <- drug_strength |>
        arrow::to_duckdb() |>
        dplyr::filter(drug_concept_id %in% drug_ids$drug_concept_id) |>
        dplyr::compute() |>
        dplyr::collect()

    # Load and filter unit concepts
    concepts <- arrow::open_dataset(
        file.path(
            tools::R_user_dir("omopcept",
                which = "cache"
            ), "concept.parquet"
        )
    )

    units_concepts <- concepts |>
        arrow::to_duckdb() |>
        dplyr::filter(domain_id == "Unit") |>
        dplyr::select(concept_id, concept_name) |>
        dplyr::compute() |>
        dplyr::collect()

    # Join drug strength with unit information
    drug_strength_units <- filtered_drug_strength |>
        dplyr::left_join(
            units_concepts,
            join_by(numerator_unit_concept_id == concept_id)
        ) |>
        dplyr::rename(numerator_unit_concept_name = concept_name) |>
        dplyr::left_join(
            units_concepts,
            join_by(denominator_unit_concept_id == concept_id)
        ) |>
        dplyr::rename(denominator_unit_concept_name = concept_name) |>
        dplyr::left_join(
            units_concepts,
            join_by(amount_unit_concept_id == concept_id)
        ) |>
        dplyr::rename(amount_unit_concept_name = concept_name)

    # Combine unit information
    drug_strength_units <- drug_strength_units |>
        dplyr::mutate(
            combined_unit = dplyr::case_when(
                !is.na(amount_unit_concept_name) ~ amount_unit_concept_name,
                !is.na(numerator_unit_concept_name) & !is.na(denominator_unit_concept_name) ~
                    paste(numerator_unit_concept_name, "/", denominator_unit_concept_name),
                !is.na(numerator_unit_concept_name) ~ numerator_unit_concept_name,
                TRUE ~ NA_character_
            )
        )

    # Identify valid units
    valid_units <- drug_strength_units |>
        dplyr::filter(!is.na(combined_unit)) |>
        dplyr::distinct(combined_unit) |>
        dplyr::mutate(
            is_valid = sapply(combined_unit, function(x) {
                tryCatch(
                    {
                        units::as_units(x)
                        TRUE
                    },
                    error = function(e) FALSE
                )
            })
        )

    # Split the drug_strength_units dataframe based on valid/invalid units
    drug_strength_units_valid <- drug_strength_units |>
        dplyr::inner_join(valid_units |> dplyr::filter(is_valid), by = "combined_unit")

    drug_strength_units_invalid <- drug_strength_units |>
        dplyr::inner_join(valid_units |> dplyr::filter(!is_valid), by = "combined_unit")

    if (nrow(drug_strength_units_invalid) > 0) {
        warning(sprintf("Found %d records with invalid units", nrow(drug_strength_units_invalid)))
    }

    # Convert string units to unit objects
    unit_lookup <- valid_units |>
        dplyr::filter(is_valid) |>
        dplyr::mutate(
            unit_object = sapply(combined_unit, units::as_units, simplify = FALSE)
        )

    # Calculate final values and units
    drug_strength_units_valid <- drug_strength_units_valid |>
        dplyr::left_join(unit_lookup, by = "combined_unit") |> # Fixed typo in vaild_unit_lookup
        dplyr::mutate(combined_unit = unit_object)

    # Calculate combined values based on available numerator/denominator or amount values
    drug_strength_units_valid <- drug_strength_units_valid |>
        dplyr::mutate( # Added missing dplyr:: prefix
            combined_value = dplyr::case_when( # Added missing dplyr:: prefix
                !is.na(numerator_value) & !is.na(denominator_value) ~
                    numerator_value / denominator_value,
                !is.na(numerator_value) ~ numerator_value,
                !is.na(amount_value) ~ amount_value,
                TRUE ~ NA_real_
            )
        )

    # select only the columns we need
    drug_strength_units_valid <- drug_strength_units_valid |>
        dplyr::select(drug_concept_id, ingredient_concept_id, combined_value, combined_unit)

    return(drug_strength_units_valid)
}
