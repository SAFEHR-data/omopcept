#' read all omop tables from a folder containing parquet or csv files into a list
#' advantage that you don't need to specify table names
#' NOTE these omop_cdm* functions are for omop extracts rather than the concepts and may be best moved to another package
#'
#' @param path path of folder containing files
#' @param lowercasenames whether to make table names lowercase, default TRUE
#' @param filetype default "parquet" option "csv"
#'
#' @return a list containing omop tables
#' @export
#' @examples
#' #omop = omop_cdm_read(path,filetype="csv")
#' #TODO woulkd be good to have a minimal example file in the package
#' #and to have a test that integer guessing works correctly
#'
omop_cdm_read <- function(path,
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
  filepaths <- purrr::set_names(filepaths, tablenames)

  #read all files in folder and put each into a master list returned by the function
  if (filetype == "parquet") {

    list_omop <- purrr::map(filepaths,read_parquet)

  } else if (filetype == "csv") {

    #list_omop <- purrr::map(filepaths,read_csv)

    #BEWARE
    #to guess integer columns correctly
    #previous issue that *concept_id in as double by read_csv then don't join
    #this reads as char then uses readr::type_convert that has a guess_integer arg
    #other (safer?) option would be to check col names & specify all *concept_id
    #columns as i, leave other as guess
    #e.g. like col_types="i?ii??"
    #read_csv doesn't have a guess_integer arg because can cause issues
    #see https://github.com/tidyverse/readr/issues/1094
    #ALSO WET that this is repeated in omop_cdm_table_read() for single table
    read_csv_guessint <- function(onefile) {
      read_csv(onefile, col_types = cols(.default = "c")) |>
        readr::type_convert(guess_integer = TRUE)
    }
    list_omop <- purrr::map(filepaths, read_csv_guessint)
  }
}





