#' open a reference to omop concept file(s) from provided location
#'
#' defaults to package cache used by omop_download()
#'
#' @param location url of file location, defaults to package cache
#' @export
#' @examples
#' # open reference, query and collect data to dataframe
#' omop_concept() |> head() |> dplyr::collect()
#'
omop_concept <- function(location = tools::R_user_dir("omopcept", which = "cache")) {


  filepath = file.path(location,"concept.parquet")

  if(!file.exists(filepath)) omop_download()

  #just creates reference to the data
  concept <- arrow::open_dataset(filepath)

}

#' super short name func to get reference to concept table
#' @rdname omop_concept
#' @export
#' @examples
#' oc() |> head() |> dplyr::collect()
oc <- omop_concept
