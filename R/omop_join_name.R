#' join omop concept name and other concept columns onto a dataframe with a *_concept_id column
#'
#' adds (namestart)_name based on (namestart)_concept_id
#' e.g. drug_concept_id to get drug_name
#'
#' @param df dataframe
#' @param namestart start of *_concept_id column, if "" will join on concept_name, ignored if namefull used
#' @param namefull optional full name of concept_id column, if default "" namestart used
#' @param columns which columns from omop concept table to join on. Option of "all", default=c("concept_name"), e.g. c("concept_name","domain_id")
#' @export
#' @examples
#' data.frame(concept_id=(c(3571338L,4002075L))) |> omop_join_name()
#' data.frame(drug_concept_id=(c(4000794L,4002592L))) |> omop_join_name(namestart="drug")
#' #if drug_exposure loaded:
#' #df2 <- drug_exposure |> distinct(route_concept_id) |> omop_join_name(namestart="route")
#' #df3 <- omop_concept_relationship() |> head() |>
#' #       dplyr::collect() |> omop_join_name(namefull="concept_id_1")
#' #want to try to catch the error in the first 2 NA column
#' #but not yet working
#' #could try purrr::possibly
#' #data.frame(bad_concept_id=(c(NA,NA)),concept_id=(c(3571338L,4002075L))) |> omop_join_name_all()
omop_join_name <- function(df,
                           namestart = "",
                           namefull = "",
                           columns = c("concept_name")
                           ) {

  #"" is to cope with concept_id from omop_join_name_all()
  if (namefull != "") id_col_name <- namefull
  else if (namestart == "") id_col_name <- "concept_id"
  else id_col_name  <- paste0(namestart,"_concept_id")

  #e.g. ancestor_concept_id to ancestor_name
  name_col_name <- sub("_id","_name",id_col_name)
  #maybe offer an option of
  #name_col_name <- sub("_concept_id","_name",id_col_name)

  from_omop_concept <- omopcept::omop_concept()

  if (columns[1] != "all" )
  {
    columns2join <- c("concept_id",columns)

    #TODO protect against problem if more than 1 id column it can become .x,.y etc.
    #this is how it worked before
    # if (domain == TRUE & !("domain_id" %in% names(df)))
    #   columns2join <- c(columns2join, "domain_id")
    # if (vocabulary == TRUE & !("vocabulary_id" %in% names(df)))
    #   columns2join <- c(columns2join, "vocabulary_id")
    # if (concept_class == TRUE & !("concept_class_id" %in% names(df)))
    #   columns2join <- c(columns2join, "concept_class_id")
    # if (concept_code == TRUE & !("concept_code" %in% names(df)))
    #   columns2join <- c(columns2join, "concept_code")
    # if (standard == TRUE & !("standard_concept" %in% names(df)))
    #   columns2join <- c(columns2join, "standard_concept")
    # if (valid_dates == TRUE & !("valid_start_date" %in% names(df)))
    #   columns2join <- c(columns2join, "valid_start_date", "valid_end_date")
    # if (invalid == TRUE & !("invalid_reason" %in% names(df)))
    #   columns2join <- c(columns2join, "invalid_reason")


    from_omop_concept <- from_omop_concept |>
      select(any_of(columns2join))
  }

  #beware rename concept_name column before joining in case
  #there is already a concept_name column in df
  #condition protects against error when called from omop_id() with no name column
  if (name_col_name != "concept_name")
  {
    from_omop_concept <- from_omop_concept |>
      rename_with(~name_col_name, concept_name)
  }

  #beware tricky code
  #join works fast within arrow by
  #a. put arg table into arrow (if not already)
  #to avoid Error in `auto_copy()`:! `x` and `y` must share the same src.
  #b. using {{}} so that an arg can be used in join_by

  #allows func to accept either a df or an "arrow_dplyr_query" e.g. from omop_ancestors()
  #otherwise get "only data frames are allowed as unnamed arguments to be auto spliced"
  if (inherits(df,"data.frame")) df <- arrow::arrow_table(df)

  #protect against the function (& the _all version) failing
  #because e.g. all values are NA which can lead to
  #Incompatible data types for corresponding join field keys
  #can't do class on the column because it may just be an arrow query
  #could test the column & if all NA there is no point in joining anyway !!
  #but tricky to test if all NA when it is an arrow query, would have to collect
  #more generally can try-catch to avoid *_all failing for all tables when just one is at fault

  tryCatch(
    expr = {

      df <- df |>
        left_join(from_omop_concept, by = join_by({{id_col_name}} == "concept_id")) |>
        #move name column next to id to make output more readable
        #any_of protects if no name column
        dplyr::relocate(any_of(name_col_name), .after = id_col_name) |>
        collect()

    },
    error = function(e){
      first_values <- df |> head() |> collect() |> select(id_col_name) |> pull()
      message('problem with column ', id_col_name, " not able to join names. First values = ", first_values)
      #print(e)
    },
    finally = {
      #message('All done, quitting.')
      return(df)
    })

}



