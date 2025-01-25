#' read single omop table from parquet or csv file
#' NOTE these omop_cdm* functions are for omop extracts rather than the concepts and may be best moved to another package
#'
#' @param tablename name of omop table e.g. "person"
#' @param path file path
#' @param filetype default "parquet" option "csv"
#' @return a dataframe
#' @export
#' @examples
#' #person = omop_cdm_table_read("person",path)
omop_cdm_table_read <- function(tablename,
                       path,
                       filetype="parquet") {

  stopifnot(filetype %in% c("parquet","csv"))

  filename <- file.path(path,paste0(tablename,".",filetype))

  if (filetype=="parquet")
    data <- read_parquet(filename)
  else
    data <- read_csv(filename)
    #BEWARE WET that this is repeated in omop_cdm_read()
    #see there for explanation
    data <- read_csv(onefile, col_types = cols(.default = "c")) |>
        readr::type_convert(guess_integer = TRUE)

}

