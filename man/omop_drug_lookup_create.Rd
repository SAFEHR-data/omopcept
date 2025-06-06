% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/omop_drug_lookup_create.R
\name{omop_drug_lookup_create}
\alias{omop_drug_lookup_create}
\title{create a lookup table from drug concepts in vocabs \code{RxNorm} and/or \verb{RxNorm Extension} to ATC drug classes}
\usage{
omop_drug_lookup_create(
  df = NULL,
  name_drug_concept_id = "drug_concept_id",
  concept_class_ids = c("Ingredient"),
  drug_concept_vocabs = c("RxNorm", "RxNorm Extension"),
  outfile = NULL,
  messages = TRUE
)
}
\arguments{
\item{df}{optional table containing drug concept ids}

\item{name_drug_concept_id}{optional name of column containing drug concept ids, default="drug_concept_id"}

\item{concept_class_ids}{optional filter of concept_class_ids, multiple allowed, default = "Ingredient", ignored if a table is passed as df}

\item{drug_concept_vocabs}{vocabs containing drug concepts default = c("RxNorm","RxNorm Extension") option just = "RxNorm Extension"}

\item{outfile}{name for output file default=NULL for no file}

\item{messages}{whether to print info messages, default=TRUE}
}
\value{
data frame with drug concepts and ATC classes
}
\description{
EXPERIMENTAL
either all drug concepts filtered by concept_class_id
OR all drug concepts in a passed table (e.g. drug_exposure)
\href{https://www.nlm.nih.gov/research/umls/rxnorm/sourcereleasedocs/atc.html}{ATC} is a WHO drug classification incorporated within RxNorm. Anatomical Therapeutic Chemical Classification System.
}
\examples{
#to create a lookup table for all Ingredients
drug_lookup = omop_drug_lookup_create()
#counting numbers of concepts under each level in ATC hierarchy
}
