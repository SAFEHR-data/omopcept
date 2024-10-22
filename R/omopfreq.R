#' count freq of values in an omop field
#' EXPERIMENTAL may change
#'
#' @param df1 an omop table
#' @param sort whether to sort freqs, default TRUE
#'
#' @export
#' @examples
#' omop_relations("Non-invasive blood pressure") |> omopfreqconceptclass()
#'
omopfreqconceptclass <- function(df1, sort=TRUE) {

  #todo check df1

  df1 |> count(concept_class_id, sort=sort)
}

#' count freq of values in an omop field
#' EXPERIMENTAL may change
#'
#' @param df1 an omop table
#' @param sort whether to sort freqs, default TRUE
#'
#' @export
#' @examples
#' omop_relations("Non-invasive blood pressure") |> omopfreqvocabulary()
#'
omopfreqvocabulary <- function(df1, sort=TRUE) {

  #todo check df1

  df1 |> count(vocabulary_id, sort=sort)
}

#' count freq of values in an omop field
#' EXPERIMENTAL may change
#'
#' @param df1 an omop table
#' @param sort whether to sort freqs, default TRUE
#'
#' @export
#' @examples
#' omop_relations("Non-invasive blood pressure") |> omopfreqdomain()
#'
omopfreqdomain <- function(df1, sort=TRUE) {

  #todo check df1

  df1 |> count(domain_id, sort=sort)
}

#' count freq of values in an omop field
#' EXPERIMENTAL may change
#'
#' @param df1 an omop table
#' @param sort whether to sort freqs, default TRUE
#'
#' @export
#' @examples
#' omop_relations("Non-invasive blood pressure") |> omopfreqrelationship()
#'
omopfreqrelationship <- function(df1, sort=TRUE) {

  #todo check df1

  df1 |> count(relationship_id, sort=sort)
}

#' super short name func to count freq of values in an omop field
#' @rdname omopfreqconceptclass
#' @export
ofreqcc <- omopfreqconceptclass
#' super short name func to count freq of values in an omop field
#' @rdname omopfreqvocabulary
#' @export
ofreqv <- omopfreqvocabulary
#' super short name func to count freq of values in an omop field
#' @rdname omopfreqdomain
#' @export
ofreqd <- omopfreqdomain
#' super short name func to count freq of values in an omop field
#' @rdname omopfreqrelationship
#' @export
ofreqr <- omopfreqrelationship

