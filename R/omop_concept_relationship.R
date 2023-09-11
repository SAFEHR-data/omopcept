#' open a reference to omop concept relationship file from provided location
#'
#' defaults to package cache used by omop_download()
#'
#' @param location url of file location, defaults to package cache
#' @export
#' @examples
#' # open reference, query and collect data to dataframe
#' omop_concept_relationship() |> head() |> dplyr::collect()
#'
omop_concept_relationship <- function(location = tools::R_user_dir("omopcept", which = "cache")) {


  filepath = file.path(location,"concept_relationship.parquet")

  if(!file.exists(filepath)) omop_download("concept_relationship")

  #just creates reference to the data
  concept_relationship <- arrow::open_dataset(filepath)

}

#' super short name func to get reference to concept table
#' @rdname omop_concept_relationship
#' @export
#' @examples
#' ocr() |> head() |> dplyr::collect()
ocr <- omop_concept_relationship
