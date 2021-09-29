## ---- eval = FALSE------------------------------------------------------------
#  devtools::install_github("m-jahn/fluctuator")

## ---- message = FALSE---------------------------------------------------------
library(dplyr)
library(fluctuator)

# import example map
SVG <- read_svg("../inst/extdata/example_network.svg")

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
#  write_svg(SVG, file = "../inst/extdata/example_network_mod.svg")

## -----------------------------------------------------------------------------
SVG2 <- read_svg("../inst/extdata/central_metabolism.svg")
head(SVG2@summary)

## -----------------------------------------------------------------------------
data(metabolic_flux)
head(metabolic_flux)

## -----------------------------------------------------------------------------
get_attributes(SVG2, node = "GAPDH") %>% pull(style)

## -----------------------------------------------------------------------------
metabolic_flux_for <- metabolic_flux %>%
  filter(substrate == "formate") %>%
  mutate(stroke_width = 0.5 + 0.2*sqrt(abs(flux_mmol_gDCW_h)))

SVG2 <- set_attributes(SVG2,
  node = metabolic_flux_for$reaction, attr = "style",
  pattern = "stroke-width:[0-9]+\\.[0-9]+",
  replacement = paste0("stroke-width:", metabolic_flux_for$stroke_width))

## -----------------------------------------------------------------------------
# make color palette
pal <- colorRampPalette(c("#ABABAB", "#009419", "#F0B000", "#FF4800"))(10)

metabolic_flux_for <- metabolic_flux_for %>%
  mutate(
    stroke_color = stroke_width %>% {1+(./max(.))*9} %>% round,
    stroke_color_rgb = pal[stroke_color])

SVG2 <- set_attributes(SVG2,
  node = metabolic_flux_for$reaction, attr = "style",
  pattern = "stroke:#808080",
  replacement = paste0("stroke:", metabolic_flux_for$stroke_color_rgb))

## -----------------------------------------------------------------------------
SVG2 <- set_attributes(SVG2, 
  node = grep("marker", SVG2@summary$id, value = TRUE),
  node_attr = "id",
  attr = "transform",
  pattern = "scale\\(0.2\\)",
  replacement = "scale(0.15)")

SVG2 <- set_attributes(SVG2, 
  node = grep("marker", SVG2@summary$id, value = TRUE),
  node_attr = "id",
  attr = "transform",
  pattern = "scale\\(-0.2\\)",
  replacement = "scale(-0.15)")

## -----------------------------------------------------------------------------
write_svg(SVG2, file = "../inst/extdata/central_metabolism_mod.svg")

## -----------------------------------------------------------------------------
SVG2 <- set_attributes(SVG2,
  node = filter(metabolic_flux_for, flux_mmol_gDCW_h < 0)$reaction,
  attr = "style",
  pattern = "marker-end:url\\(#marker[0-9]*\\);",
  replacement = "")

SVG2 <- set_attributes(SVG2,
  node = filter(metabolic_flux_for, flux_mmol_gDCW_h >= 0)$reaction,
  attr = "style",
  pattern = "marker-start:url\\(#marker[0-9]*\\);",
  replacement = "")

write_svg(SVG2, file = "../inst/extdata/central_metabolism_direction.svg")

