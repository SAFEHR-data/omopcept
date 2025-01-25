#' create a table of drug strength
#'
#' @param df a dataframe of drug exposure from the OMOP CDM
#' TODO: add default df to all the drugs in the OMOP CDM
#'
#'
#' @return a dataframe of drug strength
#'
#' @examples
omop_drug_strength_units <- function(df) {
    # get the drug strength table from the package cache
    # if it doesn't exist, download the DRUG_STRENGTH.csv from Athena
    # and save it to the package cache

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

    # select only the columns we want
    drug_strength <- drug_strength |>
        select(
            drug_concept_id, ingredient_concept_id, amount_value,
            amount_unit_concept_id, numerator_value, numerator_unit_concept_id,
            denominator_value, denominator_unit_concept_id
        )

    # filter the drug strength table to only include the drugs in the input dataframe
    drug_strength <- drug_strength |>
        filter(drug_concept_id %in% df$drug_concept_id)

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
        filter(domain_id == "Unit")

    units_concepts <- units_concepts |>
        select(concept_id, concept_name)


    # join the drug strength table with the units concepts table
    drug_strength_units <- drug_strength |>
        left_join(
            units_concepts,
            join_by(numerator_unit_concept_id == concept_id)
        ) |>
        rename(numerator_unit_concept_name = concept_name) |>
        left_join(
            units_concepts,
            join_by(denominator_unit_concept_id == concept_id)
        ) |>
        rename(denominator_unit_concept_name = concept_name) |>
        left_join(
            units_concepts,
            join_by(amount_unit_concept_id == concept_id)
        ) |>
        rename(amount_unit_concept_name = concept_name)

    return(drug_strength)
}
