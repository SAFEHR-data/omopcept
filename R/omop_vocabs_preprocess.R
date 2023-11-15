#' read in omop vocabulary csvs downloaded from Athena, preprocess
#' and write out as binary parquet files for better performance.
#'
#' TODO think: do I want to save parquets directly into the package cache from here
#'
#' @param athena_source_directory filepath where omop vocab csvs are stored
#'
omop_vocabs_preprocess <- function(athena_source_directory) {

  stopifnot(file.exists(athena_source_directory))

  convert_valid_dates <- function(df) { df |>
      mutate(
        valid_start_date = ymd(valid_start_date),
        valid_end_date   = ymd(valid_end_date)
      )
  }

  read_athena_data <- function(file, col_types) {
    read_tsv(here(athena_source_directory, file), col_types = col_types)
  }

  write_result <- function(data,file) {
    write_parquet(data,here("omop_metadata",file))
  }

  concepts <- read_athena_data("CONCEPT.csv", col_types = "icccccciic") |>
    convert_valid_dates() |>
    #TODO do I offer option to filter out vocabs ?
    #these are vocabs that we filtered out for omop_es
    #but why didn't we just not download ?
    #also they are filtered out from here but not from relationship & ancestor tables
    #maybe I could also produce something that documents correspondence between
    #athena tick boxes & these ids
    #can I get at vocabulary_name from somewhere ?
    #filter(!(vocabulary_id %in% c("NDC","SPL","OSM","ICD10PCS","ICD10CM","ICD9CM"))) |>
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
