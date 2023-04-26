
<!-- README.md is generated from README.Rmd. Please edit that file -->
<!-- use devtools::build_readme() -->

# omopvocabr

<!-- badges: start -->
<!-- badges: end -->

omopvocabr provides access to a subset of OMOP Common Data Model medical
vocabularies and flexible tidyverse compatible R functions for querying.

## Installation

Install the development version of omopvocabr from
[GitHub](https://github.com/) with:

``` r
# install.packages("remotes")
remotes::install_github("andysouth/omopvocabr")
```

## Example showing what vocabularies are included

Later there may be options to include more.

``` r

library(omopvocabr)
library(dplyr)
#> Warning: package 'dplyr' was built under R version 4.2.2
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union

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
#> Warning: package 'ggplot2' was built under R version 4.2.2
library(forcats)
#> Warning: package 'forcats' was built under R version 4.2.2

ggplot(concept, aes(y=fct_rev(fct_infreq(domain_id)), 
                    fill=vocabulary_id)) +
  geom_bar() +
  labs(y = "domain_id") +
  theme_minimal()
```

<img src="man/figures/README-conceptplot-1.png" width="100%" />
