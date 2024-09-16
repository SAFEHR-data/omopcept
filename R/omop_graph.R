#' graph omop hierarchy
#' accepts output from either omop_ancestors(), omop_descendants() or omop_relations
#'
#' @param dfin dataframe output from either omop_ancestors(), omop_descendants() or omop_relations
#'
#' @param ggrlayout ggraph layout, default = 'graphopt'
#' @param palettebrewer colour brewer palette, default='Set1', other options e.g. 'Dark2' see RColorBrewer::brewer.pal.info
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
#' #TODO make a quick example
# pressure <- omop_names("^Blood pressure$",standard='S')
# press_descend <- omop_descendants(pressure$concept_id[1])
# omop_graph(press_descend, filenameroot="bloodpressure",graphtitle="OMOP Blood Pressure")
omop_graph <- function(dfin,
                       ggrlayout='graphopt',
                       palettebrewer='Set1',
                       palettedirection=1,

                       edgecolour='grey71',
                       nodecolourvar='domain_id',
                       textcolourvar=NULL,

                       nodealpha = 0.8,
                       edgealpha = 0.3, #ggraph uses underscore adge_alpha but would mess up my consistency
                       edgewidth = 0.1,

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
      rename(from = concept_name_1,
               to = concept_name_2)
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

  nodes1 <- bind_rows(nodesfrom,nodesto) |>
    group_by(name) |>
    slice_head(n=1)

  edges1 <- dfin2 |>
    select(from, to)

  graphin <- tidygraph::tbl_graph(nodes=nodes1, edges=edges1)

  #sets node attribute of num_edges
  igraph::V(graphin)$connections <- igraph::degree(graphin)

  ggr <- ggraph::ggraph(graphin, layout=ggrlayout) +
    ggraph::geom_edge_link(colour=edgecolour, edge_alpha=edgealpha, edge_width=edgewidth ) +
    #couldn't get colouring edges to work
    #geom_edge_link(aes(colour = node.class),edge_alpha=0.6, edge_width=0.1 ) +
    #geom_edge_link(aes(colour = factor(min_levels_of_separation))) +
    #geom_node_point(aes(size=connections)) + #colour=domain_id,
    #as.factor gets colours to work if numeric
    ggraph::geom_node_point(aes(size=connections,
                                #colour=.data[[nodecolourvar]]),
                                colour=as.factor(.data[[nodecolourvar]])),
                    alpha=nodealpha,
                    show.legend = c(size = FALSE, colour = legendshow, alpha = FALSE)) +
    #geom_node_point(aes(size=connections,colour=connections)) +
    scale_color_brewer(palette=palettebrewer, direction=palettedirection) +
    labs(title=graphtitle,subtitle=graphsubtitle,
         caption=caption) +
    theme(#panel.background=element_blank(),
          panel.background=element_rect(fill=backcolour, colour=backcolour, size=0.5),
          plot.background=element_blank(),
          legend.position = legendpos,
          legend.direction = legenddir,
          legend.key.size = unit(legendcm, 'cm'),
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
    guides(colour = guide_legend(override.aes = list(size=20))) +
    ggraph::geom_node_text(aes(label=name,
                               size=nodetxtsize,
                               #colour=.data[[textcolourvar]]),
                               colour=as.factor(.data[[textcolourvar]])),
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
    if (!is.null(filenamecustom)) filename <- filenamecustom
    else
      filename <- paste0(filenameroot,
                         "-",ggrlayout,
                         "-p",palettedirection,palettebrewer,
                         "-leg",legendpos,legendcm,
                         "-nts",nodetxtsize,
                         "-nta",nodetxtangle,
                         "-n",nodecolourvar,
                         "-b",backcolour,
                         "-e",edgecolour,
                         "-",width,"x",height,units,
                         ".",filetype)

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

