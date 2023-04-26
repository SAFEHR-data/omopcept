
<!-- README.md is generated from README.Rmd. Please edit that file -->
<!-- use devtools::build_readme() -->

# omopcepts

<!-- badges: start -->
<!-- badges: end -->

omopcepts provides access to a subset of **OMOP** con**cepts** and
flexible tidyverse compatible R functions for querying.

The [OMOP Common Data Model](https://ohdsi.github.io/CommonDataModel/)
is an open standard for health data. “\[It is\] designed to standardize
the structure and content of observational data and to enable efficient
analyses that can produce reliable evidence”.

## Installation

Install the development version of omopcepts with:

``` r
# install.packages("remotes")
remotes::install_github("andysouth/omopcepts")
```

## Join OMOP names onto a dataframe containing \*concept_id

Helps to interpret OMOP data.

``` r

library(omopcepts)

df1 <- data.frame(concept_id=(c(3571338L,4002075L)))

join_omop_name(df1)
#>   concept_id      concept_name
#> 1    3571338 Problem behaviour
#> 2    4002075       BLUE LOTION
```

## Vocabularies included

Initially just a few vocabularies are included to keep the size of the
data file down. Later we may offer option to add other vocabularies.

``` r

library(omopcepts)
library(dplyr)

## showing what vocabs are included
concept |> count(vocabulary_id)
#> # A tibble: 3 × 2
#>   vocabulary_id         n
#>   <chr>             <int>
#> 1 Cancer Modifier    6043
#> 2 LOINC            265076
#> 3 SNOMED          1054935
```

### Numbers of concepts in the package by domain and vocabulary

``` r
library(ggplot2)
library(forcats)

ggplot(concept, aes(y=fct_rev(fct_infreq(domain_id)), 
                    fill=vocabulary_id)) +
  geom_bar() +
  labs(y = "domain_id") +
  theme_minimal()
```

<img src="man/figures/README-conceptplot-1.png" width="100%" />
