#' check that concept names and ids match in a passed table
#'
#'
#' @param df dataframe
#' @param id_col_name name of id column, default="concept_id"
#' @param name_col_name name of name column, default="concept_name"
#' @export
#' @examples
#' #example1 should pass, because names are joined from vocab
#' data.frame(concept_id=c(3571338L,4002075L)) |> omop_join_name() |> omop_check_names()
#' #example2 with an incorrect name
#' tst <- data.frame(concept_id=c(4052465L,4052465L),
#'                   concept_name=c("test wrong name","Ex-pipe smoker")) |>
#'            omop_check_names()
omop_check_names <- function(df,
                             id_col_name = "concept_id",
                             name_col_name = "concept_name") {

  #check that name & id cols exist in passed df
  if (!id_col_name %in% names(df) | !name_col_name %in% names(df))
    stop("passed dataframe does not contain columns ",id_col_name," and/or ",name_col_name)

  df2 <- df |>
    #select just name & id columns
    select(any_of(c(id_col_name, name_col_name))) |>
    #change name_col_name in case it clashes with concept_name from vocab
    rename_with(~"concept_name_to_check", name_col_name) |>
    omop_join_name() |>
    mutate(check = stringr::str_equal(concept_name_to_check,concept_name))

  df3 <- df2 |> filter(!check)

  if (nrow(df3) > 0)
  {
    warning(nrow(df3), " names and ids don't match\n",df3)
  } else
  {
    message("all ",nrow(df)," names and ids match")
  }

  #return any wronguns
  df3
}


#' super short name func to check concept names
#' @rdname omop_check_names
#' @export
ochecknames <- omop_check_names
