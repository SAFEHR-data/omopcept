#' create a table of drug strength
#'
#' @param df a dataframe of drug exposure from the OMOP CDM
#' TODO: add default df to all the drugs in the OMOP CDM
#'
#' @return a dataframe of drug strength
#' @examples
#' create a table of drug strength
#'
#' @param df a dataframe of drug exposure from the OMOP CDM
#' TODO: add default df to all the drugs in the OMOP CDM
#'
#' @return a dataframe of drug strength
#' @examples
omop_drug_strength_units <- function(df) {
    # get the drug strength table from the package cache
    # if it doesn't exist, download the DRUG_STRENGTH.csv from Athena
    # and save it to the package cache

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

    # filter the drug strength table to only include the drugs in the input dataframe
    # first collect unique drug_concept_ids from df
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

    # get concepts file and filter it to only include the units
    # and the columns we want
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


    # join the drug strength table with the units concepts table
    drug_strength_units <- filtered_drug_strength |>
        dplyr::left_join(
            units_concepts,
            join_by(numerator_unit_concept_id == concept_id)
        ) |>
        rename(numerator_unit_concept_name = concept_name) |>
        dplyr::left_join(
            units_concepts,
            join_by(denominator_unit_concept_id == concept_id)
        ) |>
        rename(denominator_unit_concept_name = concept_name) |>
        dplyr::left_join(
            units_concepts,
            join_by(amount_unit_concept_id == concept_id)
        ) |>
        rename(amount_unit_concept_name = concept_name)

    # Create a new column that combines unit information based on availability
    drug_strength_units <- drug_strength_units |>
        mutate(
            combined_unit = case_when(
                !is.na(amount_unit_concept_name) ~ amount_unit_concept_name,
                !is.na(numerator_unit_concept_name) | !is.na(denominator_unit_concept_name) ~
                    paste(numerator_unit_concept_name, "/", denominator_unit_concept_name),
                TRUE ~ NA_character_
            )
        )

    # Create a vector of valid units that can be parsed by as_units()
    # Using DuckDB because I could not get arrow to work correctly
    # TODO: find a better way to do this
    valid_units <- drug_strength_units |>
        arrow::to_duckdb() |>
        dplyr::filter(!is.na(combined_unit)) |>
        dplyr::distinct(combined_unit) |>
        dplyr::collect() |>  # Collect only after reducing to unique units
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
        dplyr::inner_join(
            valid_units |> filter(is_valid),
            by = "combined_unit"
        ) |>
        select(-is_valid)

    drug_strength_units_invalid <- drug_strength_units |>
        dplyr::inner_join(
            valid_units |> filter(!is_valid),
            by = "combined_unit"
        ) |>
        select(-is_valid)
    # TODO: add a warning for invalid units and export a report
    # TODO: add a check for missing numerator or denominator

    # Create a lookup table of unique units
    vaild_unit_lookup <- valid_units |>
        filter(is_valid) |>
        mutate(
            unit_object = sapply(combined_unit, function(x) {
                tryCatch(
                    units::as_units(x),
                    error = function(e) NULL
                )
            }, simplify = FALSE)
        )

    # Join back to replace string units with unit objects
    drug_strength_units_valid <- drug_strength_units_valid |>
        dplyr::left_join(vaild_unit_lookup, by = "combined_unit") |>
        mutate(combined_unit = unit_object) |>
        select(-unit_object)

    # Calculate combined values based on available numerator/denominator or amount values
    drug_strength_units_valid <- drug_strength_units_valid |>
        mutate(
            combined_value = case_when(
                !is.na(numerator_value) & !is.na(denominator_value) ~
                    numerator_value / denominator_value,
                !is.na(numerator_value) ~ numerator_value,
                !is.na(amount_value) ~ amount_value,
                TRUE ~ NA_real_
            )
        )

    # # Do the same for invalid units dataframe to keep structure consistent
    # drug_strength_units_invalid <- drug_strength_units_invalid |>
    #     mutate(
    #         combined_value = case_when(
    #             !is.na(numerator_value) & !is.na(denominator_value) ~
    #                 numerator_value / denominator_value,
    #             !is.na(numerator_value) ~ numerator_value,
    #             !is.na(amount_value) ~ amount_value,
    #             TRUE ~ NA_real_
    #         )
    #     )

    return(drug_strength_units_valid)
}
