
#' conditionally apply a pipe
#'
#' @param df dataframe to apply funct to if cond TRUE
#' @param cond condition whether to run func, not vectorised (should be a single logical)
#' @param func function to run
#' @export
#' @examples
#' #data.frame(a=c(1:5)) |>
#' #   pipe_if(TRUE, \(d) d |>
#' #   mutate(b=a*2))
pipe_if <- function(df, cond, func) {
  if (cond) func(df)
  else df
}

#' Produces a list from string variables suitable for use in join expressions
#'
#' @param lhs string column name for left side of join
#' @param rhs string column name for right side of join
#' @export
#' @examples
#' # left_join(df1,df2, by = dynamic_by(variable,"concept_id"))
dynamic_by <- function(lhs,rhs) {
  res <- c()
  res[lhs] <- rhs
  res
}

#' check c_id arg to omop_ancestors() and omop_descendants()
#' NOT EXPORTED
#'
#' @param c_id arg to check : single omop concept_id or exact concept_name to get ancestors of
#' @param anc_or_des "ancestors" or "descendants"
# @export not exported
check_c_id <- function(c_id,
                       anc_or_des) {

  #defaults
  toreturn <- data.frame(c_id=c_id,name1="ALL")

  #if arg is char assume it is exact name & lookup id
  if (is.character(c_id))
  {
    toreturn$name1 <- c_id
    toreturn$c_id <- filter(omopcept::omop_concept(), concept_name == c_id) |>
      pull(concept_id, as_vector=TRUE)
  } else if (!is.null(c_id)) {
    toreturn$name1 <- filter(omopcept::omop_concept(), concept_id == c_id) |>
      pull(concept_name, as_vector=TRUE)
  } else {
    toreturn$name1 <- "ALL"
  }

  if (length(c_id) > 1)
  {
    msg <- paste0("can only filter ",anc_or_des," of a single concept, you have ",length(c_id),
                  ". Please modify your query to get a single starting concept or none.")
    #TODO, does this stop also stop the func that called ?
    stop(msg)
  }

  return(toreturn)
}
