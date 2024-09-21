#' extract omop concept relations of a vector of concept_ids - immediate relations with indication of relationship
#'
#' @param mc_ids a vector of multiple concept_id's to get relations of
#' @param c_ids one or more concept_id to filter by, default NULL for all
#' @param d_ids one or more domain_id to filter by, default NULL for all
#' @param v_ids one or more vocabulary_id to filter by, default NULL for all
#' @param cc_ids one or more concept_class_id to filter by, default NULL for all
#' @param standard one or more standard_concept to filter by, default NULL for all, S,C
#' @param r_ids one or more relationship_id to filter by, default NULL for all, e.g c('Is a','Subsumes')
#' @param itself whether to include relations to concept itself, default=FALSE
#' @param messages whether to print info messages, default=TRUE
#' @param nsteps number of recursions to search
#' @return a dataframe of concepts and attributes
#' @export
#' @examples
#' orm <- omop_relations_multiple(c(3571338L,3655355L), r_ids=c('Is a','Subsumes'), nsteps=1)
#' #omop_relations_multiple(c(3571338L,3655355L), r_ids=c('Is a','Subsumes'), nsteps=2)
omop_relations_multiple <- function(mc_ids,
                                     c_ids=NULL,
                                     d_ids=NULL,
                                     v_ids=NULL,
                                     cc_ids=NULL,
                                     standard=NULL,
                                     r_ids=NULL,
                                     itself=FALSE,
                                     messages=TRUE,
                                     nsteps=1) {

#DEVNOTE from NY first go at dev of multiple
#just by copying recursive and adding a c_id loop at start
#and moving dfall <- NULL to before loop

dfall <- NULL

if (messages) message("multiple-y querying concept relations of: ",length(mc_ids)," concepts - may take more than a few seconds")

cnum <- 0
for(c_id in mc_ids)
{
  cnum <- cnum+1

  #checks c_id and gets name (ALL if c_id==NULL)
  res <- check_c_id(c_id)
  c_id <- res$c_id[1]
  name1 <- res$name1[1]

  if (messages) message("recursively querying relations of: ",name1," ",cnum,"/",length(mc_ids))

  for(step in 1:nsteps)
  {

    if (messages) message("step ",step," of ",nsteps)

    # get relations of each concept from the previous level

    if (step == 1) {
      prev_c_ids <- c_id
    } else {
      prev_c_ids <- unique(dfprev$concept_id_2)
    }

    dfprev <- NULL

    for(c_id in prev_c_ids) {

      # TODO maybe avoid or filter at end duplicate concept_id_1, concept_id_2, relationship_id
      # need to avoid because otherwise it takes ages repeating queries
      if (!c_id %in% dfall$concept_id_1) {

        # get immediate relations
        dfprev1 <- omop_relations(c_id=c_id,
                                 c_ids=c_ids,
                                 d_ids=d_ids,
                                 v_ids=v_ids,
                                 cc_ids=cc_ids,
                                 standard=standard,
                                 r_ids=r_ids,
                                 itself=itself,
                                 messages=messages)

        dfprev <- bind_rows(dfprev,dfprev1)
      }
    }

    dfall <- bind_rows(dfall,dfprev)

  }

} #end of c_id loop


  return(dfall)
}
