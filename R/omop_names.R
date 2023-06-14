#' string search of concept_name in omop concepts table
#'
# @param df1 dataframe containing concept_name field, if null uses concept
#' @param findstring to search for or regex, e.g. "^a" to find those starting with A
#' @param ignore_case ignore case in string comparison, default TRUE
# @param negate If TRUE, return non-matching elements, default FALSE
#' @param c_ids one or more concept_id to filter by, default NULL for all
#' @param d_ids one or more domain_id to filter by, default NULL for all
#' @param v_ids one or more vocabulary_id to filter by, default NULL for all
#' @param cc_ids one or more concept_class_id to filter by, default NULL for all
#' @param standard one or more standard_concept to filter by, default NULL for all, S,C
#' @param messages whether to print info messages, default=TRUE
#' @export
#' @examples
#' omop_names("AJCC/UICC Stage")
#' omop_names("chemotherapy", v_ids="LOINC")
#' omop_names("chemotherapy", v_ids=c("LOINC","SNOMED"), d_ids=c("Observation","Procedure"))
#' #set the findstring to "" to get all rows satisfying the other conditions
#' omop_names("", v_ids="Gender")
#' #omop_names("", d_ids="Type Concept", standard="S")

omop_names <- function(#df1 = NULL,
  findstring,
  ignore_case = TRUE,
  #negate = FALSE,
  c_ids=NULL,
  d_ids=NULL,
  v_ids=NULL,
  cc_ids=NULL,
  standard=NULL,
  messages=TRUE) {

  df1 <- omopcept::omop_concept() |>

    #TODO put negate back in if possible
    #but get Error: filter expressions must be either an expression or a list of expressions

    filter(arrow_match_substring_regex(concept_name,
                                       options=list(pattern=findstring,
                                                    ignore_case=ignore_case))) |>

    #hmmmmm this was working then suddenly stopped
    #now: Error: Filter expression not supported for Arrow Datasets

    collect() |>
    #cool this is pretty fast running these filters after collect
    #probably the case as long as above filter produces reasonably small table
    omop_filter_concepts(c_ids=c_ids, d_ids=d_ids, v_ids=v_ids, cc_ids=cc_ids, standard=standard) #|>
    #filter(str_detect(concept_name, regex(findstring, ignore_case=ignore_case))) |>

    #filter(grepl(findstring,.data$concept_name, ignore.case=ignore_case))
    #filter(stringr::str_detect(.data$concept_name, stringr::regex(findstring, ignore_case=ignore_case), negate=negate)) |>

  if (messages) message("returning ",nrow(df1)," concepts")

  return(df1)

  # this allowed passing dataframe instead of concepts
  # but caused confusing behaviour when omop_names("test")
  # if (is.null(df1)) df1 <- concept
  #
  # if (!is.null(findstring))
  # {
  #   df1 <- df1 |>
  #     filter(str_detect(concept_name, findstring)) |>
  #     omop_filter_concepts(c_ids=c_ids, d_ids=d_ids, v_ids=v_ids, cc_ids=cc_ids, standard=standard)
  # }

}


#' super short name func to search concepts by concept_name
#' @rdname omop_names
#' @export
#' @examples
#' onames("chemotherapy", v_ids="LOINC")
#' # because of R argument matching, you can just use the first unique letters of
#' # arguments e.g. v for v_ids, cc for cc_ids
#' # to get all clinical drugs starting with A
#' onames("^a", d="DRUG", v="SNOMED", cc="Clinical Drug")
#' # to get all 'chop' cancer regimens
#' chops <- onames("chop", d="Regimen")
onames <- omop_names



#ISSUE is that can't pass a string varible within a function - its not recognised by arrow
#but can pass stringvar outside of a function

#TODO read this to see if it can solve my issue
#https://arrow.apache.org/docs/r/articles/developers/writing_bindings.html

#or may be able to call arrow C++ functions directly
#apache arrow R cookbook is good on this with list of C++ functions
#https://arrow.apache.org/cookbook/r/manipulating-data---tables.html#use-r-functions-in-dplyr-verbs-in-arrow
#list_compute_functions() gives list of C++ functions
#C++ func doc : https://arrow.apache.org/docs/cpp/compute.html#available-functions
#looking at the output without collect() shows the C++ code
#omop_concept() |> filter(str_detect(str_to_lower(concept_name),str_to_lower(stringvar)))
#* Filter: match_substring_regex(utf8_lower(concept_name), {pattern="chemo", ignore_case=false})
#For functions which don’t have a base R or tidyverse equivalent,
#or you want to supply custom options, you can call them by prefixing their name with “arrow_”

#but none of these work
# omop_concept() |> arrow_match_substring_regex(utf8_lower(concept_name), {pattern="chemo", ignore_case=false})
# omop_concept() |> filter(arrow_match_substring_regex(utf8_lower(concept_name), {pattern="chemo", ignore_case=false}))
# omop_concept() |> filter(arrow_match_substring_regex(utf8_lower(concept_name), {pattern=stringvar, ignore_case=false}))
# omop_concept() |> arrow_match_substring_regex(concept_name, {pattern="chemo"})

# #Hurrah! these do work
# omop_concept() |> filter(arrow_match_substring_regex(concept_name, options=list(pattern="chemo"))) |> collect()
# omop_concept() |> filter(arrow_match_substring_regex(concept_name, options=list(pattern=stringvar))) |> collect()
# #can I get that to work in a function ?
# #Hurrah2! Yes
# concept_codes2 <- function(findstring){ omop_concept() |> filter(arrow_match_substring_regex(concept_name, options=list(pattern=findstring))) |> collect() }
# concept_codes2("chemo")

# can register a scalar function within arrow
# https://arrow.apache.org/docs/r/articles/data_wrangling.html#registering-custom-bindings
# BUT maybe my func is vector rather than scalar ?
# detect_str_arrow <- function(context, string) {
#   replace <- c(`'` = "", `"` = "", `-` = "", `\\.` = "_", ` ` = "_")
#   string %>%
#     stringr::str_replace_all(replace) %>%
#     stringr::str_to_lower() %>%
#     stringi::stri_trans_general(id = "Latin-ASCII")
# }
# #To call this within an arrow/dplyr pipeline, it needs to be registered:
#   register_scalar_function(
#     name = "to_snake_name",
#     fun = to_snake_name,
#     in_type = utf8(),
#     out_type = utf8(),
#     auto_convert = TRUE
#   )
# #Once registered, the following works:
#   sw %>%
#     mutate(name, snake_name = to_snake_name(name), .keep = "none") %>%
#     collect()
