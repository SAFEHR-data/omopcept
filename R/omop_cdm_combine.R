#' combine two omop cdm (Common Data Model) instances
#' initially works on lists
#' NOTE these omop_cdm* functions are for omop extracts rather than the concepts and may be best moved to another package
#' TODO could be modified relatively easily to work on >2 extracts up to 9 :-)
#' TODO get it to work on folder names by calling omop_cdm_read()
#'
#' @param cdm1 list containing cdm tables
#' @param cdm2 list containing cdm tables
#' @param make_care_site_id_unique whether to set care_site_id to 1 & 2 for each instance, default TRUE
#' @param make_ids_unique whether to uniqueify all other IDs (multiply by 10 & add extractnum), default TRUE
#' @param add_care_site_name_to_person_id_tables whether to add column to all tables with person_id
# TODO re-enable these args if allowing files
# @param lowercasenames whether to make table names lowercase, default TRUE
# @param filetype default "parquet" option "csv"
#'
#' @return a list containing merged omop tables
#' @export
#' @examples
#' #test creation of new ids when overlap
#' pids1 <- 1:3
#' pids2 <- 1:2
#' cdm1 <- list(person=data.frame(person_id=pids1,age=21:23,care_site_id=1L),
#'              measurement=data.frame(person_id=pids1,meas=5:7),
#'              care_site=data.frame(care_site_id=1L, care_site_name="hospital1"))
#' cdm2 <- list(person=data.frame(person_id=pids2,age=91:92,care_site_id=2L),
#'             measurement=data.frame(person_id=pids2,meas=15:16),
#'             care_site=data.frame(care_site_id=1L, care_site_name="hospital2"),
#'             death=data.frame(person_id=pids2,d=c(0,1)))
#' cdm3 <- omop_cdm_combine(cdm1, cdm2)
#'
omop_cdm_combine <- function(cdm1, cdm2,
                             make_care_site_id_unique = TRUE,
                             make_ids_unique = TRUE,
                             add_care_site_name_to_person_id_tables = TRUE) {
                     #filetype = "parquet",
                     #lowercasenames = TRUE) {

  if (make_care_site_id_unique)
  {
    #make unique in care_site table
    #don't need to check current values set id to 1 for cdm1 & 2 for cdm2
    #BEWARE ASSUMES JUST 1 care_site per instance
    #TODO add check
    cdm1$care_site$care_site_id[1] <- 1
    cdm2$care_site$care_site_id[1] <- 2

    #set in person table for all rows
    cdm1$person$care_site_id <- 1
    cdm2$person$care_site_id <- 2
  }

  if (make_ids_unique)
  {
    # find all primary & foreign key columns (named ‘*_id’ but not ‘*_concept_id’)
    # multiply by 10 and add 1 for extract1 & 2 for extract2

    uniqueify_ids <- function(x, cdmnum) {

      #to keep a record
      changed_fields <- NULL

      for (i in seq_along(x)) {
        for (j in seq_along(x[[i]])) {

          col_name <- names(x[[i]])[j]

          if (grepl("_id$", col_name) &
              !grepl("concept_id$", col_name) &
              col_name != "care_site_id") {

            x[[i]][[j]] <- as.integer(x[[i]][[j]]) *10 + cdmnum

            changed_fields <- paste0(changed_fields," ",
                                     names(x)[i],"$",col_name)
          }
        }
      }

      message("uniquefied columns : ", changed_fields)

      return(x)
    }

    cdm1 <- cdm1 |> uniqueify_ids(1)
    cdm2 <- cdm2 |> uniqueify_ids(2)
  }



  if (add_care_site_name_to_person_id_tables)
  {
    #local function
    add_care_site_name <- function(cdm) {
      for (name in names(cdm)) {
        if ("person_id" %in% names(cdm[[name]])) {
          #BEWARE assumes single care_site per instance
          cdm[[name]]$care_site_name <- cdm$care_site$care_site_name[1]
        }}
      cdm
    }
    cdm1 <- add_care_site_name(cdm1)
    cdm2 <- add_care_site_name(cdm2)
  }

  # combine rows in all omop tables present
  # loops version provided by Ana, just seconds on few thousand rows
  all_names <- union(names(cdm1), names(cdm2))

  cdmboth <- list()

  for (name in all_names) {
    if (name %in% names(cdm1) && name %in% names(cdm2)) {
      cdmboth[[name]] <- bind_rows(cdm1[[name]], cdm2[[name]])
    }
    else if (name %in% names(cdm1)) {
      cdmboth[[name]] <- cdm1[[name]]
    }
    else cdmboth[[name]] <- cdm2[[name]]
  }


  cdmboth

}




