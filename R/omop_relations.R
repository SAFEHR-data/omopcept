#' recursively extract omop concept relations of one passed - immediate relations with indication of relationship
#'
#' TODO need to sort repeated rows
#'
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
#' @param nsteps number of recursions to search
#' @param add_step_column whether to add column with step level, default=TRUE
#' @return a dataframe of concepts and attributes
#' @export
#' @examples
#' omop_relations("Non-invasive blood pressure")
#' omop_relations("Non-invasive blood pressure",nsteps=2,r_ids=c('Is a','Subsumes'))
#' #omop_relations("lenalidomide")
#' #omop_relations(1633308)
#' #chemodrugs <- omop_relations("Cytotoxic chemotherapeutic",v_ids="HemOnc",d_ids="Regimen")
#' #cmde <- omop_relations(v_ids="Cancer Modifier")
omop_relations <- function(c_id=NULL,
                           c_ids=NULL,
                           d_ids=NULL,
                           v_ids=NULL,
                           cc_ids=NULL,
                           standard=NULL,
                           r_ids=NULL,
                           itself=FALSE,
                           names2avoid=c("SNOMED CT core","Defined","Primitive"),
                           messages=TRUE,
                           nsteps=1,
                           add_step_column=TRUE) {


  #checks c_id and gets name (ALL if c_id==NULL)
  res <- check_c_id(c_id)
  c_id0 <- res$c_id[1]
  name1 <- res$name1[1]

  if (messages) message("recursively querying concept relations of: ",name1," - may take more than a few seconds")

  dfall <- NULL

  for(step in 1:nsteps)
  {

    if (messages) message("step ",step," of ",nsteps)

    # get relations of each concept from the previous level
    if (step == 1) {
      prev_c_ids <- c_id0
    } else {
      prev_c_ids <- unique(dfprev$concept_id_2)
    }

    dfprev <- NULL

    for(c_id in prev_c_ids) {

      # get immediate relations
      dfprev1 <- omop_relations1step(c_id=c_id,
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

      #add step column that can be used in plot colouring
      if (add_step_column)
      {
        dfprev1 <- dfprev1 |> mutate(step=step)
        #need a relation to itself to get colouring right
        #in some options standard one gets filtered elsewhere
        #'Is' is a non standard relationship_id
        if (step == 1)
        {
          r_to_itself <- dfprev1 |>
            head(1) |>
            mutate( concept_id_1=c_id0,
                    concept_id_2=c_id0,
                    relationship_id="Is",
                    step=0)

          dfprev1 <- bind_rows(r_to_itself, dfprev1)
        }
      }
      dfprev <- bind_rows(dfprev,dfprev1)
    }

    dfall <- bind_rows(dfall,dfprev)

  }

  #join names onto ids only at end to make faster
  dfall <- dfall |> omop_join_name_all()

  return(dfall)
}

#' super short name func to find relations
#' @rdname omop_relations
#' @export
#' @examples
#' # because of R argument matching, you can just use the first unique letters of
#' # arguments e.g. v for v_ids, cc for cc_ids
#' chemodrugs <- orels("Cytotoxic chemotherapeutic", v="HemOnc", d="Regimen")
orels <- omop_relations