#' super short name func to join concept_names on
#' @rdname omop_join_name
#' @export
#' @examples
#' data.frame(drug_concept_id=(c(4000794L,4002592L))) |> ojoin(namestart="drug")
ojoin <- omop_join_name


#' join omop concept names onto all *_concept_id columns in a dataframe
#'
#' adds \\*_name based on \\*_concept_id
#' e.g. drug_concept_id to get drug_name etc.
#'
#' @param df dataframe, or a list of multiple dataframes
#' @param columns which columns from omop concept table to join on. Option of "all", default=c("concept_name"), e.g. c("concept_name","domain_id")
#' @return dataframe based on input df with 1 extra column added for each concept_id column, or a list of multiple dataframes
#' @export
#' @examples
#' data.frame(concept_id=(c(3571338L,3655355L)),
#'            drug_concept_id=(c(4000794L,35628998L))) |>
#'            omop_join_name_all()
#' data.frame(domain_concept_id_1=(c(3571338L,3655355L))) |> omop_join_name_all()
#' #examples commented for now mostly to speed package build
#' #data.frame(route_concept_id=(c(4132161L,	4171047L)),
#' #          drug_concept_id=(c(1550560L,	35780880L))) |>
#' #          omop_join_name_all()
#' #df2 <- drug_exposure |>
#' #       head(100)) |>
#' #       omop_join_name_all()
#' #df3 <- omop_concept_relationship() |> head() |>
#' #          dplyr::collect() |> omop_join_name_all()
#' # multiple tables in a list
#' #df4 <- data.frame(concept_id=(c(3571338L,3655355L)))
#' #list1 <- list(df4,df4)
#' #list2 <- list1 |> omop_join_name_all(columns="all")
omop_join_name_all <- function(df,
                               columns = c("concept_name")
                               ) {

  #to apply to list of multiple tables
  #if inherits from list use lapply to call func itself on components
  if (inherits(df,'list')) {
    alltables <- lapply(df, function(x) omop_join_name_all(x, columns = columns))
    return(alltables)
  }

  #logic
  #if colname contains *_concept_id do omop_join_name(namestart=*)
  #else if colname contains concept_id do omop_join_name(namefull=colname)

  colnames <- df |>
    select(any_of(contains("concept_id"))) |>
    names() |>
    stringr::str_remove("_concept_id$")

  for(cname in colnames)
  {
    if (str_detect(cname,"concept_id")) {
          df <- df |> omop_join_name(namefull=cname, columns = columns )
    } else
          df <- df |> omop_join_name(namestart=cname, columns = columns )
  }

  return(df)
}

#' super short name func to join all concept_names to a table
#' @rdname omop_join_name_all
#' @export
#' @examples
#' data.frame(concept_id=(c(3571338L,3655355L)),
#'            drug_concept_id=(c(4000794L,35628998L))) |>
#'            ojoinall()
ojoinall <- omop_join_name_all
