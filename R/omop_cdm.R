#' read all omop tables from a folder containing parquet or csv files into a list
#' advantage that you don't need to specify table names
#'
#' @param path path of folder containing files
#' @param lowercasenames whether to make table names lowercase, default TRUE
#' @param filetype default "parquet" option "csv"
#'
#' @return a list containing omop tables
#'
#' @example
#' #omop = omop_cdm(path,filetype="csv")
#'
omop_cdm <- function(path,
                     filetype = "parquet",
                     lowercasenames = TRUE) {

  # install required packages if not present
  required_packages <- c("fs","purrr")
  install_package <- function(packname) {
    if (!requireNamespace(packname, quietly = TRUE)) {
      message("Trying to install required package:",packname)
      utils::install.packages(packname)
    }
  }
  #required_packages |> purrr::map(\(pkg) install_package(pkg))
  lapply(required_packages,install_package)

  #get all files matching filetype fs::dir_ls
  filepaths <- fs::dir_ls(path,glob=paste0("*.",filetype))

  #remove /path/* & .extension from tablenames
  tablenames <- tools::file_path_sans_ext(basename(filepaths))

  if (lowercasenames) tablenames <- tolower(tablenames)

  #set vector names to tablenames
  #so that list elements get named with these by map
  filepaths <- set_names(filepaths, tablenames)

  #read all files in folder and put each into a master list returned by the function
  if (filetype == "parquet") {

    list_omop <- purrr::map(filepaths,read_parquet)

  } else if (filetype == "csv") {

    list_omop <- purrr::map(filepaths,read_csv)
  }
}





