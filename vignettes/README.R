## ---- eval = FALSE------------------------------------------------------------
#  devtools::install_github("m-jahn/fluctuator")

## -----------------------------------------------------------------------------
library(fluctuator)

# import example map
SVG <- read_svg("../images/example_network.svg")

# show class
class(SVG)

# get a summary
summary(SVG)

## -----------------------------------------------------------------------------
get_attributes(SVG, node = "node_1", attr = c("label", "style"))
get_attributes(SVG, node = "ABC", attr = c("label", "style"))

## -----------------------------------------------------------------------------
SVG <- set_attributes(SVG, node = "node_1", attr = "style",
  pattern = "fill:#808080", replacement = "fill:#FF0000")

SVG <- set_attributes(SVG, node = c("ABC", "DEF"), attr = "style",
  pattern = "stroke-width:1.32291663", replacement = c("stroke-width:2.5", "stroke-width:0.5"))

## ---- eval = FALSE------------------------------------------------------------
#  write_svg(SVG, file = "../images/example_network_mod.svg")

