#'
#' Write an `svg()` graphic file
#'
#' Writes an object of class `XMLsvg` to disk that was imported by `read_svg()`.
#'
#' @param x (XMLsvg) object to export
#' @param file (character) File path to write to
#'
#' @importFrom XML saveXML
#'
#' @export
write_svg <- function(x, file) {
  # export only the xml/svg slot of the object
  XML::saveXML(x@svg, file = file, indent = FALSE)
}
