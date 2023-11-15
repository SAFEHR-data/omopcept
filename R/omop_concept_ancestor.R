#' open a reference to omop concept ancestor file from provided location
#'
#' defaults to package cache used by omop_vocab_table_save()
#'
#' @param location url of file location, defaults to package cache
#' @export
#' @examples
#' # open reference, query and collect data to dataframe
#' omop_concept_ancestor() |> head() |> dplyr::collect()
#'
omop_concept_ancestor <- function(location = tools::R_user_dir("omopcept", which = "cache")) {


  filepath = file.path(location,"concept_ancestor.parquet")

  if(!file.exists(filepath)) omop_vocab_table_save("concept_ancestor")

  #just creates reference to the data
  concept_ancestor <- arrow::open_dataset(filepath)

}

#' super short name func to get reference to concept table
#' @rdname omop_concept_ancestor
#' @export
#' @examples
#' oca() |> head() |> dplyr::collect()
oca <- omop_concept_ancestor
