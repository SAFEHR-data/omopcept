
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


