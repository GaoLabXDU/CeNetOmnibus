#' Check and Install the dependency packages of CeNetOmnibus
#' @return
#' @export
#'
#' @examples
#'    checkDependency()
checkDependency=function()
{
  print("Checking Dependency...")
  dependency=data.frame(package=c('parallel','biomaRt','shiny','plyr','ggplot2','jsonlite','shinydashboard','shinyWidgets','DT','ggthemr','tibble','igraph','scales','rhandsontable','PerformanceAnalytics','linkcomm','MCL','visNetwork','colourpicker','ggplotify','survival','survminer','ComplexHeatmap','circlize','formattable','infotheo','ProNet','gprofiler2','R.oo','svglite','patchwork','Matrix','stringi'),
                        repo=c('CRAN','Bioc','CRAN','CRAN','CRAN','CRAN','CRAN','CRAN','CRAN','github','CRAN','CRAN','CRAN','CRAN','CRAN','CRAN','CRAN','CRAN','CRAN','CRAN','CRAN','CRAN','Bioc','CRAN','CRAN','CRAN','self','CRAN','CRAN','CRAN','CRAN','CRAN','CRAN'),stringsAsFactors = F)
  rownames(dependency)=dependency$package
  installed=installed.packages()
  if(!"devtools" %in% installed)
    install.packages('devtools')
  if(!"BiocManager" %in% installed)
    install.packages('BiocManager')
  install=dependency[!(dependency$package %in% installed),]
  CRAN=install$package[which(install$repo=='CRAN')]
  Bioc=install$package[which(install$repo=='Bioc')]
  if(length(CRAN)>0)
    devtools::install_cran(CRAN,upgrade='never')
  if(length(Bioc)>0)
    devtools::install_bioc(Bioc,upgrade = 'never')
  if("ggthemr" %in% install$package)
    devtools::install_github("cttobin/ggthemr",upgrade='never')
  if("ProNet" %in% install$package)
    install.packages("https://cran.r-project.org/src/contrib/Archive/ProNet/ProNet_1.0.0.tar.gz",repos = NULL,type = "source")
  print("Checking Dependency Finish!")
}
