#'
#' Read an `svg()` graphic file
#'
#' SVG (standard vector graphic) files are structured text files in XML format
#' (Extensible Markup Language). They contain descriptions of vector objects
#' such as circles, rectangles, and paths. This function 'reads' an XML file
#' by parsing it and stores it in an object of class `XMLsvg`.
#'
#' @param file (character) path to `.svg` file
#' @param ... other arguments passed down to `xmlParse`
#'
#' @examples
#'
#' # read an svg file
#' # SVG <- read_svg("example.svg")
#'
#' # alternatively, simply load example shipped with package
#' #data(example_network)
#' #print(rounded_rect)
#' #summary(example_network)
#'
#' @importFrom methods new
#' @importFrom dplyr bind_rows
#' @importFrom dplyr as_tibble
#' @importFrom dplyr mutate
#' @importFrom XML xmlParse
#' @importFrom XML xmlAttrs
#'
#' @export
read_svg <- function(file, ...) {
  # parse the input file
  xml <- XML::xmlParse(file, ...)
  # create a summary table of all paths and
  # return object of new class
  XMLsvg(
    svg = xml,
    summary = svg_summary_table(xml)
  )
}

# generate summary table
# lower level function; not supposed to be called directly
svg_summary_table <- function(xml) {
  # extract the non-metadata nodesets in the SVG
  nodeSets <- names(summary(xml)$nameCounts)
  nodeSets <- base::intersect(nodeSets, c("path", "rect", "circle",
    "marker", "tspan", "text"))
  # collect node info in new tibble
  df_node <- lapply(nodeSets, function(nodeSet) {
    lapply(xml[paste0("//svg:", nodeSet)], function(node) {
      df_node <- as.data.frame(XML::xmlAttrs(node))
      df_node <- dplyr::as_tibble(t(df_node))
      dplyr::mutate(df_node, node_set = nodeSet)
    })
  })
  dplyr::bind_rows(df_node, .id = "node_no")
}
