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


test_that("omop_join_name_all() doesn't error with column containing all NAs", {

  df1 <- tibble(concept_id = (c(NA,NA)))

  expect_no_error( df2 <- df1 |> omop_join_name_all() )

})

# commented because I don't think I want it to have to cope
# # with ids as doubles anymore
# test_that("omop_join_name_all() works on a double ID column", {
#
#   #note no L after numbers so they are created as doubles
#   df1 <- tibble(concept_id = (c(3571338,4002075)))
#   df2 <- df1 |> omop_join_name_all()
#   df3 <- df1 |> mutate(concept_name = c("Problem behaviour","BLUE LOTION"))
#
#   #checks joined column
#   expect_equal(df2[,2],df3[,2])
# })

# commented because I don't think I want it to have to cope
# # with ids as strings anymore
# test_that("omop_join_name_all() works on a string ID column", {
#
#   df1 <- tibble(concept_id = (c("3571338","4002075")))
#   df2 <- df1 |> omop_join_name_all()
#   df3 <- df1 |> mutate(concept_name = c("Problem behaviour","BLUE LOTION"))
#
#   #checks joined column
#   expect_equal(df2[,2],df3[,2])
# })







