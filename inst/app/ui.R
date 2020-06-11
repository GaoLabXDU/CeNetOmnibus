###############################
### Google Analytics - ui.R ###
###############################
source("www/R/customerUI.R",local = T)
source('www/R/input_tabUI.R',local = T)
source('www/R/process_tabUI.R',local = T)
source('www/R/construct_tabUI.R',local = T)
source('www/R/visualization_tabUI.R',local = T)
source('www/R/analysis_tabUI.R',local = T)
source('www/R/help_tabUI.R',local = T)
includeScript('www/js/all.js')
header=dashboardHeader(
  title='CeNet Omnibus',
  titleWidth=280
)
sidebar=dashboardSidebar(
  sidebarMenu(
    menuItem("1st Step: Data Input", tabName = "input", icon = icon("table",class = 'far'),badgeLabel = 3),
    menuItem("2nd Step: Data Preprocess", tabName = "process", icon = icon("cog"),badgeLabel = 4),
    menuItem("3rd Step: Network Construction", tabName = "construction", icon = icon("connectdevelop"),badgeLabel = 3),
    menuItem("4th Step: Network Visualization", tabName = "visualization", icon = icon("project-diagram"),badgeLabel = 1),
    menuItem("5th Step: Network Analysis", tabName = "analysis", icon = icon("chart-line"),badgeLabel = 4),
    menuItem("Help and Tutorial", tabName = "help", icon = icon("question"))
  ),width=280
)

body=dashboardBody(
  tabItems(
    input_tab,
    process_tab,
    construction_tab,
    visual_tab,
    analysis_tab,
    help_tab
  ),
  useSweetAlert()
)
dashboardPage(
  tags$head(
    tags$style(".shiny-input-container {margin-bottom: 0px} .shiny-file-input-progress {margin-bottom: 0px} .fa-spin {-webkit-animation:fa-spin 2s infinite linear;animation:fa-spin 2s infinite linear}"),
    tags$link(href = 'skins/all.css',rel="stylesheet"),tags$link(href='css/bootstrap-table.min.css',rel='stylesheet'),tags$link(href = 'css/select2.min.css',rel="stylesheet"),tags$link(href='css/select2-bootstrap-theme.css',rel="stylesheet"),
    tags$link(href = 'css/bootstrap-editable.css',rel="stylesheet"),tags$link(href='shinyWidgets/multi/multi.min.css',rel='stylesheet'),tags$link(href='css/ion.rangeSlider.min.css',rel='stylesheet'),
    tags$script(src="js/icheck.min.js"),tags$script(src='js/bootstrap-table.min.js'),tags$script(src='js/select2.min.js'),tags$script(src='js/customerUI.js'),
    tags$script(src='js/bootstrap-editable.js'),
    tags$script(src='js/all.js'),
    tags$script(src="js/process.js"),
    tags$script(src="js/ion.rangeSlider.min.js"),
    tags$script(src="js/construction.js"),
    tags$script(src="js/filterProcess.js"),
    tags$script(src="js/samplefilterprocess.js"),
    tags$script(src="js/cytoscape.js"),
    tags$script(src='js/visualization.js'),
    tags$script(src="js/jscolor.js"),
    tags$script(src='js/analysis.js'),tags$script(src='js/FileSaver.js'),
    tags$link(href ='css/network-table.css',rel="stylesheet")
    ),
  header=header,
  sidebar = sidebar,
  body=body
)