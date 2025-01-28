#' Get the ATC route of administration for a given OMOP route_concept_id
#'
#' @param route_concept_id A numeric vector or list containing OMOP concept IDs for routes of administration
#' @return A data frame containing the original concept_id, concept_name, and mapped ATC route
#' @export
#' @examples
#' # Get ATC route for a single route concept
#' omop_atc_route(4128794)
#'
#' # Get ATC routes for multiple route concepts
#' omop_atc_route(c(4128794, 4112421))
omop_atc_route <- function(route_concept_id) {
    # load concepts table and filter for route concepts
    concepts <- arrow::open_dataset(
        file.path(
            tools::R_user_dir("omopcept",
                which = "cache"
            ), "concept.parquet"
        )
    )
    route_ids <- unlist(route_concept_id)
    route_concepts <- concepts |>
        arrow::to_duckdb() |>
        dplyr::filter(concept_id %in% !!route_ids) |>
        dplyr::select(concept_id, concept_name) |>
        dplyr::compute() |>
        dplyr::collect()

    # THIS LIST IS NEITHER COMPLETE NOR CORRECT
    # I did not find a way to get the correct ATC route from the concept_name
    # I build this list on top of the one in the validate article from RAMSES
    # https://ramses-antibiotics.web.app/articles/load-data.html
    # TODO: Add more routes and correct the ones that are wrong
    route_concepts <- route_concepts |>
        dplyr::mutate(atc_route = dplyr::case_when(
            # concept_name %in% c("No matching concept") ~ NA_character_,
            concept_name %in% c("Respiratory trac") ~ "Inhal",
            concept_name %in% c("Urethral", "Ophthalmic", "Epidural", "Intra-articula", "Nasojejunal", "Otic") ~ "Instill",
            concept_name %in% c("Nasogastric", "Nasal", "Infiltration") ~ "N",
            concept_name %in% c("Oral", "Gastrostomy", "Jejunostomy", "Oropharyngeal", "Paravertebral", "Ocula") ~ "O",
            concept_name %in% c("Intravenous", "Haemodiafiltration", "Intrapleural", "Intravesical", "Intra-arterial", "Intravitreal", "Intrathecal") ~ "P",
            concept_name %in% c("Rectal") ~ "R",
            concept_name %in% c("Buccal", "Sublingual", "Oromucosal", "Subcutaneous", "Intraosseous", "Dental", "Otic", "Perineural") ~ "SL",
            concept_name %in% c("Transdermal", "Topical") ~ "TD",
            concept_name %in% c("Vaginal", "Intrauterin") ~ "V",
            concept_name %in% c("Intramuscula") ~ "Implant",
            .default = NA_character_
        ))

    return(route_concepts)
}
