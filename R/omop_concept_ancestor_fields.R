#' field names of omop concept ancestor table
#'
#' @export
#' @examples
#' omop_concept_ancestor_fields()
omop_concept_ancestor_fields <- function() {

  names(omop_concept_ancestor())

}

#' super short name func giving field names of omop concept ancestor table
#' @rdname omop_concept_ancestor_fields
#' @export
ocafields <- omop_concept_ancestor_fields
