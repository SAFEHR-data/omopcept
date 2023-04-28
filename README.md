
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

OMOP is maintained by OHDSI (pronounced “Odyssey”). “The Observational
Health Data Sciences and Informatics program is a multi-stakeholder,
interdisciplinary collaborative that strives to improve medical decision
making and bring better health outcomes to patients around the world.”

OMOP concepts can be searched and downloaded from [Athena – the OHDSI
vocabularies repository](https://athena.ohdsi.org).

This package provides R tools to interact with the concepts in a more
reproducible way.

## Installation

Install the development version of omopcepts with:

``` r
# install.packages("remotes")

remotes::install_github("andysouth/omopcepts")
```

## Concept data

OMOP vocab data downloaded from Athena includes a table called
CONCEPT.csv, that is used in this package.

| fields           | about                               | query_arguments |
|:-----------------|:------------------------------------|:----------------|
| concept_id       | unique id                           | c_ids           |
| concept_name     | descriptive name                    | pattern         |
| domain_id        | e.g. drug, measurement              | d_ids           |
| vocabulary_id    | e.g. LOINC, SNOMED                  | v_ids           |
| concept_class_id | e.g. Clinical Observation, Organism | cc_ids          |
| standard_concept | standard or not                     | standard        |
| concept_code     | source code                         |                 |

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

concept_names("chemotherapy", v_ids=c("LOINC","SNOMED"), d_ids=c("Observation","Procedure"))
#> # A tibble: 297 × 7
#>    concept_id concept_name               domai…¹ vocab…² conce…³ stand…⁴ conce…⁵
#>         <int> <chr>                      <chr>   <chr>   <chr>   <chr>   <chr>  
#>  1    3010410 Chemotherapy records       Observ… LOINC   Clinic… S       11486-8
#>  2    3011998 Date 1st chemotherapy tre… Observ… LOINC   Clinic… S       21927-9
#>  3    3046488 Chemotherapy [Minimum Dat… Observ… LOINC   Survey  S       45841-4
#>  4   40758122 Chemotherapy in last 14 d… Observ… LOINC   Survey  S       54992-3
#>  5   40758123 Chemotherapy in last 14 d… Observ… LOINC   Survey  S       54993-1
#>  6   40766658 Type of chemotherapy [Phe… Observ… LOINC   Clinic… S       63938-5
#>  7   40768860 Cancer chemotherapy recei… Observ… LOINC   Clinic… S       66178-5
#>  8   40770073 Have you been treated wit… Observ… LOINC   Clinic… S       67446-5
#>  9   40770096 History of Chemotherapy o… Observ… LOINC   Clinic… S       67469-7
#> 10   36305649 Chemotherapy infusion sta… Observ… LOINC   Clinic… S       88060-9
#> # … with 287 more rows, and abbreviated variable names ¹​domain_id,
#> #   ²​vocabulary_id, ³​concept_class_id, ⁴​standard_concept, ⁵​concept_code
```

## Join OMOP names onto a dataframe containing concept ids in a column called \*concept_id

Helps to interpret OMOP data.

``` r


data.frame(concept_id=(c(3571338L,4002075L))) |> 
  join_omop_name()
#>   concept_id      concept_name
#> 1    3571338 Problem behaviour
#> 2    4002075       BLUE LOTION
 

data.frame(drug_concept_id=(c(4000794L,4002592L))) |> 
  join_omop_name(namestart="drug")
#>   drug_concept_id       drug_concept_name
#> 1         4000794                BUZZ OFF
#> 2         4002592 DEXAMETHASONE INJECTION
```

## Vocabularies included

Initially just a few vocabularies are included to keep the size of the
data file down. Later we may offer option to add other vocabularies.

``` r

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
