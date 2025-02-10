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
    # Input validation
    if (is.null(route_concept_id)) {
        stop("route_concept_id must be provided")
    }

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
            # Inhalation
            concept_name %in% c("Respiratory tract", "Inhalation") ~ "Inhal",

            # Instillation
            concept_name %in% c(
                "Urethral", "Ophthalmic", "Epidural", "Intra-articular",
                "Nasojejunal", "Otic", "Intrathecal", "Intravitreal"
            ) ~ "Instill",

            # Nasal
            concept_name %in% c("Nasogastric", "Nasal", "Infiltration") ~ "N",

            # Oral
            concept_name %in% c(
                "Oral", "Gastrostomy", "Jejunostomy", "Oropharyngeal",
                "Paravertebral", "Ocular", "Per Oral", "By mouth"
            ) ~ "O",

            # Parenteral
            concept_name %in% c(
                "Intravenous", "Haemodiafiltration", "Intrapleural",
                "Intravesical", "Intra-arterial", "IV"
            ) ~ "P",

            # Rectal
            concept_name %in% c("Rectal", "Per Rectum") ~ "R",

            # Sublingual/Subcutaneous
            concept_name %in% c(
                "Buccal", "Sublingual", "Oromucosal", "Subcutaneous",
                "Intraosseous", "Dental", "Perineural"
            ) ~ "SL",

            # Transdermal
            concept_name %in% c("Transdermal", "Topical", "Cutaneous") ~ "TD",

            # Vaginal
            concept_name %in% c("Vaginal", "Intrauterine") ~ "V",

            # Implant/Depot
            concept_name %in% c("Intramuscular", "Implant", "Depot") ~ "Implant",
            .default = NA_character_
        ))

    return(route_concepts)
}
