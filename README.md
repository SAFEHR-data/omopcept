
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

## String search in concept_name field

``` r

concept_names("chemotherapy", v_ids="LOINC")
#> # A tibble: 71 × 7
#>    concept_id concept_name               domai…¹ vocab…² conce…³ stand…⁴ conce…⁵
#>         <int> <chr>                      <chr>   <chr>   <chr>   <chr>   <chr>  
#>  1    3010410 Chemotherapy records       Observ… LOINC   Clinic… S       11486-8
#>  2    3002377 Chemotherapy treatment at… Measur… LOINC   Clinic… S       21881-8
#>  3    3011998 Date 1st chemotherapy tre… Observ… LOINC   Clinic… S       21927-9
#>  4    3003037 Chemotherapy treatment Ca… Measur… LOINC   Clinic… S       21946-9
#>  5    3000897 Reason for no chemotherap… Measur… LOINC   Clinic… S       21951-9
#>  6    3014397 Chemotherapy Cancer        Measur… LOINC   Clinic… S       21967-5
#>  7    3027104 Chemotherapy treatment Ca… Measur… LOINC   Clinic… S       22041-8
#>  8    3037369 2nd course chemotherapy C… Measur… LOINC   Clinic… S       42045-5
#>  9    3032293 3rd course chemotherapy C… Measur… LOINC   Clinic… S       42051-3
#> 10    3028808 4th course chemotherapy C… Measur… LOINC   Clinic… S       42057-0
#> # … with 61 more rows, and abbreviated variable names ¹​domain_id,
#> #   ²​vocabulary_id, ³​concept_class_id, ⁴​standard_concept, ⁵​concept_code
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
