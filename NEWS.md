# omopcept 0.0.6.2 2024-12-18 DEV version

* `omop_graph()` working on raw relations table e.g. `omop_concept_relationship() |> head(50) |> collect() |> omop_graph(nodecolourvar="relationship_id", nodetxtsize=3)`

# omopcept 0.0.6.1 2024-12-18

* add helper functions `omopfreq*()` for counting frequency of values in `domain` `conceptclass` `relationship` or `vocabulary`
* split out `omop_graph_calc()` for separate calculation of nodes & edges, either a) to enable other data to be joined on (e.g. num records) for visualisation or b) so nodes & edges can be passed to an alternative renderer (as yet unknown)   
* split out `omop_graph_vis()` to enable  other data to be joined on (e.g. num records) for visualisation
* `omop_graph()` gets separate args `nodesizevar` and `nodesize` so size can be set by a variable column and/or a sizing param
* add `omop_drug_lookup_create()` to create a lookup table from drugs in `RxNorm` or `RxNorm Extension` to `ATC` drug classes at all levels
* update omop vocabs & default location for pre-processed ones moved to Github

# omopcept 0.0.6.0 2024-09-26

### BREAKING CHANGES
To make use of `omop_relations()` easier and more intuitive
* `omop_relations_recursive()` arg `num_recurse` changed to `nsteps`
* `omop_relations_recursive()` renamed to `omop_relations()` which in turn renamed to `omop_relations1step()`
* `omop_relations()` now optionally adds column `step` for plot colouring, replacing `recurse_level`

### non-breaking changes
* `omop_graph()` gets args `caption` `captionsize` `captionjust` `captioncolour`
* repository moved from `andysouth` to `SAFEHR-data`
* issue fixed in `omop_relations` & `omop_graph()` with colouring plots by `recurse_level`
* `omop_grap()` gets `nodesize` arg (NOT functioning yet)
* `omop_grap()` gets `canvas` arg to set plot size, one of "A4","A4l","A3","A3l","A2","A2l","A1","A1l","A0","A0l","slide","slidehalf"

# omopcept 0.0.5.9 2024-07-24

* `omop_graph()` gets args `palettedirection` `nodetxtnudgex` `nodetxtnudgey` `titlejust` `backcolour`

* `omop_relations_recursive()` gets arg `add_recurse_column` to add a column with `recurse_level` that can be used to colour

# omopcept 0.0.5.8 2024-07-09

* bugfix in `omop_cdm_combine()`, defend against 'non-numeric argument to binary operator'

# omopcept 0.0.5.7 2024-06-12

* `omop_cdm_combine()` outputs msg of uniquefied fields

# omopcept 0.0.5.6 2024-06-11

* `omop_cdm_combine()` refactored to make all IDs unique that it didn't before
* `omop_relations()` gets `names2avoid` arg
* `omop_graph()` gets args `nodealpha` `edgealpha` `edgewidth`

# omopcept 0.0.5.5 2024-05-10

* `omop_cdm_combine()` gets `make_care_site_id_unique` & `add_care_site_name_to_person_id_tables` arg

# omopcept 0.0.5.4 2024-05-09

* `omop_cdm_combine()` gets `make_person_id_unique` arg

# omopcept 0.0.5.3 2024-05-08

* `omop_graph()` gets args `nodetxtangle` `legendshow`
* read in omop cdm instance with `omop_cdm_read()` & `omop_cdm_table_read()`
* combine cdm instances with `omop_cdm_combine()`

# omopcept 0.0.5.2 2024-03-13

* add to `omop_codes()` exact & fixed args, e.g. easier to search for loinc codes

# omopcept 0.0.5.1 2024-03-01

* `omop_join_name()` protects against concept_id columns that are not integer

# omopcept 0.0.5.0 2024-01-30

