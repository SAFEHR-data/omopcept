#' download omop concept file(s) from provided location
#'
#' initially using UCLH temporary private filestore
#'
#' @param location url of file location, defaults to UCLH filestore
#' @export
download_concept <- function( location="https://omopes.blob.core.windows.net/newcontainer/") {

  options(timeout = 360)

  download <- function(f, mode) {
    download.file(paste0(location,f),
                  #saving to extdata to replace existing package file
                  destfile = here("extdata",f),
                  mode = mode)
  }
  download("concept.parquet", "wb")
  # download("concept_relationship.parquet", "wb")
  # download("concept_ancestor.parquet", "wb")
  # download("drug_strength.parquet", "wb")
  # download("metadata_version.txt", "w")
}
