#' graph omop hierarchy
#' accepts output from either omop_ancestors(), omop_descendants() or omop_relations
#'
#' @param dfin dataframe output from either omop_ancestors(), omop_descendants() or omop_relations
#'
#' @param ggrlayout ggraph layout, default = "graphopt", also "tree" works well, more directional
#' @param palettebrewer colour brewer palette, default='Dark2', other options e.g. 'Set1' see RColorBrewer::brewer.pal.info
#' @param palettedirection palette direction, default=1, -1 for reversed
#'
#' @param edgecolour colour for lines joining nodes
#' @param nodecolourvar column to specify node colour, default="domain_id" other options "vocabulary_id" "concept_class_id" "standard_concept"
#' @param textcolourvar column to specify node text colour, default=NULL then set same as node_colour above. Other options "vocabulary_id" "concept_class_id" "standard_concept"
#'
#' @param nodealpha node transparency, default 0.8
#' @param edgealpha edge transparency, default 0.3, #ggraph uses underscore edge_alpha but would mess up my consistency
#' @param edgewidth edge width, default 0.1, #ggraph uses underscore edge_width but would mess up my consistency
#'
#' @param nodesizevar column to set node size, default="connections", uses num connections to a node
#' @param nodesize modify node size range, default c(0,6), will modify size whether nodesizevar used or not, single value e.g. 5 will give equal sized nodes
#'
#' @param nodetxtvar column to set node label, default="name"
#' @param nodetxtangle node text angle, default=0, 90 gives vertical text
#' @param nodetxtsize node text size, default=9
#' @param nodetxtnudgey nudge_y text relative to points, default 0.3
#' @param nodetxtnudgex nudge_x text relative to points, default 0
#' @param legendtxtsize text size for legend, default=20
#' @param titletxtsize text size for title, default=20
#' @param titlejust title justification, "left","right", default "centre"
#'
#' @param legendshow whether to show legend, default TRUE
#' @param legendpos legend position, default 'bottom'
#' @param legenddir legen direction default = 'horizontal'
#' @param legendcm legend size cm, default=3
#'
#' @param plot whether to display plot, default TRUE, note that large plots will not display well in R graphics window but do output well to pdf
#' @param saveplot whether to save plot, default TRUE, note that large plots will not display well in R graphics window but do output well to pdf
#' @param filetype output image file, default='pdf'
#' @param filenameroot optional root for an auto filename for plot (not used if filenamecustom is supplied)
#' @param filenamecustom optional filename for plot, otherwise default name is created
#' @param filepath where to save image file, default=file.path("..//omopcept-plots")
#'
#' @param canvas some plot setups that override width,height,units "A4" "A4landscape" etc.
#' @param width plot width, default=50
#' @param height plot height, default=30
#' @param units plot size units default='cm'
#' @param titlecolour colour for main title, default='darkred'
#' @param backcolour colour for background
#'
#' @param graphtitle optional title for graph, default NULL for none
#' @param graphsubtitle optional subtitle for graph, default NULL for none
#'
#' @param caption optional text below plot, default=NULL
#' @param captiontxtsize caption text size default=18,
#' @param captionjust caption justification default="left",
#' @param captioncolour caption text colour default="black",
#'
#' @param messages whether to print info messages, default=TRUE
#'
#' @return ggraph object
#' @export
#' @examples
#' bp <- omop_relations("Non-invasive blood pressure")
#' omop_graph(bp, nodesizevar="connections", nodesize = 5)
#' omop_graph(bp, nodesizevar="", nodesize = 5)
#'
#' #TODO need a more flexible palette solution than brewer (that limits num cats)
#
# pressure <- omop_names("^Blood pressure$",standard='S')
# press_descend <- omop_descendants(pressure$concept_id[1])
# omop_graph(press_descend, filenameroot="bloodpressure",graphtitle="OMOP Blood Pressure")
omop_graph <- function(dfin,
                       ggrlayout='graphopt',
                       palettebrewer='Dark2',
                       palettedirection=1,

                       edgecolour='grey71',
                       nodecolourvar='domain_id',
                       textcolourvar=NULL,

                       nodealpha = 0.8,
                       edgealpha = 0.3, #ggraph uses underscore adge_alpha but would mess up my consistency
                       edgewidth = 0.1,

                       nodesizevar = "connections",
                       nodesize = c(0,6),

                       nodetxtvar = 'name',
                       nodetxtangle=0,
                       nodetxtsize=9,
                       nodetxtnudgey=0.3,
                       nodetxtnudgex=0,
                       legendtxtsize=18,
                       titletxtsize=18,
                       titlejust="centre",

                       legendshow = TRUE,
                       legendpos = 'bottom',
                       legenddir = 'horizontal',
                       legendcm = 3,

                       plot=TRUE,
                       saveplot = TRUE,
                       filetype = 'pdf',
                       filenameroot = 'omop_graph',
                       filenamecustom = NULL,
                       filepath = file.path("..//omopcept-plots"),

                       canvas=NULL,
                       width=50,
                       height=30,
                       units='cm',
                       titlecolour='darkred',
                       backcolour='white',

                       graphtitle="omopcept graph",
                       graphsubtitle=NULL,
                       caption=NULL,
                       captiontxtsize=18,
                       captionjust="left",
                       captioncolour="black",
                       messages=TRUE
                       ) {


  #calculate nodes and edges
  graphlist <- omop_graph_calc(dfin)

  #visualisation
  #need to pass all args from main func
  #must be a better way than this ...
  omop_graph_vis(graphlist,
                 ggrlayout=ggrlayout,
                 palettebrewer=palettebrewer,
                 palettedirection=palettedirection,

                 edgecolour=edgecolour,
                 nodecolourvar=nodecolourvar,
                 textcolourvar=textcolourvar,

                 nodealpha = nodealpha,
                 edgealpha = edgealpha, #ggraph uses underscore adge_alpha but would mess up my consistency
                 edgewidth = edgewidth,

                 nodesizevar = nodesizevar,
                 nodesize = nodesize,

                 nodetxtvar = nodetxtvar,
                 nodetxtangle=nodetxtangle,
                 nodetxtsize=nodetxtsize,
                 nodetxtnudgey=nodetxtnudgey,
                 nodetxtnudgex=nodetxtnudgex,
                 legendtxtsize=legendtxtsize,
                 titletxtsize=titletxtsize,
                 titlejust=titlejust,

                 legendshow = legendshow,
                 legendpos = legendpos,
                 legenddir = legenddir,
                 legendcm = legendcm,

                 plot=plot,
                 saveplot = saveplot,
                 filetype = filetype,
                 filenameroot = filenameroot,
                 filenamecustom = filenamecustom,
                 filepath = filepath,

                 canvas=canvas,
                 width=width,
                 height=height,
                 units=units,
                 titlecolour=titlecolour,
                 backcolour=backcolour,

                 graphtitle=graphtitle,
                 graphsubtitle=graphsubtitle,
                 caption=caption,
                 captiontxtsize=captiontxtsize,
                 captionjust=captionjust,
                 captioncolour=captioncolour,
                 messages=messages)

}

