#' query concept records by concept_id from omop concepts table
#'
#' @param c_id concept_id s to get records of
#' @param columns which columns from omop concept table to return. default "all", options c("concept_name") & c("concept_name","domain_id")
#' @export
#' @examples
#' omop_id(196523)
#' #can specify as an integer or not
#' omop_id(196523L)
#'
omop_id <- function(c_id,
                    columns = "all") {

  if (!inherits(c_id,"integer"))  c_id <- as.integer(c_id)

  df1 <- omop_join_name(data.frame(concept_id = c_id), columns = columns)

  return(df1)

}

#' super short name func to get info about a concept_id
#' @rdname omop_id
#' @export
#' @examples
#' oid(43807321L)
oid <- omop_id

