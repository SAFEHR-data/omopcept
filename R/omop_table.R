#' read single omop table from parquet or csv file
#'
#' @param tablename name of omop table e.g. "person"
#' @param path file path
#' @param filetype default "parquet" option "csv"
#' @return a dataframe
#' @example
#' #person = omop_table("person",path)
omop_table <- function(tablename,
                       path,
                       filetype="parquet") {

  stopifnot(filetype %in% c("parquet","csv"))

  filename <- file.path(path,paste0(tablename,".",filetype))

  if (filetype=="parquet")
    data <- read_parquet(filename)
  else
    data <- read_csv(filename)

}

