#' Compute DDD from drug exposure
#'
#' This function computes the Daily Defined Dose (DDD) from drug exposure data
#'
#' @param mode Character string specifying calculation mode - either "atc" or "omop"
#' @param target_concept_id Drug code(s) to filter on - either ATC code(s) or OMOP concept ID(s)  
#' @param drug_exposure_df Data frame containing drug exposure data
#' @param atc_ddd_path Optional path to ATC DDD reference data
#' @param start_date Optional start date to filter drug exposures (YYYY-MM-DD)
#' @param end_date Optional end date to filter drug exposures (YYYY-MM-DD)
#' @return A tibble with three columns:
#'   - drug_concept_id: OMOP concept ID for the drug
#'   - ddd_per_drug: Total DDD (Daily Defined Dose) for all exposures of that drug
#'   - concept_name: Name of the drug                                               
#' @export
#' @examples
#'
#' drug_exposure_df <- arrow::read_parquet("~/leicester/DRUG_EXPOSURE.parquet")
#' 
#' compute_ddd(target_concept_id = "1713694",
#'             mode = "drug",
#'             drug_exposure_df = drug_exposure_df,
#'             atc_ddd_path = "~/output/WHO ATC-DDD 2025-01-27.csv")
#'
#' reutns:
#' # A tibble: 1 × 2
#'  drug_concept_id ddd_per_drug
#'            <int>        <dbl>
#'1         1713694       19954.
#' 
#' 
#' compute_ddd(target_concept_id= "1713332" ,
#'             mode = "ingredient",
#'             drug_exposure_df = drug_exposure_df,
#'             atc_ddd_path = "~/output/WHO ATC-DDD 2025-01-27.csv")
#' 
#' # A tibble: 8 × 2
#'   drug_concept_id ddd_per_drug
#'             <int>        <dbl>
#' 1         1713370        69.7 
#' 2         1713520         8.33
#' 3         1713671       171.  
#' 4         1713694     15963.  
#' 5         1759879       383.  
#' 6        19073183        31   
#' 7        19073187      3070   
#' 8        19123605        46.4 
#' 

compute_ddd <- function(target_concept_id = NULL,
                        mode = "ingredient",
                        drug_exposure_df = NULL,
                        atc_ddd_path = NULL,
                        start_date = NULL,
                        end_date = NULL,
                        export_csv = FALSE
                        ) {
    # Input validation
    if (is.null(target_concept_id)) {
        stop("Drug code must not be NULL")
    }

    if (is.null(drug_exposure_df)) {
        stop("Drug exposure table must be provided")
    }
    
    if (!is.null(start_date)) {
        stopifnot(IsDate(start_date))
        start_date <- as.Date(start_date)
    } else {
        start_date <- min(drug_exposure_df$drug_exposure_start_date)
    }
    
    stopifnot(is.logical(export_csv))
    
    if (!is.null(end_date)) {
        stopifnot(IsDate(end_date))
        end_date <- as.Date(end_date)
    } else {
        end_date <- max(drug_exposure_df$drug_exposure_end_date)
    }
    # This current filter setup will catch all drug exposures that
    # - has a start date equal to or later than the given start date
    # OR
    # - has an end date equal to or earlier than the given end date
    # OR
    # - both
    drug_exposure_df <- drug_exposure_df |>
        dplyr::filter(drug_exposure_start_date >= start_date & drug_exposure_end_date <= end_date)

    # Check if target_concept_id is a string and convert to list if needed
    if (is.character(target_concept_id) && length(target_concept_id) == 1) {
        target_concept_id <- list(target_concept_id)
    } else if (!is.list(target_concept_id)) {
        stop("target_concept_id must be either a string or a list")
    }

    if (mode == "ingredient") {
        ddd_per_drug <- compute_ddd_ingredient(target_concept_id, drug_exposure_df, atc_ddd_path)
    } else if (mode == "drug") {
        ddd_per_drug <- compute_ddd_drug(target_concept_id, drug_exposure_df, atc_ddd_path)
    } else {
        stop("Invalid mode")
    }

    if(export_csv) {
        export_csv_func(ddd_per_drug)
    }
    return(ddd_per_drug)
                        }

IsDate <- function(input_date, date.format = "%d/%m/%y") {
  tryCatch(!is.na(as.Date(input_date, date.format)),  
           error = function(err) {FALSE})  
}

export_csv_func <- function(df, filename = NULL) {
    if (is.null(filename)) {
        filename <- paste0("output_", format(Sys.Date(), "%Y-%m-%d"), ".csv")
    }
  write.csv(df, filename)
}


compute_ddd_ingredient <- function(ingredient_concept_id_list, drug_exposure_df, atc_ddd_path) {


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

    # get list of drug_concept_ids with the ingredient_concept_id
    ingredient_id_unlisted <- unlist(ingredient_concept_id_list)
    drug_concept_id_list <- drug_strength |>
        arrow::to_duckdb() |>
        dplyr::filter(ingredient_concept_id %in% !!ingredient_id_unlisted) |>
        dplyr::select(drug_concept_id) |>
        dplyr::distinct() |>
        dplyr::compute() |>
        dplyr::collect() |>
        dplyr::pull(drug_concept_id) |>
        as.list()

    return(compute_ddd_drug(drug_concept_id_list, drug_exposure_df, atc_ddd_path, ingredient_concept_id_list))
}

compute_ddd_drug <- function(drug_concept_id_list,
                             drug_exposure_df,
                            atc_ddd_path,
                            ingredient_concept_id_list = NULL) {

    
   
    # filter drug_exposure_df for the drug_concept_ids
    filtered_drug_exposure <- drug_exposure_df |>
        dplyr::filter(drug_concept_id %in% drug_concept_id_list)

    # get the route of administration
    filtered_drug_exposure <- filtered_drug_exposure |>
        dplyr::left_join(omop_atc_route(filtered_drug_exposure$route_concept_id), by = c("route_concept_id" = "concept_id"))

    # get the drug strength
    # TODO: find a way to filter the drug strength table for the relevant ingredients only
    filtered_drug_exposure <- filtered_drug_exposure |>
        dplyr::left_join(omop_drug_strength_units(filtered_drug_exposure), by = "drug_concept_id")

    # if ingredient_concept_id is provided, filter the drug strength table
    if (!is.null(ingredient_concept_id_list)) {
        filtered_drug_exposure <- filtered_drug_exposure |>
            dplyr::filter(ingredient_concept_id %in% ingredient_concept_id_list)
    }

    # get the drug lookup
    filtered_drug_lookup <- omop_drug_lookup_create(filtered_drug_exposure) |>
        dplyr::filter(ATC_level == 5)

    # add back the atc_code
    filtered_drug_exposure <- filtered_drug_exposure |>
        dplyr::left_join(filtered_drug_lookup, by = "drug_concept_id")

    # load atc_ddd_table
    atc_ddd_table <- atc_ddd_ref(atc_ddd_path)

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

    # add drug name from the concept table 
    concepts <- arrow::open_dataset(
        file.path(
            tools::R_user_dir("omopcept", which = "cache"),
            "concept.parquet"
        )
    )

    ddd_per_drug <- ddd_per_drug |>
        dplyr::left_join(concepts |>
            arrow::to_duckdb() |>
            dplyr::select(concept_id, concept_name) |>
            dplyr::compute() |>
            dplyr::collect(), by = c("drug_concept_id" = "concept_id")
    )

    return(ddd_per_drug)
}
