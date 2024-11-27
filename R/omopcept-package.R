#' @keywords internal
"_PACKAGE"

## usethis namespace: start
#' @importFrom dplyr filter
#' @importFrom dplyr left_join
#' @importFrom dplyr right_join
#' @importFrom dplyr semi_join
#' @importFrom dplyr mutate
#' @importFrom dplyr rename_with
#' @importFrom dplyr select
#' @importFrom dplyr collect
#' @importFrom dplyr pull
#' @importFrom dplyr rename
#' @importFrom dplyr relocate
#' @importFrom dplyr join_by
#' @importFrom dplyr slice_head
#' @importFrom dplyr bind_rows
#' @importFrom dplyr group_by
#' @importFrom dplyr any_of
#' @importFrom dplyr contains
#' @importFrom dplyr tibble
#' @importFrom dplyr count
#'
#' @importFrom rlang .data
#'
#' @importFrom stringr regex
#' @importFrom stringr str_detect
#'
#' @importFrom arrow open_dataset
#' @importFrom arrow write_parquet
#' @importFrom arrow read_parquet
#'
#' @importFrom readr read_tsv
#' @importFrom readr read_csv
#' @importFrom readr write_csv
#'
#' @importFrom lubridate ymd
#'
#' @importFrom utils globalVariables
#' @importFrom utils head
#'
#' @importFrom tools file_path_sans_ext
#'
## only used in omop_cdm_read() & omop_cdm_table_read()
## not imported here, install checked in the function
# @importFrom fs dir_ls
# @importFrom purrr map
#
# trying importing whole packages rather than having to fiddle
# with xtra functions as they crop up
# @import dplyr
#' @import ggplot2
# @import igraph
# @import ggraph

# @importFrom tidygraph tbl_graph
# @importFrom igraph degree
# @importFrom igraph V
# @importFrom ggraph ggraph
# @importFrom ggraph geom_edge_link
#'
# @importFrom arrow arrow_match_substring_regex
## usethis namespace: end
#NULL

#to get rid of check notes : "no visible binding for global variable"
utils::globalVariables(c('concept_name', 'concept_id','concept_code',
                         'ancestor_concept_id','descendant_concept_id',
                         'ancestor_concept_name','descendant_concept_name',
                         'ancestor_name','descendant_name',
                         'relationship_id','domain_id','vocabulary_id','concept_class_id',
                         'standard_concept',
                         'min_levels_of_separation',
                         'concept_id_1','concept_id_2',
                         'concept_name_1','concept_name_2',
                         'valid_start_date','valid_end_date','invalid_reason',
                         'from', 'to', 'name', 'connections',
                         'concept_name_to_check','check',
                         'sizecolumn'))
