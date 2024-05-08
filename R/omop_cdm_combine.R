#' combine two omop cdm (Common Data Model) instances
#' initially works on lists but TODO get it to work on folder names by calling omop_cdm_read()
#'
#' @param cdm1 list containing cdm tables
#' @param cdm2 list containing cdm tables
# TODO re-enable these args if allowing files
# @param lowercasenames whether to make table names lowercase, default TRUE
# @param filetype default "parquet" option "csv"
#'
#' @return a list containing merged omop tables
#'
#' @examples
#' cdm1 <- list(person=tibble(id=1:3,age=21:23),
#'              measurement=tibble(id=1:3,meas=5:7))
#' cdm2 <- list(person=tibble(id=11:12,age=91:92),
#'             measurement=tibble(id=11:12,meas=15:16),
#'             death=tibble(id=11:12,d=c(0,1)))
#' cdm3 <- omop_cdm_combine(cdm1, cdm2)
#'
omop_cdm_combine <- function(cdm1, cdm2) {
                     #filetype = "parquet",
                     #lowercasenames = TRUE) {

  # loops version provided by Ana, works :-)
  # may be slow on big inputs ?
  all_names <- union(names(cdm1), names(cdm2))

  combined_list <- list()

  for (name in all_names) {
    if (name %in% names(cdm1) && name %in% names(cdm2)) {
      combined_list[[name]] <- bind_rows(cdm1[[name]], cdm2[[name]])
    }
    else if (name %in% names(cdm1)) {
      combined_list[[name]] <- cdm1[[name]]
    }
    else combined_list[[name]] <- cdm2[[name]]
  }

  combined_list


  # OLD version2 that nearly worked, but list included NAs for columns not present in inputs (because goes via a dataframe)
  # merged <- as.list(bind_rows(cdm1,cdm2))

  # OLD version1 that nearly worked, but produced a list containing dataframes with repeated columns, e.g. id
  # #install required packages if not present
  # required_packages <- c("purrr")
  # install_package <- function(packname) {
  #   if (!requireNamespace(packname, quietly = TRUE)) {
  #     message("Trying to install required package:",packname)
  #     utils::install.packages(packname)
  #   }
  # }
  # #required_packages |> purrr::map(\(pkg) install_package(pkg))
  # lapply(required_packages,install_package)
  #
  # cat_lists <- function(list1, list2) {
  #   keys <- unique(c(names(list1), names(list2)))
  #   purrr::map2(list1[keys], list2[keys], c) |>
  #     purrr::set_names(keys)
  # }
  #
  # lists <- list(cdm1, cdm2)
  #
  # merged <- purrr::reduce(lists, cat_lists)

}