#' super short name graph func
#' @rdname omop_graph
#' @export
omgr <- omop_graph


#' calculate nodes and edges from omop hierarchy
#' accepts output from either omop_ancestors(), omop_descendants() or omop_relations
#' used by omop_graph(), you are only likely to want to use on it's own to
#'  a) separate calculation & visualisation so that you can join attributes for visualisation
#'  b) pass the nodes and edges to a different graph rendering package
#'
#' @param dfin dataframe output from either omop_ancestors(), omop_descendants() or omop_relations
#'
#' @return list containing edges & nodes tables
#' @export
#' @examples
#' bp <- omop_relations("Non-invasive blood pressure")
#' listedges_nodes <- omop_graph_calc(bp)
# GOOD example with raw relationship table subset
# rel <- omop_concept_relationship() |> head(50) |> collect()
# #note this colours nodes by relationship, not quite sure how it works when nodes inevitably have >1 relationship type
# omop_graph(rel, nodecolourvar="relationship_id", nodetxtsize=3)
omop_graph_calc <- function(dfin) {

  # to detect input type from presence of specific column names
  # then create table with columns named 'from' and 'to' required by ggraph

  # TODO allow user to specify from & to columns as args
  # create a list with from & to strings

  if ("ancestor_name" %in% names(dfin)) {
    #DESCENDANT TABLE
    from = 'ancestor_name'
    to   = 'concept_name'

  } else if ("descendant_concept_name" %in% names(dfin)) {
    #ANCESTOR TABLE
    from = 'descendant_concept_name'
    to   = 'concept_name'

  } else if ("concept_id_1" %in% names(dfin)) {

    #RELATION TABLE
    #names not present in relation table, join on because needed to label nodes
    if (!"concept_name_1" %in% names(dfin)) {
      dfin <- dfin |> omop_join_name_all(columns="all")
    }
    from = 'concept_name_2'
    to   = 'concept_name_1'

  } else if ("ATC_concept_name" %in% names(dfin)) {

    from = 'ATC_concept_name'
    to   = 'drug_concept_name'

  } else if ("vocabulary_id_1" %in% names(dfin)) {

    #from vocab-network-ohdsi.R
    #dfin2 <- dfin |> mutate(from = vocabulary_id_1, to = vocabulary_id_2)
    #trying out way of allowing user to set from, to columns
    from <- 'vocabulary_id_1'
    to   <- 'vocabulary_id_2'

  } else
  {stop("column names unrecognised")}

  #copying with mutate in case user wants to use original names for vis
  lfromto <- list(from=from, to=to)
  dfin2 <- dfin |> mutate(from = .data[[lfromto$from]], to = .data[[lfromto$to]])

  #challenge to get all nodes from columns from & to, to avoid Invalid (negative) vertex id

  #TODO 2025-04-23
  #first beware that I think I may have exploratory commits on my other laptop
  #need to fix an issue that sometimes a node can get an incorrect attribute
  #related to whether it is 'from' or 'to'
  #so I may need to rename attribute columns
  #see in gdoc notes 2025-03-11
  #if the node is a from then it should get attributes from concept_1
  #if it is a to it should get attributes from concept_2
  #think this is only an issue when I'm trying to stretch the method
  #e.g. for the vocab network plots
  #maybe not for standrad concept_relationship plots

  nodesfrom <- dfin2 |>
    #select(from,vocabulary_id,domain_id) |>
    group_by(from) |>
    slice_head(n=1) |>
    rename(name=from)
    #todo, think I need more renaming here
    #e.g. for domain & standard I only want one attribute per node

  nodesto <- dfin2 |>
    group_by(to) |>
    slice_head(n=1) |>
    rename(name=to)

  nodes <- bind_rows(nodesfrom,nodesto) |>
    group_by(name) |>
    slice_head(n=1)

  edges <- dfin2 |>
    select(from, to)

  list(nodes=nodes, edges=edges)

}


