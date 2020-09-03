#' Run CeNetOmnibus App
#'
#' @param maxRequestSize Integer.The admitted file size for uploaded files. Unit MB. Default 1000MB.
#' @param workpath Character. The dictionary for temp files. Default is return value of tempdir()
#' @param projectName Character. The name of this analysis. Default is session token.
#' @param typeLimit Integer. The number of valid items. Default is 10.
#' @param useEnsembl Boolean. Determine if use Ensembl databasae. Default is T for connecting.
#' @param ... Other parameters passed to runApp()
#'
#' @return
#' @export
#'
#' @examples
#'    CeNetOmnibus()
CeNetOmnibus <- function(maxRequestSize=1000,workpath=tempdir(),projectName=NULL,typeLimit=10,useEnsembl=T,...) {
  library(parallel)
  library(biomaRt)
  library(shiny)
  library(plyr)
  library(ggplot2)
  library(jsonlite)
  library(shinydashboard)
  library(shinyWidgets)
  library(DT)
  library(ggthemr)
  library(tibble)
  library(igraph)
  library(scales)
  library(rhandsontable)
  library(PerformanceAnalytics)
  library(linkcomm)
  library(MCL)
  library(visNetwork)
  library(colourpicker)
  library(ggplotify)
  library(survival)
  library(survminer)
  library(ComplexHeatmap)
  library(circlize)
  library(formattable)
  library(infotheo)
  library(ProNet)
  library(gprofiler2)
  library(svglite)
  library(R.oo)

  maxRequestSize=maxRequestSize*1024^2
  tmpdir<<-normalizePath(workpath)
  projName<<-projectName
  if(!is.null(projectName))
  {
    projName <<- gsub(pattern = " ",replacement = '_',x = projectName)
  }
  typeLimit <<- typeLimit
  ggthemr('flat')
  usedcolors=swatch()
  options(shiny.maxRequestSize = maxRequestSize)
  useE<<-useEnsembl
  #suppressMessages(shiny::runApp(system.file("app", package = "CeNetOmnibus"),launch.browser=TRUE,...))
  shiny::runApp("D:\\ceNet-Omnibus\\app",launch.browser=TRUE,...)
}
