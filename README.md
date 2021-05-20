fluctuator
================
Michael Jahn
2021-05-20

<!-- include logo-->

<img src="images/logo.png" align="right" />

-----

An Interface to Import and Modify SVG (XML) Graphic Files in R.

## Description

SVG is the primary choice for scalable, open-source graphic files. This
packages provides a simple interface to import SVG graphic files in R,
modify these in a programmatic way, and export the files again. The
purpose of this package is to overlay scientific data on medium or large
scale network representations, which is too laborious and time-consuming
to do manually. SVG Graphics have to be drawn beforehand, for example
using [Inkscape](https://inkscape.org/). Objects (“nodes”) are than
identified and modified using unique IDs/label in R. The fantastic
[Escher](https://escher.github.io/#/) app follows a similar approach,
where a metabolic network is first drawn on a canvas, and then used as a
template to overlay metabolic, flux, gene expression or other data.
Options to customize the metabolic maps are too restricted.

Package info:

  - Maintainer: Michael Jahn, Science for Life Lab, Stockholm
  - License: GPL-3
  - Depends: R (\>= 3.5.0)
  - Imports: `methods`, `XML`, `dplyr`

## Installation

To install the package directly from github, use the following function
from the `devtools` package in your R session:

``` r
devtools::install_github("m-jahn/fluctuator")
```

## Usage

### Read SVG

We can import a simple SVG file representing a network. The resulting
`XMLsvg` has two slots, the original XML structure and a feature table
with all graphical objects (“nodes”) and their attributes.

``` r
library(fluctuator)

# import example map
SVG <- read_svg("../images/example_network.svg")

# show class
class(SVG)
```

    ## [1] "XMLsvg"
    ## attr(,"package")
    ## [1] "fluctuator"

``` r
# get a summary
summary(SVG)
```

    ## Attribute summary:
    ## 
    ## Attribute table:

    ##                     Length Class  Mode     
    ## node_no             14     -none- character
    ## id                  14     -none- character
    ## d                   14     -none- character
    ## style               14     -none- character
    ## transform           14     -none- character
    ## connector-curvature 14     -none- character
    ## node_set            14     -none- character
    ## label               14     -none- character
    ## cx                  14     -none- character
    ## cy                  14     -none- character
    ## r                   14     -none- character
    ## stockid             14     -none- character
    ## orient              14     -none- character
    ## refY                14     -none- character
    ## refX                14     -none- character
    ## isstock             14     -none- character
    ## space               14     -none- character
    ## x                   14     -none- character
    ## y                   14     -none- character
    ## role                14     -none- character
    ## width               14     -none- character
    ## height              14     -none- character

### Get attributes of SVG

We can search for certain nodes in the SVG and display their attributes.
Note that nodes are objects, not to be confused with single points of a
path.

``` r
get_attributes(SVG, node = "node_1", attr = c("label", "style"))
```

    ## # A tibble: 1 x 2
    ##   label  style                                                                  
    ##   <chr>  <chr>                                                                  
    ## 1 node_1 color:#000000;clip-rule:nonzero;display:inline;overflow:visible;visibi…

``` r
get_attributes(SVG, node = "ABC", attr = c("label", "style"))
```

    ## # A tibble: 1 x 2
    ##   label style                                                                   
    ##   <chr> <chr>                                                                   
    ## 1 ABC   fill:#000000;fill-opacity:1;fill-rule:evenodd;stroke:#000000;stroke-wid…

### Change attributes of SVG

The most important feature of this package is to change SVG attributes
using the `set_attributes()` function. The function takes four important
arguments: the name (`label`) of the `node` whose attributes should be
changed, and which corresponds to Inkscape object names. The `attribute`
that is supposed to be changed (e.g. `style`). And a pattern +
replacement that modifies the character value of the attribute.

In this example we change the fill color of `node_1` to red. Then we
also change the thickness of the two arrows (reactions) `ABC` and `DEF`.

``` r
SVG <- set_attributes(SVG, node = "node_1", attr = "style",
  pattern = "fill:#808080", replacement = "fill:#FF0000")

SVG <- set_attributes(SVG, node = c("ABC", "DEF"), attr = "style",
  pattern = "stroke-width:1.32291663", replacement = c("stroke-width:2.5", "stroke-width:0.5"))
```

### Export modified SVG file

Modified SVG files can be saved to disk using `write_svg()`.

``` r
write_svg(SVG, file = "../images/example_network_mod.svg")
```

|            Original SVG            |              Modified SVG              |
| :--------------------------------: | :------------------------------------: |
| ![](images/example_network.png) | ![](images/example_network_mod.png) |

<!-- ### Real world example -->
