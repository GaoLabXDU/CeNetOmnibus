construction_tab=tabItem(tabName = "construction",
                         h2("Step1: Choose Measurement",style='font-family:Georgia',downloadButton(outputId = 'export_condition_value',label = 'Export Values')),
                         div(class='col-lg-12 callout callout-info',
                             tags$p(style="font-size:14px;font-family:sans-serif",
                                    HTML("Please choose measurements used for construct ceRNA network, e.g. Pearson Correlation(PCC), Shared MicroRNA Significance(MS), Liquid Association(LA).&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"),
                                    tags$button(tags$i(class='fa fa-plus-square'),HTML('Add New'),class='btn btn-default',id='add_new_condition'))
                             
                         ),
                         fluidRow(
                           div(id='condition_panel')
                         ),
                         h2("Step2: Set Threshold",style='font-family:Georgia',downloadButton(outputId = 'export_condition_plot',label = "Export Plots")),
                         div(class='col-lg-12 callout callout-info',
                             tags$p(style="font-size:14px;font-family:sans-serif",
                                    HTML("Please choose threshold for every measurement and every task.")
                             )
                         ),
                         fluidRow(
                           div(id="condition_preview")
                         ),
                         h2("Step3: Network Construction",downloadButton(outputId = "network_export",label = "Export Network"),style='font-family:Georgia'),
                         div(class='col-lg-12 callout callout-info',
                             tags$p(style="font-size:14px;font-family:sans-serif",
                                    HTML("Click to Construct CeRNA Network"),
                                    tags$button(tags$i(class='fa fa-plus-square'),HTML('Construct Network'),class='btn btn-default',id='network_construction'))
                             
                         ),
                         fluidRow(
                           div(id="network_summary"
                           )
                         )
)