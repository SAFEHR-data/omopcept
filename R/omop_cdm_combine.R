#' combine two omop cdm (Common Data Model) instances
#' initially works on lists but TODO get it to work on folder names by calling omop_cdm_read()
#'
#' @param cdm1 list containing cdm tables
#' @param cdm2 list containing cdm tables
#' @param make_person_id_unique whether to check & shift person ids of cdm2, default TRUE
# TODO re-enable these args if allowing files
# @param lowercasenames whether to make table names lowercase, default TRUE
# @param filetype default "parquet" option "csv"
#'
#' @return a list containing merged omop tables
#' @export
#' @examples
#' pids1 <- 1:3
#' pids2 <- 11:12
#' cdm1 <- list(person=data.frame(person_id=pids1,age=21:23),
#'              measurement=data.frame(person_id=pids1,meas=5:7))
#' cdm2 <- list(person=data.frame(person_id=pids2,age=91:92),
#'             measurement=data.frame(person_id=pids2,meas=15:16),
#'             death=data.frame(person_id=pids2,d=c(0,1)))
#' cdm3 <- omop_cdm_combine(cdm1, cdm2)
#' #test creation of new ids when overlap
#' pids21 <- 1:2
#' cdm21 <- list(person=data.frame(person_id=pids21,age=91:92),
#'             measurement=data.frame(person_id=pids21,meas=15:16),
#'             death=data.frame(person_id=pids21,d=c(0,1)))
#' cdm31 <- omop_cdm_combine(cdm1, cdm21)
#'
omop_cdm_combine <- function(cdm1, cdm2,
                             make_person_id_unique = TRUE) {
                     #filetype = "parquet",
                     #lowercasenames = TRUE) {

  if (make_person_id_unique)
  {
    # add tens value greater than max1 to cdm2
    max1person <- max(cdm1$person$person_id, na.rm = TRUE)
    min2person <- min(cdm2$person$person_id, na.rm = TRUE)
    #if they are already separate then don't need to modify
    if (min2person < max1person)
    {
      #get nearest tens val above max1
      addto2 <- 10^nchar(max1person)

      message("in omop_cdm_combine adding ",addto2," to all person_ids in cdm2 to make unique, you can turn off with make_person_id_unique=FALSE")

      #find all person_id columns in cdm2 & add
      cdm12 <- cdm1
      for (name in names(cdm2)) {
        if ("person_id" %in% names(cdm2[[name]])) {
          cdm2[[name]]$person_id <- addto2 + cdm2[[name]]$person_id
        }}
    }
  }


  # loops version provided by Ana, just seconds on few thousand rows
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




