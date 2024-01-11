#' return domain_id s for concept_id s
#'
#' @param c_id concept_id s to get domain_id s for
#' @export
#' @examples
#' omop_domain(c(196523,43807321))
#' #can specify as an integer or not
#'
omop_domain <- function(c_id) {

  if (!inherits(c_id,"integer"))  c_id <- as.integer(c_id)

  df1 <- omop_join_name(data.frame(concept_id = c_id), columns = "domain_id")

  return(df1)

}

