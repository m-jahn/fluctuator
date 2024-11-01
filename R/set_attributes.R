#'
#' Change attributes of an imported SVG file
#'
#' SVG files and the imported representation of class `XMLsvg` are
#' hierarchically organized in node sets and nodes. Each node is a graphical
#' object such as a path, rectangle, or text. The attributes of these nodes
#' can be changed with this function. Note that even when the output of
#' \code{set_attributes()} is not assigned to a new object, the input `XMLsvg` object
#' is still changed. This is because, unlike usual R work flows, attributes of
#' XML objects are changed on the fly (similar to python).
#'
#' @return Returns an object of class `XMLsvg`
#'
#' @param xml (XMLsvg) XMLsvg object obtained from `read_svg()`
#' @param node (character) node(s) to be modified. Node names are searched using
#'   the `node_attr` field
#' @param node_attr (character) name of the attribute by which target nodes are
#'   filtered (default: "label")
#' @param attr (character) the desired attribute to be displayed, such as `id`, `style`
#' @param pattern (character) (sub-) string of the attribute value to be modified
#' @param replacement (character) string that is used as replacement for `pattern`
#' @param verbose (logical) print messages about the number of changed nodes
#'
#' @importFrom stats setNames
#' @importFrom dplyr select
#' @importFrom dplyr filter
#' @importFrom XML getNodeSet
#' @importFrom XML xmlGetAttr
#' @importFrom XML removeAttributes
#' @importFrom XML addAttributes
#'
#' @export
set_attributes <- function(
  xml, node = NULL, node_attr = "label",
  attr = NULL, pattern = NULL, replacement = NULL,
  verbose = TRUE
) {
  # check correct class
  stopifnot(class(xml) == "XMLsvg")
  # check if node_attr exists
  check_node_attr(xml@summary, node_attr)
  # if only 1 node/attribute is supposed to be changed
  if (all(sapply(list(node, attr, pattern, replacement), length) == 1)) {
    changed_nodes <- set_single_attribute(xml, node, node_attr,
      attr, pattern, replacement)
  } else {
  # otherwise loop through all attributes
  # node, attr, pattern, and replacement must be of same length or length 1
    df_params <- data.frame(node = node, attr = attr,
      pattern = pattern, replacement = replacement)
    changed_nodes <- apply(df_params, 1, function(p) {
      set_single_attribute(xml, p["node"], node_attr,
        p["attr"], p["pattern"], p["replacement"])
    })
    changed_nodes <- sum(unlist(changed_nodes))
  }
  if (verbose) {
    if (changed_nodes > 0) {
      message(paste0("New attributes were set for ", changed_nodes, " node(s)."))
    } else {
      warning("No attribute was changed, check node selection.")
    }
  }
  xml@summary = svg_summary_table(xml@svg)
  xml
}

# lower level function; not supposed to be called directly
set_single_attribute <- function(
  xml, node, node_attr, attr, pattern, replacement
) {
  # get node set to modify and loop over nodes
  nodeSets <- unique(xml@summary$node_set)
  changed_nodes <- lapply(nodeSets, function(nodeSet) {
    # select current node set
    curr_nodeSet <- XML::getNodeSet(xml@svg, paste0("//svg:", nodeSet))
    # loop through current node set and change attributes
    sapply(curr_nodeSet, function(curr_node) {
      target_node <- XML::xmlGetAttr(curr_node, name = node_attr)
      if (!is.null(target_node)) {
        if (target_node %in% node) {
          modify_node_rec(curr_node, attr, pattern, replacement)
        } else {
          return(0)
        }
      } else {
        return(0)
      }
    })
  })
  return(sum(unlist(changed_nodes)))
}

# recursively modify 1 attribute at a time, for 1 node and all its children
modify_node_rec <- function(curr_node, attr, pattern, replacement, changed_nodes = 0) {
  att <- XML::xmlGetAttr(curr_node, name = attr)
  if (!is.null(att)) {
    if (pattern == "") {
      att <- replacement
    } else {
      att <- gsub(pattern, replacement, att)
    }
    XML::removeAttributes(curr_node, .attrs = attr)
    att_list <- stats::setNames(list(curr_node, att), c("node", attr))
    do.call(XML::addAttributes, att_list)
    changed_nodes <- changed_nodes + 1
  }
  # recursively call function for children
  children <- XML::xmlChildren(curr_node)
  if (length(children)) {
    result <- lapply(children, function(curr_node) {
      modify_node_rec(
        curr_node = curr_node,
        attr = attr,
        pattern = pattern,
        replacement = replacement,
        changed_nodes = changed_nodes)
    })
    changed_nodes <- changed_nodes + sum(unlist(result))
  }
  return(changed_nodes)
}
