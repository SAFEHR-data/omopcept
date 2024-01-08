test_that("omop_join_name_all() works with simple concept_id & *_concept_id", {
  #TODO check what happens if vocab data haven't been loaded
  expect_no_error( data.frame(concept_id = (c(3571338L,3655355L)),
                              drug_concept_id = (c(4000794L,35628998L))) |>
                   omop_join_name_all()
                 )
})

test_that("omop_join_name_all() works with tricky field from FACT_RELATIONSHIP", {

  expect_no_error( data.frame(domain_concept_id_1 = c(3571338L,3655355L)) |>
                      omop_join_name_all()
                 )
})

test_that("omop_join_name_all() works on list of multiple tables", {

  df <- data.frame(concept_id = c(3571338L,3655355L))
  expect_no_error( list(df,df)  |>
                   omop_join_name_all()
                 )
})
