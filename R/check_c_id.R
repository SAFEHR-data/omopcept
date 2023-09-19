#' check c_id arg to omop_ancestors() and omop_descendants()
#' TODO want to not export but couldn't get to work when not exported
#'
#' @param c_id arg to check : single omop concept_id or exact concept_name to get ancestors of
# @param anc_or_des "ancestors" or "descendants"
#' @export
#' @examples
#' # example code
#' c_id <- 1633308
#' check_c_id(c_id)
#'
check_c_id <- function(c_id) {

  #defaults
  #toreturn <- data.frame(c_id=c_id,name1="ALL")
  #BEWARE the above created pernicious fault when c_id NULL,
  #error in `data.frame()`: ! arguments imply differing number of rows: 0, 1
  toreturn <- data.frame(c_id="none",name1="ALL")

  #if arg is char assume it is exact name & lookup id
  if (is.character(c_id))
  {
    toreturn$name1 <- c_id
    toreturn$c_id <- dplyr::filter(omop_concept(), concept_name == c_id) |>
      dplyr::pull(concept_id, as_vector=TRUE)
  } else if (!is.null(c_id)) {
    toreturn$c_id <- c_id #bugfix this line missing 2023-09-12
    toreturn$name1 <- dplyr::filter(omop_concept(), concept_id == c_id) |>
      dplyr::pull(concept_name, as_vector=TRUE)
  } else {
    toreturn$name1 <- "ALL"
  }

  if (length(c_id) > 1)
  {
    msg <- paste0("can only filter ancestors, descendants or relations of a single concept, you have ",length(c_id),
                  ". Please modify your query to get a single starting concept or none.")
    #TODO, does this stop also stop the func that called ?
    stop(msg)
  }

  return(toreturn)
}
