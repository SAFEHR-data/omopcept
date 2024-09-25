#' set plot dimensions from a string e.g. "A4" "A4l" etc.
#'
#' options "A4","A4l","A3","A3l","A2","A2l","A1","A1l","A0","A0l","slide","slidehalf"
#'
#' @param canvas string defining canvas size "A4" "A4l" for landscape etc.
#'
#' @return list of width, height, units
#' @export
#' @examples
#' get_plot_dims("A1")
get_plot_dims <- function(canvas)

{

options <- c("A4","A4l","A3","A3l","A2","A2l","A1","A1l","A0","A0l","slide","slidehalf")

#TODO add check that canvas in options

switch(canvas,
    A4 =  {width <- 210
       height <- 297
       units="mm"},
       A4l = {width <- 297
       height <- 210
       units="mm"},
       A3l =  {width <- 420
       height <- 297
       units="mm"},
       A3 = {width <- 297
       height <- 420
       units="mm"},
       A2 =  {width <- 420
       height <- 594
       units="mm"},
       A2l = {width <- 594
       height <- 420
       units="mm"},
       A1l =  {width <- 841
       height <- 594
       units="mm"},
       A1 = {width <- 594
       height <- 841
       units="mm"},
       A0 =  {width <- 841
       height <- 1189
       units="mm"},
       A0l = {width <- 1189
       height <- 841
       units="mm"},
       slide =    {width <- 1920
       height <- 1080
       units="px"},
       slidehalf = {width <- 960
       height <- 1080
       units="px"})

  list(width=width, height=height, units=units)

}
