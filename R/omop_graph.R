#' graph omop hierarchy
#' accepts output from either omop_ancestors(), omop_descendants() or omop_relations
#'
#' @param dfin dataframe output from either omop_ancestors(), omop_descendants() or omop_relations
#'
#' @param ggrlayout ggraph layout, default = 'graphopt'
#' @param palettebrewer colour brewer pallette, default='Set1', other options e.g. 'Dark2' see RColorBrewer::brewer.pal.info
#'
#' @param filetype output image file, default='pdf'
#' @param filenameroot optional root for an auto filename for plot (not used if filenamecustom is supplied)
#' @param filenamecustom optional filename for plot, otherwise default name is created
#'
#' @param width plot width, default=50
#' @param height plot height, default=30
#' @param units plot size units default='cm'
#'
#' @param graphtitle optional title for graph, default NULL for none
#' @param plot whether to display plot, default TRUE, but note that large plots will not display well in R graphics window but do output well to pdf
#' @param messages whether to print info messages, default=TRUE
#'
#' @return ggraph object
#' @export
#' @examples
#' #pressure <- omop_names("^Blood pressure$",standard='S')
#' #press_descend <- omop_descendants(pressure$concept_id[1])
#' #omop_graph(press_descend)
omop_graph <- function(dfin,
                       ggrlayout='graphopt',
                       palettebrewer = 'Set1',

                       filetype = 'pdf',
                       filenameroot = 'omop_graph',
                       filenamecustom = NULL,

                       width=50,
                       height=30,
                       units='cm',

                       graphtitle=NULL,
                       plot=TRUE,
                       messages=TRUE
                       ) {

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
  #TODO get this to cope with relationship tables that have no vocab or domain
  #maybe I just need to allow join_name_all() to also join on vocab & domain
  nodesfrom <- dfin2 |>
    select(from,vocabulary_id,domain_id) |>
    group_by(from) |>
    slice_head(n=1) |>
    rename(name=from)

  nodesto <- dfin2 |>
    select(to,vocabulary_id,domain_id) |>
    group_by(to) |>
    slice_head(n=1) |>
    rename(name=to)

  nodes1 <- bind_rows(nodesfrom,nodesto) |>
    group_by(name) |>
    slice_head(n=1)

  edges1 <- dfin2 |>
    select(from, to)


  graphin <- tbl_graph(nodes=nodes1, edges=edges1)

  #sets node attribute of num_edges
  V(graphin)$connections <- degree(graphin)

  ggr <- ggraph(graphin, layout=ggrlayout) +
    #ggr <- ggraph(graphin,  layout = "sparse_stress", pivots=100) +
    geom_edge_link(colour="grey71", edge_alpha=0.3, edge_width=0.1 ) +
    #couldn't get colouring edges to work
    #geom_edge_link(aes(colour = node.class),edge_alpha=0.6, edge_width=0.1 ) +
    #geom_edge_link(aes(colour = factor(min_levels_of_separation))) +
    #geom_node_point(aes(size=connections)) + #colour=domain_id,
    geom_node_point(aes(size=connections, colour=domain_id)
                    ,alpha=0.9,
                    show.legend = c(size = FALSE, colour = TRUE, alpha = FALSE)) +
    #geom_node_point(aes(size=connections,colour=connections)) +
    scale_fill_brewer(palette = palettebrewer) +
    #this sets bg to white & other elements for good graphs
    #theme_graph() + gives font error
    theme(panel.background=element_blank(),
          plot.background=element_blank(),
          legend.position = "bottom",
          legend.key.size = unit(3, 'cm'),
          #legend.key.height = unit(1, 'cm'),
          #legend.key.width = unit(1, 'cm'),
          legend.key = element_rect(fill = "white"),
          #legend.title = element_text(size=30),
          legend.title = element_blank(),
          legend.text = element_text(size=20) ) +
    guides(colour = guide_legend(override.aes = list(size=20))) +
    geom_node_text(aes(label=name,
                       # colour=domain_id,
                       # size=connections*3),
                       # disabling node text size
                       size=7,
                       colour=domain_id),
                   show.legend=FALSE,
                   repel=TRUE,
                   check_overlap=FALSE,
                   nudge_y=0.3, #move labels above points
                   alpha=0.9)

  if (!is.null(graphtitle)) ggr <- ggr + ggtitle(graphtitle)

  if (plot) plot(ggr)

  #saving plots
  #naming convention
  #s  separation min
  #m  plot metres
  #ea edge alpha
  #ta text alpha
  #pdark2 palette color brewer
  #ns node sized
  #nts node text size
  #d? domains

  if (!is.null(filenamecustom)) filename <- filenamecustom
  else
    filename <- paste0(filenameroot,".",filetype)

  ggsave(ggr,filename=filename,width=width,height=height,units=units,limitsize = FALSE)


  #if (messages) message("saved graph file as ", outfilename)

  return(ggr)

}

#' super short name graph func
#' @rdname omop_graph
#' @export
#' @examples
#' # because of R argument matching, you can just use the first unique letters of
#' # arguments e.g. v for v_ids, cc for cc_ids
#omgr <- omop_graph

