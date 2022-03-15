#'
#' Change values of an imported SVG file
#'
#' SVG files and the imported representation of class `XMLsvg` are
#' hierarchically organized in node sets and nodes. Each node is a graphical
#' object such as a path, rectangle, or text. This function changes _values_ of
#' nodes, most notably text fields. For _attributes_ which describe the properties
#' of a value, see \code{set_attributes()}. Note that even when the output of
#' \code{set_values()} is not assigned to a new object, the input \code{XMLsvg} object
#' is still changed. This is because, unlike usual R work flows, attributes of
#' XML objects are changed on the fly (similar to python).
#'
#' @return Returns an object of class `XMLsvg`
#'
#' @param xml (XMLsvg) XMLsvg object obtained from \code{read_svg()}
#' @param node (character) node(s) to be modified. Node names are searched using
#'   the `node_attr` field
#' @param node_attr (character) name of the attribute by which target nodes are
#'   filtered (default: "label")
#' @param value (character) The (new) value assigned to
#'
#' @importFrom stats setNames
#' @importFrom dplyr select
#' @importFrom dplyr filter
#' @importFrom XML getNodeSet
#' @importFrom XML xmlGetAttr
#' @importFrom XML getChildrenStrings
#' @importFrom XML xmlChildren
#' @importFrom XML xmlValue
#'
#' @export
set_values <- function(
  xml, node = NULL, node_attr = "label",
  value = NULL
) {
  # check correct class
  stopifnot(class(xml) == "XMLsvg")
  # if only 1 node/value is supposed to be changed
  if (all(sapply(list(node, value), length) == 1)) {
    set_single_value(xml, node, node_attr, value)
  } else {
  # otherwise loop through all nodes
  # node and value must be of same length or length 1
    df_params <- data.frame(node = node, value = value)
    apply(df_params, 1, function(p) {
      set_single_value(xml, p["node"], node_attr, p["value"])
    })
  }
  xml@summary = svg_summary_table(xml@svg)
  xml
}

# lower level function; not supposed to be called directly
set_single_value <- function(
  xml, node, node_attr, value
) {
  # get node set to modify and loop over nodes
  nodeSets <- unique(xml@summary$node_set)
  invisible(lapply(nodeSets, function(nodeSet) {
    # select current node set
    curr_nodeSet <- XML::getNodeSet(xml@svg, paste0("//svg:", nodeSet))
    # loop through current node set and change values
    sapply(curr_nodeSet, function(curr_node) {
      target_node <- XML::xmlGetAttr(curr_node, name = node_attr)
      if (!is.null(target_node)) {
        if (target_node %in% node) {
          if (length(XML::getChildrenStrings(curr_node)) > 0) {
            text_lab <- XML::xmlChildren(curr_node)[[1]]
            XML::xmlValue(text_lab) = as.character(value)
          }
        }
      }
    })
  }))
}
