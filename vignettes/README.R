## ---- eval = FALSE------------------------------------------------------------
#  devtools::install_github("m-jahn/fluctuator")

## ---- message = FALSE---------------------------------------------------------
library(dplyr)
library(fluctuator)

# import example map
SVG <- read_svg("../images/example_network.svg")

# show class
class(SVG)

# access summary table of objects/nodes
head(SVG@summary)

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

## -----------------------------------------------------------------------------
SVG2 <- read_svg("../images/central_metabolism.svg")
head(SVG2@summary)

## -----------------------------------------------------------------------------
data(metabolic_flux)
head(metabolic_flux)

## -----------------------------------------------------------------------------
get_attributes(SVG2, node = "GAPDH") %>% pull(style)

## -----------------------------------------------------------------------------
metabolic_flux_for <- metabolic_flux %>%
  filter(substrate == "formate") %>%
  mutate(stroke_width = 0.2 + 0.2*sqrt(abs(flux_mmol_gDCW_h)))

SVG2 <- set_attributes(SVG2,
  node = metabolic_flux_for$reaction, attr = "style",
  pattern = "stroke-width:[0-9]+\\.[0-9]+",
  replacement = paste0("stroke-width:", metabolic_flux_for$stroke_width))

## -----------------------------------------------------------------------------
reactions_green <- metabolic_flux %>%
  filter(substrate == "formate", flux_mmol_gDCW_h != 0) %>%
  pull(reaction)

SVG2 <- set_attributes(SVG2,
  node = reactions_green, attr = "style",
  pattern = "stroke:#808080",
  replacement = "stroke:#008A12")

## -----------------------------------------------------------------------------
write_svg(SVG2, file = "../images/central_metabolism_mod.svg")

