#' read in omop vocabulary csvs downloaded from Athena, preprocess
#' and write out as binary parquet files for better performance.
#'
#' by default saves parquet files locally to package cache where omopcept functions can access
#'
#' @param from filepath where omop vocab csvs are stored
#' @param to path to save parquet files locally, defaults to package cache which is where omopcept functions look
#'
#' @returns nothing
#' @seealso [omop_vocab_table_save()]
#'    alternative that saves an already processed parquet file from remote or local source to local package cache
#'
#' @export
omop_vocabs_preprocess <- function(from,
                                   to = tools::R_user_dir("omopcept", which = "cache")) {

  stopifnot("specified location of vocab csvs seems not to exist" = file.exists(from))

  convert_valid_dates <- function(df) { df |>
      mutate(
        valid_start_date = ymd(valid_start_date),
        valid_end_date   = ymd(valid_end_date)
      )
  }

  read_athena_data <- function(file, col_types) {
    read_tsv(file.path(from, file), col_types = col_types)
  }

  write_result <- function(data,file) {
    write_parquet(data,file.path(to,file))
  }

  concepts <- read_athena_data("CONCEPT.csv", col_types = "icccccciic") |>
    convert_valid_dates() |>
    write_result("concept.parquet")

  read_athena_data("CONCEPT_RELATIONSHIP.csv",col_types = "iiciic") |>
    semi_join(concepts, by = c("concept_id_1" = "concept_id")) |>
    semi_join(concepts, by = c("concept_id_2" = "concept_id")) |>
    convert_valid_dates() |>
    write_result("concept_relationship.parquet")

  read_athena_data("CONCEPT_ANCESTOR.csv", col_types = "iiiicc") |>
    semi_join(concepts, by = c("ancestor_concept_id" = "concept_id")) |>
    semi_join(concepts, by = c("descendant_concept_id" = "concept_id")) |>
    write_result("concept_ancestor.parquet")

  read_athena_data("DRUG_STRENGTH.csv", col_types = "iininininiic") |>
    semi_join(concepts, by = c("drug_concept_id" = "concept_id")) |>
    convert_valid_dates() |>
    write_result("drug_strength.parquet")

}
