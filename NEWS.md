
# omopcept 0.0.0.90051 dev

* added `omop_graph()` for visualising omop hierarchy with `ggraph`
* add option for NULL `c_id` to `omop_descendants()` and `omop_ancestors()`, returns all concepts within other filters

# omopcept 0.0.0.9005 2023-08-08

* added optional `itself` argument (default FALSE) to `omop_descendants()` and `omop_ancestors()`
* added optional `separation` argument (default NULL) to `omop_descendants()` and `omop_ancestors()` filters on `min_levels_of_separation` e.g. c(1,2)


# omopcept 0.0.0.9003 2023-06-14

* **omop_join_name_all()**
* added shortname copies of functions for interactive use **ojoin() ojoinall()**
* generalised **omop_download()** to get other omop tables
* **omop_descendants()** function to query omop hierarchy
* **omop_ancestors()**
* shortname function copies of above. **odesc()** and **oance()**
* added optional **messages** argument to query functions

# omopcept 0.0.0.9002 2023-05-15

* renamed package to omopcept
* renamed package functions to make clearer, most start omop_*()
* **omop_id()** to search ids
* added supershort name copies of functions for interactive use **oid() onames() ocodes()**

# omopcepts 0.0.0.9001 2023-05-05

* concepts moved from data to parquet, enabling arrow queries without reading in all data
* **omop_download()** added
* Added `NEWS.md` to track changes to the package.


# omopcepts 0.0.0.9000 2023-04-25

* first version
