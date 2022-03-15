#'
#' Get values from an imported SVG file
#'
#' SVG files and the imported representation of class `XMLsvg` are
#' hierarchically organized in node sets and nodes. Each node is a graphical
#' object such as a path, rectangle, or text. The values of these nodes
#' can be queried using this function. A typical application for this
#' function is to query the content of a text field. If you want to retrieve
#' the (style) _attributes_ of a text field, use \code{get_attributes()} instead.
#'
#' @return Returns a named list with values for the queried nodes
#'   (or NULL if no value exists)
#'
#' @param xml (XMLsvg) XMLsvg object obtained from \code{read_svg()}
#' @param node (character) node(s) to be modified. Node names are searched using
#'   the `node_attr` field
#' @param node_attr (character) name of the attribute by which target nodes are
#'   filtered (default: "label")
#'
#' @importFrom XML getNodeSet
#' @importFrom XML xmlGetAttr
#' @importFrom XML getChildrenStrings
#' @importFrom XML xmlChildren
#' @importFrom XML xmlValue
#'
#' @export
get_values <- function(
  xml, node = NULL, node_attr = "label"
) {
  # check correct class
  stopifnot(class(xml) == "XMLsvg")
  # if only 1 node/value is supposed to be changed
  sapply(node, function(n) get_single_value(xml, n, node_attr))
}

# lower level function; not supposed to be called directly
get_single_value <- function(
  xml, node, node_attr
) {
  # get node set and loop over nodes
  nodeSets <- unique(xml@summary$node_set)
  unlist(lapply(nodeSets, function(nodeSet) {
    # select current node set
    curr_nodeSet <- XML::getNodeSet(xml@svg, paste0("//svg:", nodeSet))
    # loop through current node set and change values
    unlist(sapply(curr_nodeSet, function(curr_node) {
      target_node <- XML::xmlGetAttr(curr_node, name = node_attr)
      if (!is.null(target_node)) {
        if (target_node %in% node) {
          if (length(XML::getChildrenStrings(curr_node)) > 0) {
            text_lab <- XML::xmlChildren(curr_node)[[1]]
              XML::xmlValue(text_lab)
          }
        }
      }
    }))
  }))
}
