#' check c_id arg to omop_ancestors() and omop_descendants()
#' TODO want to not export but couldn't get to work when not exported
#'
#' @param c_id arg to check : single omop concept_id or exact concept_name to get ancestors of
#' @param anc_or_des "ancestors" or "descendants"
#' @export
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
