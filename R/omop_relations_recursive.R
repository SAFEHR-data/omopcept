#' recursively extract omop concept relations of one passed - immediate relations with indication of relationship
#'
# TODO could add recurse_level column for colouring plots
# TODO I could rename this to omop_relations() & rename that to omop_rel1() and not export it
# num_recurse==1 is same as what omop_relations is currently so can just have that as default
#' @param c_id single omop concept_id or exact concept_name to get relations of, default NULL returns all
#' @param c_ids one or more concept_id to filter by, default NULL for all
#' @param d_ids one or more domain_id to filter by, default NULL for all
#' @param v_ids one or more vocabulary_id to filter by, default NULL for all
#' @param cc_ids one or more concept_class_id to filter by, default NULL for all
#' @param standard one or more standard_concept to filter by, default NULL for all, S,C
#' @param r_ids one or more relationship_id to filter by, default NULL for all, e.g c('Is a','Subsumes')
#' @param itself whether to include relations to concept itself, default=FALSE
#' @param names2avoid concept names to avoid, defaults to generic concepts with lots relations, can be set to NULL
#' @param messages whether to print info messages, default=TRUE
#' @param num_recurse number of recursions to search
#' @param add_recurse_column whether to add column with recurse level, default=TRUE
#' @return a dataframe of concepts and attributes
#' @export
#' @examples
#' r1 <- omop_relations_recursive("Non-invasive blood pressure", num_recurse=1)
#' #omop_relations_recursive("Non-invasive blood pressure", r_ids=c('Is a','Subsumes'), num_recurse=2)
omop_relations_recursive <- function(c_id=NULL,
                                     c_ids=NULL,
                                     d_ids=NULL,
                                     v_ids=NULL,
                                     cc_ids=NULL,
                                     standard=NULL,
                                     r_ids=NULL,
                                     itself=FALSE,
                                     names2avoid=c("SNOMED CT core","Defined","Primitive"),
                                     messages=TRUE,
                                     num_recurse=1,
                                     add_recurse_column=TRUE) {


  #checks c_id and gets name (ALL if c_id==NULL)
  res <- check_c_id(c_id)
  c_id <- res$c_id[1]
  name1 <- res$name1[1]

  if (messages) message("recursively querying concept relations of: ",name1," - may take more than a few seconds")

  dfall <- NULL

  for(recurse in 1:num_recurse)
  {

    if (messages) message("recurse level ",recurse," of ",num_recurse)

    # get relations of each concept from the previous level
    # TODO maybe avoid or filter at end duplicate concept_id_1, concept_id_2, relationship_id

    if (recurse == 1) {
      prev_c_ids <- c_id
    } else {
      prev_c_ids <- unique(dfprev$concept_id_2)
    }

    dfprev <- NULL

    for(c_id in prev_c_ids) {

      # get immediate relations
      dfprev1 <- omop_relations(c_id=c_id,
                               c_ids=c_ids,
                               d_ids=d_ids,
                               v_ids=v_ids,
                               cc_ids=cc_ids,
                               standard=standard,
                               r_ids=r_ids,
                               itself=itself,
                               names2avoid=names2avoid,
                               messages=messages,
                               join_names=FALSE)

      if (add_recurse_column)
        dfprev1 <- dfprev1 |> mutate(recurse_level=recurse)

      #TODO could add recurse_level column for colouring plots
      dfprev <- bind_rows(dfprev,dfprev1)
    }

    dfall <- bind_rows(dfall,dfprev)

  }

  #join names onto ids only at end to make faster
  dfall <- dfall |> omop_join_name_all()

  return(dfall)
}
