#' create a lookup table from drug concepts to ATC drug classes
#'
#' EXPERIMENTAL
#' either all drug concepts filtered by concept_class_id
#' OR all drug concepts in a passed table (e.g. drug_exposure)
#'
#' @param df optional table containing drug concept ids
#' @param name_drug_concept_id name of column containing drug concept ids, default="drug_concept_id"
# TODO think about this because probably don't want a filter if a table is passed
#' @param concept_class_ids optional filter of concept_class_ids, multiple allowed, default = "Ingredient", ignored if a table is passed as df
#'
#' @param savefile whether to save as file, default TRUE
#' @param filetype default "csv" later add optrion for "parquet"
#'
#' @return data frame with drug concepts and ATC classes
#' @export
#' @examples
#' drug_lookup = omop_drug_lookup_create()
#'
omop_drug_lookup_create <- function(df = NULL,
                                    name_drug_concept_id = "drug_concept_id",
                                    concept_class_ids = c("Ingredient"),
                                    savefile = FALSE,
                                    file = "drug_lookup",
                                    filetype = "csv") {


  # 9 million ATC descendants !

  atc_descendants <- omop_concept_ancestor() |>
    #ideally would do before collect
    #but get Error in df[[id_col_name]] <- as.integer(df[[id_col_name]]) : cannot add bindings to a locked environment
    #that I can probably fix in omopcept
    #collect() |>
    omop_join_name(namestart = "ancestor", columns = c("concept_name","vocabulary_id","concept_class_id")) |>
    #TODO need to speed up, partly by changing renaming
    #renaming of joined columns to differentiate ancestor & descendant
    rename(ancestor_vocabulary_id = vocabulary_id,
           ATC_level         =  concept_class_id) |>

    omop_join_name(namestart = "descendant", columns = c("concept_name","vocabulary_id","concept_class_id")) |>
    filter(ancestor_vocabulary_id=="ATC" &
           vocabulary_id == "RxNorm Extension") |>

    # renaming columns
    select(ATC_level,concept_class_id,
           ATC_concept_id    = ancestor_concept_id,
           ATC_concept_name  = ancestor_concept_name,
           drug_concept_id   = descendant_concept_id,
           drug_concept_name = descendant_concept_name
    ) |>
    collect() |>
    # extract numeric part of the ATC level
    mutate(ATC_level = stringr::str_sub(ATC_level,5,5))


  if ( is.null(df) )
  {
    #if no table then filter by concept_class_id arg
    atc_descendants <- atc_descendants |>
      filter(concept_class_id %in% concept_class_ids)
  } else
  {
    #join or filter concept_ids present in passed table
    atc_descendants <- atc_descendants |>
      right_join(df, by=join_by(drug_concept_id == {{name_drug_concept_id}}))
  }

if (savefile) write_csv(atc_descendants, file = file)

invisible(atc_descendants)

}





