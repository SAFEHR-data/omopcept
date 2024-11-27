#' create a lookup table from drug concepts to ATC drug classes
#'
#' EXPERIMENTAL
#' either all drug concepts filtered by concept_class_id
#' OR all drug concepts in a passed table (e.g. drug_exposure)
#'
#' @param df optional table containing drug concept ids
#' @param name_drug_concept_id name of column containing drug concept ids, default="drug_concept_id"
#' @param concept_class_ids optional filter of concept_class_ids, multiple allowed, default = "Ingredient", ignored if a table is passed as df
#'
#' @param outfile name for output file default=NULL for no file
# @param filetype default "csv" later add optrion for "parquet"
#' @param messages whether to print info messages, default=TRUE
#'
#' @return data frame with drug concepts and ATC classes
#' @export
#' @examples
#' drug_lookup = omop_drug_lookup_create()
# #standard_concept == 'S' important for this example to work
#rxnormext_egs <- omop_concept() |> filter(vocabulary_id == "RxNorm Extension" & standard_concept == 'S') |> head(100) |> collect()
#lookup2 <- omop_drug_lookup_create(select(rxnormext_egs,concept_id), name_drug_concept_id="concept_id")
omop_drug_lookup_create <- function(df = NULL,
                                    name_drug_concept_id = "drug_concept_id",
                                    concept_class_ids = c("Ingredient"),
                                    #savefile = FALSE,
                                    outfile = NULL, #"drug_lookup",
                                    #filetype = "csv",
                                    messages = TRUE) {


  # 9 million ATC descendants !

  if (messages) message("creating drug lookup may take more than a few seconds (e.g. ~20s for all concept_class_ids == 'Ingredient'")

  #filtering order to try to speed up (i.e. filter before join where possible)

  # get first link to the data
  atc_descendants <- omop_concept_ancestor()

  if ( !is.null(df) )
  {
    #join or filter concept_ids present in passed table
    atc_descendants <- atc_descendants |>
      dplyr::right_join(df, by=join_by(descendant_concept_id == {{name_drug_concept_id}}))
  }


  atc_descendants <- atc_descendants |>
    #ideally would do before collect
    #but get Error in df[[id_col_name]] <- as.integer(df[[id_col_name]]) : cannot add bindings to a locked environment
    #that I can probably fix in omopcept
    #collect() |>
    omop_join_name(namestart = "descendant", columns = c("concept_name","vocabulary_id","concept_class_id"))

  # done here straight after join of concept_class_id for speed
  if ( is.null(df) )
  {
    #if no table then filter by concept_class_id arg
    atc_descendants <- atc_descendants |>
      filter(concept_class_id %in% concept_class_ids)
  }

  atc_descendants <- atc_descendants |>
    rename(drug_concept_id   = descendant_concept_id,
           drug_concept_name = descendant_concept_name,
           drug_concept_class_id = concept_class_id,
           drug_vocabulary_id = vocabulary_id) |>

    omop_join_name(namestart = "ancestor", columns = c("concept_name","vocabulary_id","concept_class_id")) |>
    #renaming of joined columns to differentiate ancestor & descendant
    rename(ancestor_vocabulary_id = vocabulary_id,
           ATC_level         =  concept_class_id) |>


    filter(ancestor_vocabulary_id=="ATC" &
           drug_vocabulary_id == "RxNorm Extension") |>

    # renaming columns
    select(drug_concept_name, drug_concept_id, drug_concept_class_id,
           ATC_level,
           ATC_concept_name  = ancestor_concept_name,
           ATC_concept_id    = ancestor_concept_id

    ) |>
    collect() |>
    # extract numeric part of the ATC level
    mutate(ATC_level = stringr::str_sub(ATC_level,5,5))


if (!is.null(outfile)) write_csv(atc_descendants, file = paste0(outfile,".csv"))

invisible(atc_descendants)

}





