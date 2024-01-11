#' field names of omop concept relationship table
#'
#' @export
#' @examples
#' omop_concept_relationship_fields()
omop_concept_relationship_fields <- function() {

  names(omop_concept_relationship())

}

#' super short name func giving field names of omop concept relationship table
#' @rdname omop_concept_relationship_fields
#' @export
ocrfields <- omop_concept_relationship_fields
