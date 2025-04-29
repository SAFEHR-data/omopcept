# ggraph-simple-test.R
# andy south 2025-03-11
#
# testing ggraph trying to solve issue
# that omop_graph() occasionally colours nodes by the wrong attribute



nod <- data.frame(name=c("A","B","C","D"), attribute=c("a","b","c","d"))
edg <- data.frame(from=c(1,1,2), to=c(2, 3, 3))
tg  <- tbl_graph(nodes = nod, edges = edg)
ggraph(tg) + geom_node_point() + geom_edge_link() + geom_node_text(aes(label=attribute), size=10)


#how does it cope with repeated node names ?
#a separate node gets plotted even if it has identical name & attributes to another
nod <- data.frame(name=c("A","B","C","C"), attribute=c("a","b","c","c"))
edg <- data.frame(from=c(1,1,2), to=c(2, 3, 3))
tg  <- tbl_graph(nodes = nod, edges = edg)
ggraph(tg) + geom_node_point() + geom_edge_link() + geom_node_text(aes(label=name), size=10)


#this indicates that I have to make sure omopcept filters to get just one node per name
