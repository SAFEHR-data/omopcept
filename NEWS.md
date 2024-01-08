
# omopcept 0.0.4.1 2024-01-08 DEV version



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