* started vignette on hierarchy, access with `vignette("hierarchy-for-blood-counts")`
* `omop_relations()` add arg `itself` whether to include relations to concept itself, default=FALSE
* `omop_names()` add an arg `fixed` (default=FALSE) that when true matches string as-is
* `omop_domain()` return domain_id s for concept_id s
* `omop_id()` now accepts multiple ids and can specify columns to return + a bit faster
* `omop_concept_fields()` `omop_concept_ancestor_fields()` `omop_concept_relationship_fields()` to get column names of omop tables, short name equivalents `ocfields()` `ocafields()` `ocrfields()`
* `omop_join_name()` made much faster by not using copy=true in join
* BREAKING CHANGE `omop_join_name()` & `omop_join_name_all()` refactor and simplify column args
* `omop_join_name()` arg columns="all" to join all concept table columns


# omopcept 0.0.4.0 2024-01-08

* fix bug in omop_join_names_all() - Error in class(df) == "list"


# omopcept 0.0.3.0 2024-01-05

* `omop_names()` added argument `exact=` TRUE for exact string search, "start" for exact start, "end" for exact end
* `omop_check_names()` to check that concept names and ids match in a passed table
* fix bug in `omop_join_name_all()` to cope with "domain_concept_id_1" from FACT_RELATIONSHIP
* `omop_join_name_all()` now copes with a list of multiple tables
* update readme about vocabulary download options


# omopcept 0.0.2.0 2023-12-27

* graph pkgs igraph,tidygraph,ggraph moved from imports to suggests
* `num_recurse` loop start at 1 rather than 0 in `omop_relations_multiple()` & `omop_relations_recursive()`


# omopcept 0.0.1.1 2023-11-15

* `omop_vocabs_preprocess()` read in omop vocab csvs, preprocess to parquet save in package cache
* `omop_vocab_table_save()` renamed from `omop_download()`
* `omop_graph()` auto file naming
* `omop_relations()` add `r_ids` arg to filter by `relationship_id` e.g. `c('Is a','Subsumes')`
* `omop_relations_recursive()` added to recursively extract relations of a single concept


# omopcept 0.0.1.0 2023-10-14

* `omop_graph()` working for visualising omop hierarchy with `ggraph`
* `domain`, `vocabulary`, `concept_code` & `concept_class` optional args added to `omop_join_name()` & `omop_join_name_all()` to be able to also join these columns
* `namefull` optional arg added to `omop_join_name()` to cope with e.g. `concept_id_2` in `omop_join_name_all()`
* `omop_relations()` and `omop_concept_relationship()` for getting more info about immediate neighbour relationships 
* bugfix, `omop_ancestors()` & `omop_decsendants()` were not filtering domin, separation etc., when `concept_id` not specified
* option for NULL `c_id` to `omop_descendants()` and `omop_ancestors()`, returns all concepts within other filters


# omopcept 0.0.0.9005 2023-08-08

* optional `itself` argument (default FALSE) to `omop_descendants()` and `omop_ancestors()`
* optional `separation` argument (default NULL) to `omop_descendants()` and `omop_ancestors()` filters on `min_levels_of_separation` e.g. c(1,2)


# omopcept 0.0.0.9003 2023-06-14

* `omop_join_name_all()`
* shortname copies of functions for interactive use **ojoin() ojoinall()**
* generalised **omop_download()** to get other omop tables
* **omop_descendants()** function to query omop hierarchy
* **omop_ancestors()**
* shortname function copies of above. **odesc()** and **oance()**
* added optional **messages** argument to query functions


# omopcept 0.0.0.9002 2023-05-15

* renamed package to omopcept
* renamed package functions to make clearer, most start omop_*()
* **omop_id()** to search ids
* supershort name copies of functions for interactive use **oid() onames() ocodes()**

# omopcepts 0.0.0.9001 2023-05-05

* concepts moved from data to parquet, enabling arrow queries without reading in all data
* **omop_download()** added
* `NEWS.md` to track changes to the package.


# omopcepts 0.0.0.9000 2023-04-25

* first version