#' visualise graph of omop hierarchy
#' called by omop_graph()
#'
#' @param graphlist list of `edges` and `nodes` created from `omop_graph_calc()`
#'
#' @param ggrlayout ggraph layout, default = "graphopt", also "tree" works well, more directional
#' @param palettebrewer colour brewer palette, default='Dark2', other options e.g. 'Set1' see RColorBrewer::brewer.pal.info
#' @param palettedirection palette direction, default=1, -1 for reversed
#'
#' @param edgecolour colour for lines joining nodes
#' @param nodecolourvar column to specify node colour, default="domain_id" other options "vocabulary_id" "concept_class_id" "standard_concept"
#' @param textcolourvar column to specify node text colour, default=NULL then set same as node_colour above. Other options "vocabulary_id" "concept_class_id" "standard_concept"
#'
#' @param nodealpha node transparency, default 0.8
#' @param edgealpha edge transparency, default 0.3, #ggraph uses underscore edge_alpha but would mess up my consistency
#' @param edgewidth edge width, default 0.1, #ggraph uses underscore edge_width but would mess up my consistency
#'
#' @param nodesizevar column to set node size, default="connections", uses num connections to a node
#' @param nodesize modify node size range, default c(0,6), will modify size whether nodesizevar used or not
#'
#2025-03-05 try adding this to make label setting independent from node ID
#' @param nodetxtvar column to set node label, default="name"
#' @param nodetxtangle node text angle, default=0, 90 gives vertical text
#' @param nodetxtsize node text size, default=9
#' @param nodetxtnudgey nudge_y text relative to points, default 0.3
#' @param nodetxtnudgex nudge_x text relative to points, default 0
#' @param legendtxtsize text size for legend, default=20
#' @param titletxtsize text size for title, default=20
#' @param titlejust title justification, "left","right", default "centre"
#'
#' @param legendshow whether to show legend, default TRUE
#' @param legendpos legend position, default 'bottom'
#' @param legenddir legen direction default = 'horizontal'
#' @param legendcm legend size cm, default=3
#'
#' @param plot whether to display plot, default TRUE, note that large plots will not display well in R graphics window but do output well to pdf
#' @param saveplot whether to save plot, default TRUE, note that large plots will not display well in R graphics window but do output well to pdf
#' @param filetype output image file, default='pdf'
#' @param filenameroot optional root for an auto filename for plot (not used if filenamecustom is supplied)
#' @param filenamecustom optional filename for plot, otherwise default name is created
#' @param filepath where to save image file, default=file.path("..//omopcept-plots")
#'
#' @param canvas some plot setups that override width,height,units "A4" "A4landscape" etc.
#' @param width plot width, default=50
#' @param height plot height, default=30
#' @param units plot size units default='cm'
#' @param titlecolour colour for main title, default='darkred'
#' @param backcolour colour for background
#'
#' @param graphtitle optional title for graph, default NULL for none
#' @param graphsubtitle optional subtitle for graph, default NULL for none
#'
#' @param caption optional text below plot, default=NULL
#' @param captiontxtsize caption text size default=18,
#' @param captionjust caption justification default="left",
#' @param captioncolour caption text colour default="black",
#'
#' @param messages whether to print info messages, default=TRUE
#'
#' @return ggraph object
#' @export
#' @examples
#' #showing how nodesizevar can be set from any column
#' bp <- omop_relations("Non-invasive blood pressure")
#' nodesedges <- omop_graph_calc(bp)
#' nodesedges$nodes$testsizevar <- c(1:nrow(nodesedges$nodes))
#' omop_graph_vis(nodesedges, nodesizevar="testsizevar", nodesize = 5)
omop_graph_vis <- function(
                       graphlist,
                       ggrlayout='graphopt',
                       palettebrewer='Dark2',
                       palettedirection=1,

                       edgecolour='grey71',
                       nodecolourvar='domain_id',
                       textcolourvar=NULL,

                       nodealpha = 0.8,
                       edgealpha = 0.3, #ggraph uses underscore adge_alpha but would mess up my consistency
                       edgewidth = 0.1,

                       nodesizevar = "connections",
                       nodesize = c(0,6),

                       nodetxtvar = 'name',
                       nodetxtangle=0,
                       nodetxtsize=9,
                       nodetxtnudgey=0.3,
                       nodetxtnudgex=0,
                       legendtxtsize=18,
                       titletxtsize=18,
                       titlejust="centre",

                       legendshow = TRUE,
                       legendpos = 'bottom',
                       legenddir = 'horizontal',
                       legendcm = 3,

                       plot=TRUE,
                       saveplot = TRUE,
                       filetype = 'pdf',
                       filenameroot = 'omop_graph',
                       filenamecustom = NULL,
                       filepath = file.path("..//omopcept-plots"),

                       canvas=NULL,
                       width=50,
                       height=30,
                       units='cm',
                       titlecolour='darkred',
                       backcolour='white',

                       graphtitle="omopcept graph",
                       graphsubtitle=NULL,
                       caption=NULL,
                       captiontxtsize=18,
                       captionjust="left",
                       captioncolour="black",
                       messages=TRUE
) {



# install required packages if not present
required_packages <- c("igraph","tidygraph","ggraph")
install_package <- function(packname) {
  if (!requireNamespace(packname, quietly = TRUE)) {
    message("Trying to install required package:",packname)
    utils::install.packages(packname)
  }
}
#required_packages |> purrr::map(\(pkg) install_package(pkg))
lapply(required_packages,install_package)



titlehjust <- dplyr::case_match(titlejust,
                                c("centre","center") ~ 0.5,
                                "left" ~ 0,
                                "right" ~ 1,
                                .default = 0)
captionhjust <- dplyr::case_match(captionjust,
                                  c("centre","center") ~ 0.5,
                                  "left" ~ 0,
                                  "right" ~ 1,
                                  .default = 0)

graphin <- tidygraph::tbl_graph(nodes=graphlist$nodes, edges=graphlist$edges)

#check if nodecolourvar is present in data
# if not, make a new column with equal values
# (this was only way I could think to avoid having a condition withing
#  the ggplot call, which I don't think is possible)
#  uses graphlist because not sure where I expect nodecolourvar to be in graphin !!
if( !(nodecolourvar %in% names(graphlist$nodes)) )
{
  igraph::V(graphin)$xxnodecolour <- 1
  nodecolourvar <- "xxnodecolour"
}
#cat(paste("textcolourvar:",textcolourvar,"\n"))
#have to check null first otherwise errors
#TODO problem with this that when textcolourvar missing
#it seems to add an extra coloured dot to the legend on right
#even though below uses geom_node_text(show.legend=FALSE)
#bp <- omop_relations("Non-invasive blood pressure")
#ln <- omop_graph_calc(bp)
#omop_graph_vis(ln,nodesize = 5,textcolourvar = "test")
#add this as a test after
if( !is.null(textcolourvar)) {
  if(! textcolourvar %in% names(graphlist$nodes))
    {
      igraph::V(graphin)$xxtextcolour <- 1
      textcolourvar <- "xxtextcolour"
    }}

#set node & text colour same by default, but user can change
if (is.null(textcolourvar)) textcolourvar <- nodecolourvar
if (is.null(nodecolourvar)) nodecolourvar <- textcolourvar

#sets node attribute of num_edges to allow node sizing
if (!is.null(nodesizevar) & nodesizevar=="connections")
  igraph::V(graphin)$sizecolumn <- igraph::degree(graphin)
else if( nodesizevar %in% names(graphlist$nodes))
  igraph::V(graphin)$sizecolumn <- graphlist$nodes[[nodesizevar]]
else
  igraph::V(graphin)$sizecolumn <- 1 #nodesize

#look at set.seed to try to keep the layout the same
ggr <- ggraph::ggraph(graphin, layout=ggrlayout) +
  ggraph::geom_edge_link(colour=edgecolour, edge_alpha=edgealpha, edge_width=edgewidth ) +
  #couldn't get colouring edges to work
  #geom_edge_link(aes(colour = node.class),edge_alpha=0.6, edge_width=0.1 ) +
  #geom_edge_link(aes(colour = factor(min_levels_of_separation))) +
  #as.factor gets colours to work if numeric
  ggraph::geom_node_point(aes(size=sizecolumn,
                              #TODO check presence of nodecolourvar in data before here
                              colour=as.factor(.data[[nodecolourvar]])),
                          #TODO re-enable this when worked out how to get it to cope with "connections"
                          #size=nodesize,
                          alpha=nodealpha,
                          show.legend = c(size = FALSE, colour = legendshow, alpha = FALSE)) +

  scale_size_continuous(range = nodesize) +

  #distiller should cope with larger num cats by interpolation ?
  #no gives Discrete values supplied to continuous scale
  #scale_color_distiller(palette=palettebrewer, direction=palettedirection) +
  scale_color_brewer(palette=palettebrewer, direction=palettedirection) +

  labs(title=graphtitle,subtitle=graphsubtitle,
       caption=caption) +
  theme(#panel.background=element_blank(),
    panel.background=element_rect(fill=backcolour, colour=backcolour, size=0.5),
    plot.background=element_blank(),
    legend.position = legendpos,
    legend.direction = legenddir,
    legend.key.size = unit(10*legendcm, 'mm'),#otherwise only int cm seemingly allowed
    #legend.key.height = unit(1, 'cm'),
    #legend.key.width = unit(1, 'cm'),
    legend.key = element_rect(fill = "white"),
    #legend.title = element_text(size=30),
    legend.title = element_blank(),
    legend.text = element_text(size=legendtxtsize),
    #hjust=0.5 to make centred
    plot.title = element_text(size=titletxtsize,
                              colour=titlecolour,
                              hjust=titlehjust),
    plot.caption = element_text(size=captiontxtsize,
                                colour=captioncolour,
                                hjust=captionhjust),
    plot.subtitle = element_text(size=0.7*titletxtsize, colour=titlecolour)) +
  #allows legend key symbols to be bigger, not sure if required
  guides(colour = guide_legend(override.aes = list(size=legendcm*5))) +
  ggraph::geom_node_text(aes(#label=name,
                             #2025-03-05 try to allow label to be set from other columns
                             label=.data[[nodetxtvar]],
                             colour=as.factor(.data[[textcolourvar]])),
                         size=nodetxtsize,
                         angle=nodetxtangle,
                         show.legend=FALSE,
                         repel=TRUE,
                         check_overlap=FALSE,
                         nudge_y=nodetxtnudgey, #0.3, #move labels above points
                         nudge_x=nodetxtnudgex,
                         alpha=1)

#if (!is.null(graphtitle)) ggr <- ggr + ggtitle(graphtitle)

#
#if (plot) plot(ggr)

#plot file naming convention
#s  separation min
#m  plot metres
#ea edge alpha
#ta text alpha
#pdark2 palette color brewer
#ns node sized
#nts node text size
#d? domains

if (saveplot)
{
  if (!is.null(canvas))
  {
    canvas_specs <- get_plot_dims(canvas)
    width <- canvas_specs$width
    height <- canvas_specs$height
    units <- canvas_specs$units
  }

  cat("plot dims: w",width," h",height," u:",units,"\n")

  if (!is.null(filenamecustom))
    filename <- filenamecustom
  else
  {
    filename <- paste0(filenameroot,
                       "-",ggrlayout,
                       "-p",palettedirection,palettebrewer,
                       "-leg",legendpos,legendcm,
                       "-nts",nodetxtsize,
                       "-nta",nodetxtangle,
                       "-n",nodecolourvar,
                       "-b",backcolour,
                       "-e",edgecolour)
  }

  #add these even if custom filename
  if (!is.null(canvas)) filename <- paste0(filename,"-",canvas)
  else                  filename <- paste0(filename,"-",width,"x",height,units)

  #add extension
  filename <- paste0(filename,".",filetype)

  #if plot folder doesn't exist create it
  #could be done with ggsave::create.dir=TRUE but only in ggplot from 2024
  if (!dir.exists(filepath))
    dir.create(filepath, recursive = TRUE)


  ggsave(ggr, filename=file.path(filepath,filename),
         width=width, height=height, units=units, limitsize=FALSE)
  #create.dir=TRUE) #beware create.dir needs ggplot v >3.50


  if (messages) message("saved graph file as ", filename)
}


return(ggr)
}
