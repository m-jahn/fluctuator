#'
#' Get attributes from an imported SVG file
#'
#' SVG files and the imported representation of class `XMLsvg` are
#' hierarchically organized in node sets and nodes. Each node is a graphical
#' object such as a path, rectangle, or text. The attributes of these nodes
#' can be queried using this function. Attributes relate to the _style_ of an
#' element. If you want to retrieve the _values_ of an element (e.g. content of
#' a text field), use `get_values()` instead.
#'
#' @return Returns a `tibble` with rows being the selected nodes and
#'   columns being the selected attributes
#'
#' @param xml (XMLsvg) XMLsvg object obtained from `read_svg()`
#' @param node (character) node(s) to be displayed. Node names are searched using
#'   the `node_attr` field
#' @param attr (character) the desired attribute to be displayed, such as `id`, `style`
#' @param node_attr (character) name of the attribute by which target nodes are
#'   filtered (default: "label")
#'
#' @importFrom dplyr %>%
#' @importFrom dplyr select
#' @importFrom dplyr filter
#' @importFrom dplyr all_of
#' @importFrom dplyr .data
#'
#' @export
get_attributes <- function(xml, node = NULL,
  node_attr = "label", attr = NULL
) {
  stopifnot(class(xml) == "XMLsvg")
  df <- xml@summary
  # check if node_attr exists
  check_node_attr(df, node_attr)
  # filter by ID
  if (!is.null(node)) {
    df <- dplyr::filter(df, .data[[node_attr]] %in% node)
  }
  # select only desired attributes
  if (!is.null(attr)) {
    df <- dplyr::select(df, dplyr::all_of(attr))
  }
  df
}

check_node_attr <- function(df, node_attr) {
  if (!node_attr %in% colnames(df)) {
    stop(
      paste0(
        "node attribute '", node_attr,
        "' is not available in this svg file. Try for example node_attr = 'id'"
      )
    )
  }
}
