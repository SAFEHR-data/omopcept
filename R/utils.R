
#' conditionally apply a pipe
#'
#' @param df dataframe to apply funct to if cond TRUE
#' @param cond condition whether to run func, not vectorised (should be a single logical)
#' @param func function to run
#' @example data.frame(a=c(1:5)) |> pipe_if(TRUE, \(d) d |> mutate(b=a*2))
pipe_if <- function(df, cond, func) {
  if (cond) func(df)
  else df
}

#' Produces a list from string variables suitable for use in join expressions
#' For example, (by=dynamic_by(variable,"rhs"))
dynamic_by <- function(lhs,rhs) {
  res <- c()
  res[lhs] <- rhs
  res
}
