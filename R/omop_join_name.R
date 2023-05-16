#' join omop concept name onto a dataframe with a *_concept_id column
#'
#' adds (namestart)_name based on (namestart)_concept_id
#' e.g. drug_concept_id to get drug_name
#'
#' @param df dataframe
#' @param namestart start of *_concept_id column, if "" will join on concept_name
#' @export
#' @examples
#' data.frame(concept_id=(c(3571338L,4002075L))) |> omop_join_name()
#' data.frame(drug_concept_id=(c(4000794L,4002592L))) |> omop_join_name(namestart="drug")
#' #df2 <- drug_exposure %>% distinct(route_concept_id) %>% omop_join_name(route_concept_id)
omop_join_name <- function(df, namestart="") {

  #"" is to cope with concept_id from omop_join_name_all()
  if (namestart == "") id_col_name <- "concept_id"
  else id_col_name  <- paste0(namestart,"_concept_id")

  name_col_name <- sub("_id","_name",id_col_name)

  #beware rename concept_name column before joining in case
  #there is already a concept_name column in df
  id_and_name <- omopcept::omop_concept() |>
    select(.data$concept_id,.data$concept_name) |>
    rename_with(~name_col_name, .data$concept_name)

  #TODO can I make this faster by replacing the copy=TRUE with some filter & collect ?

  df |>
    left_join(id_and_name, by = dynamic_by(id_col_name,"concept_id"), copy = TRUE)

}


#' super short name func to join concept_names on
#' @rdname omop_join_name
#' @export
#' @examples
#' data.frame(drug_concept_id=(c(4000794L,4002592L))) |> ojoin(namestart="drug")
ojoin <- omop_join_name


#' join omop concept names onto all *_concept_id columns in a dataframe
#'
#' adds \\*_name based on \\*_concept_id
#' e.g. drug_concept_id to get drug_name etc.
#'
#' @param df dataframe
#' @return dataframe based on input df with 1 extra column added for each concept_id column
#' @export
#' @examples
#' #TODO create an OMOP correct example where columns are consistent between rows
#' data.frame(concept_id=(c(3571338L,4002075L)),
#'            drug_concept_id=(c(4000794L,4002592L))) |>
#'            omop_join_name_all()
#' #df2 <- drug_exposure %>%
#' #       head(100)) %>%
#' #       omop_join_name_all()
omop_join_name_all <- function(df) {

  colnames <- df |>
    select(ends_with("concept_id")) |>
    names() |>
    stringr::str_remove("_concept_id") |>
    stringr::str_remove("concept_id")    #to cope with 'concept_id' passes "" to omop_join_name()

  for(cname in colnames)
  {
    df <- df |>
      omop_join_name(cname)
  }

  return(df)
}

#' super short name func to join all concept_names to a table
#' @rdname omop_join_name_all
#' @export
#' @examples
#' #TODO create an OMOP correct example where columns are consistent between rows
#' data.frame(concept_id=(c(3571338L,4002075L)),
#'            drug_concept_id=(c(4000794L,4002592L))) |>
#'            ojoinall()
ojoinall <- omop_join_name_all
