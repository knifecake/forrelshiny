
# Shiny GUI for the forrel package

## Installation

This package requires `forrel` (available on CRAN) and the `fafreqs` and
`gezellig` packages (available on GitHub). Installing packages from
GitHub requires the package `devtools` which is available on CRAN and
may be installed with

``` r
install.packages("devtools")
```

Once you have `devtools` you may install `forrelshiny` by pasting the
following into an R interactive session:

``` r
install.packages("forrel")
devtools::install_github("knifecake/gezellig")
devtools::install_github("knifecake/fafreqs")
devtools::install_github("knifecake/forrelshiny")
```

## Exclusion power

To launch the exclusion power graphical user interface import the
`forrelshiny` package and use the `epGUI()` function like this:

``` r
library("forrelshiny")

epGUI()
```
