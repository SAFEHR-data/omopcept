#' open a reference to omop concept file(s) from provided location
#'
#' initially using R user cache
#'
#' @param location url of file location, defaults to package cache
#' @export
#' @examples
#' # open refernce, query and collect data to dataframe
#' open_concept() |> head() |> dplyr::collect()
#'
open_concept <- function(location = tools::R_user_dir("omopcepts", which = "cache")) {


  filepath = file.path(location,"concept.parquet")

  if(!file.exists(filepath)) download_concept()

  #just creates reference to the data
  concept <- arrow::open_dataset(filepath)

}
