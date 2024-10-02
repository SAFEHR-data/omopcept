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
#' @param nodesize node size, default="connections", or set to numeric value
# TODO replace nodesize with
# together with splitting out the calculation & rendering code
# this should allow user to size nodes with their own data
# @param nodesizevar column to set node size, default="connections", uses num connections to a node
# @param nodesizemodify modify node size, numeric value, not sure scale yet.
# Will work to modify size whether a sizing variable is used or not
#'
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
#' #TODO need a more flexible palette solution than brewer (that limits num cats)
#' #TODO try to sort being able to size nodes AND use a variable
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

                       nodesize = "connections",

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

  #set node & text colour same by default, but user can change
  if (is.null(textcolourvar)) textcolourvar <- nodecolourvar
  if (is.null(nodecolourvar)) nodecolourvar <- textcolourvar

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


  #graph calc split into its own function
  graphlist <- omop_graph_calc(dfin)

  #put all the rest (vis stuff) into its own function too - including from above
  #need to pass all args from main func, will this work ?
  #omop_graph_vis(graphlist, ...)

  graphin <- tidygraph::tbl_graph(nodes=graphlist$nodes, edges=graphlist$edges)

  #sets node attribute of num_edges to allow node sizing
  #or set nodesize to constant
  #TODO allow nodesize to be set by a column in the data
  if (nodesize=="connections")
      igraph::V(graphin)$connections <- igraph::degree(graphin)
  else
      igraph::V(graphin)$connections <- nodesize

  ggr <- ggraph::ggraph(graphin, layout=ggrlayout) +
    ggraph::geom_edge_link(colour=edgecolour, edge_alpha=edgealpha, edge_width=edgewidth ) +
    #couldn't get colouring edges to work
    #geom_edge_link(aes(colour = node.class),edge_alpha=0.6, edge_width=0.1 ) +
    #geom_edge_link(aes(colour = factor(min_levels_of_separation))) +
    #as.factor gets colours to work if numeric
    ggraph::geom_node_point(aes(size=connections,
                                #colour=.data[[nodecolourvar]]),
                                colour=as.factor(.data[[nodecolourvar]])),
                    #TODO re-enable this when worked out how to get it to cope with "connections"
                    #size=nodesize,
                    alpha=nodealpha,
                    show.legend = c(size = FALSE, colour = legendshow, alpha = FALSE)) +

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
    ggraph::geom_node_text(aes(label=name,
                               #colour=.data[[textcolourvar]]),
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

#' super short name graph func
#' @rdname omop_graph
#' @export
#' @examples
#' # because of R argument matching, you can just use the first unique letters of
#' # arguments e.g. v for v_ids, cc for cc_ids
#omgr <- omop_graph




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
omop_graph_calc <- function(dfin) {

  # to detect input type from presence of specific column names
  # then create a table containing 2 columns named 'from' and 'to'
  # from,to table required by ggraph
  if ("ancestor_name" %in% names(dfin)) {

    #DESCENDANT
    dfin2 <- dfin |>
      rename(from = ancestor_name,
             to = concept_name)

  } else if ("descendant_concept_name" %in% names(dfin)) {

    #ANCESTOR
    dfin2 <- dfin |>
      rename(from = descendant_concept_name,
             to = concept_name)

  } else if ("concept_name_1" %in% names(dfin)) {

    #RELATION
    dfin2 <- dfin |>
      #2024-09-16 changed order of these to resolve text colouring issue
      rename(from = concept_name_2,
             to = concept_name_1)
  }

  #challenge to make sure get all nodes from columns from & to
  #to avoid Invalid (negative) vertex id
  nodesfrom <- dfin2 |>
    #select(from,vocabulary_id,domain_id) |>
    group_by(from) |>
    slice_head(n=1) |>
    rename(name=from)

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

