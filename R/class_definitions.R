#'
#' S4 class definition for SVG XML
#'
#' SVG (standard vector grqphic) files are structured text files in XML format
#' (Extensible Markup Language). The new class `XMLsvg` stores the SVG file
#' in a list object with two slots, the SVG parsed by `parseXML()` and a summary
#' table.
#'
#' @importFrom methods setClass
#'
#' @export
XMLsvg <- setClass("XMLsvg",
  contains = "list",
  slots = c(
    svg = "XMLInternalDocument",
    summary = "data.frame"
  )
)

# Generic methods for the new class
#' @export
summary.XMLsvg <- function(object, digits = 12L, ...) {
  cat("Attribute summary:\n")
  summary.default(object@svg, digits = digits, ...)
  cat("\nAttribute table:\n")
  summary.default(object@summary, digits = digits, ...)
}
