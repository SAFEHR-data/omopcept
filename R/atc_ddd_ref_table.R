#' open a ATC to DDD table from provided location
#'
#' This is a skelton func now to be filled in later by a parser if needed
#'
#' TODO: add defualt location or call a parser to collect
#' the most recent data from https://atcddd.fhi.no/atc_ddd_index/
#'
#' @param filepath file location and name
#' @return dataframe of ATC to DDD data
#' @export
#' @examples
#'
atc_ddd_ref <- function(filepath) {
  stopifnot(file.exists(filepath))

  # read the data
  atc_ddd <- read_csv(filepath)

  return(atc_ddd)
}