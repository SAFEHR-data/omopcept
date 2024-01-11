#' field names of omop concept table
#'
#' @export
#' @examples
#' omop_concept_fields()
omop_concept_fields <- function() {

  #cool that this works even though omop_concept() returns an arrow object
  names(omop_concept())

}

#' super short name func giving field names of omop concept table
#' @rdname omop_concept_fields
#' @export
ocfields <- omop_concept_fields
