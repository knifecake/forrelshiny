
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

The exclusion power GUI runs on your browser but it does not use an
internet connection. None of your data will leave your computer.

### A note on saving the workspace

A *save workspace* functionality is currently being tested. It uses
Shiny’s bookmarking feature which is still not very mature. We hope it
becomes more stable as the implementation of complex bookmarking is
finalised in Shiny. For the moment, bookmarking works as follows:

1.  Launch the app and input the files you need for the calculation.
    Optionally run the calculation.
2.  When you whish to save the results, click *Save workspace* on the
    top-right corner. A pop-up window will appear with a link that you
    must copy and save somewhere.
3.  When you want to revisit this particular workspace you will need to
    launch the app if it is not already running and paste the link you
    saved into your browser’s address bar.

Please note that if you save a project multiple times you will still get
different links and only the most recent one will contain the lastest
changes you made to the project.
