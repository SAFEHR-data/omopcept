#' join omop concept name onto a dataframe with a *_concept_id column
#'
#' adds (namestart)_name based on (namestart)_concept_id
#' e.g. drug_concept_id to get drug_name
#'
#' @param df dataframe
#' @param namestart start of *_concept_id column, if NULL will join on concept_name
#' @export
#' @examples
#' df1 <- data.frame(concept_id=(c(3571338L,4002075L)))
#' join_omop_name(df1)
#' df2 <- data.frame(drug_concept_id=(c(4000794L,4002592L)))
#' join_omop_name(df2, namestart="drug")
#' #df2 <- drug_exposure %>% distinct(route_concept_id) %>% join_omop_name(route_concept_id)
join_omop_name <- function(df, namestart=NULL) {

  if (is.null(namestart)) id_col_name <- "concept_id"
  else id_col_name  <- paste0(namestart,"_concept_id")

  name_col_name <- sub("_id","_name",id_col_name)


  #beware rename concept_name column before joining in case
  #there is already a concept_name column in df
  id_and_name <- concept |>
    select(.data$concept_id,.data$concept_name) |>
    rename_with(~name_col_name, .data$concept_name)

  df |>
    left_join(id_and_name, by = dynamic_by(id_col_name,"concept_id"))

}
