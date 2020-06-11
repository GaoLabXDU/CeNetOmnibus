process_tab=tabItem(tabName = "process",
                    #h2("Data Preprocess"),
                    div(class="row" ,id="float_banner",
                        #box(title='Data Process',collapsible=T,collapsed=F,status='primary',solidHeader=T,width = 12,
                        value_BoxInput(value = 0,subtitle =  "Valid RNA", icon = "twitter",color = "red",width = 4,inputId="Rnaoutput" ),
                        value_BoxInput(value = 0,subtitle =  "Valid MicroRNA", icon = "twitter",color = "purple",width = 4,inputId="MicroRnaoutput" ),
                        value_BoxInput(value = 0,subtitle =  "Valid Sample", icon = "twitter",color = "yellow",width = 4,inputId="Sampleoutput" )
                    ),
                    h2("Step1: Gene Grouping",style='font-family:Georgia'),
                    fluidRow(
                      box(title = "Gene Grouping",status = 'success',solidHeader = F,width = 12,id="Info_Map_all",
                          footer = list(downloadButton("downloadData_group", "Download"),
                                     tags$button(id = 'biotype_group_statics', type = "button",class = "btn btn-success action-button pull-right",HTML('Preview'),width='20')
                                   ),
                          div(class='col-lg-6',style="padding:0px",
                              prettyRadioButtons(inputId = 'biotype_map',label = 'Mapping Columns',choices = c('None'),selected = 'None',status='success',inline=T,shape = 'round'),
                              #multiInput(inputId = 'valid_biotype',label = 'Select Used Biotype',choices = c('None'),selected = NULL,options = list(enable_search = T,non_selected_header = "Choose between:",selected_header = "You have selected:")),
                              div(class="form-group",style='padding:0px',
                                  tags$label(class='control-label',HTML('Group Setting')),
                                  div(class='multi-wrapper',
                                      div(class='input-group margin',style='display:table;margin:0px',
                                          div(style='display:table-row',
                                              div(class='input-group-btn',
                                                  tags$button(class='btn btn-success',type='button',id="add_group",
                                                              HTML("<i class='fa fa-plus'></i> Add Group")
                                                  )
                                              ),
                                              tags$input(class='form-control search-input',type='text',id='new_group_name')
                                          )
                                      )
                                  ),
                                  div(class='multi-wrapper',
                                      div(class='col-lg-6 non-selected-wrapper',style="height:350px;overflow-y:auto",id='group_biotype',
                                          div(class='header',HTML('Groups'))
                                      ),
                                      div(class='col-lg-6 non-selected-wrapper',style="height:350px;overflow-y:auto",id='candidate_biotype',
                                          div(class='header',HTML('Candidate Items'))
                                      )
                                  )
                              )
                          ),
                          div(class='col-lg-6',
                              imageOutput(outputId = 'biotype_group_statics_graph',height = "100%",width="100%")
                          )


                      )#,
                      # div(class="box-footer",
                      #     downloadButton("downloadData_group", "Download"),
                      #     tags$button(id = 'biotype_group_statics', type = "button",class = "btn btn-success action-button pull-right",HTML('Preview'),width='20')
                      # )
                    ),
                    h2("Step2: Sample Filter",style='font-family:Georgia'),
                    fluidRow(
                      box(title = "Sample Filter",status = 'danger',solidHeader = F,width = 12,id="Sample_Filter_all",
                          footer =div(
                            downloadButton("downloadData_sample", "Download"),
                            tags$button(id = 'sample_slice_all', type = "button",class = "btn btn-success action-button pull-right",HTML('Filter'),width='20')
                          )
                      )
                    ),
                    h2("Step3: Gene Filter (Filter ceRNA please choose group first!)",style='font-family:Georgia'),
                    fluidRow(
                      box(title = "Gene Filter",status = 'danger',solidHeader = F,width = 12,id="Gene_Filter_all",
                          footer =div(
                            downloadButton("downloadData_gene", "Download"),
                            tags$button(id = 'gene_slice_all', type = "button",class = "btn btn-success action-button pull-right",HTML('Filter'),width='20')
                          )

                      )
                    ),
                    h2("Step4: Value Transformation",style='font-family:Georgia'),
                    fluidRow(
                      box(title = "Value Transformation",status = 'danger',solidHeader = F,width = 12,id="Value_Transform_all",
                          tabsetPanel(
                            tabPanel(title='CeRNA',
                                     div(class="col-lg-12",id="ceRNA_choose_transfunction",
                                         h3("Transform Operations"),
                                         div(class='btn-group',style="border:1px solid #ccc;margin:20px;",
                                             h3("Log-Transformation",style="text-align:center;")


                                         ),
                                         div(class='btn-group',style="border:1px solid #ccc;margin:20px;",
                                             h3("Normalization",style="text-align:center;")

                                         ),
                                         div(class='btn-group',style="border:1px solid #ccc;margin:20px;",
                                             h3("Execute",style="text-align:center;")
                                         )
                                     ),
                                     div(class="col-lg-12",id="ceRNA_handson_id",
                                         h3("Preview")

                                     )

                            ),
                            tabPanel(title='MicroRNA',
                                     div(class="col-lg-12",id="microRNA_choose_transfunction",
                                         h3("Transform Operation"),
                                         div(class='btn-group',style="border:1px solid #ccc;margin:20px;",
                                             h3("Log-Transformation",style="text-align:center;")


                                         ),
                                         div(class='btn-group',style="border:1px solid #ccc;margin:20px;",
                                             h3("Normalization",style="text-align:center;")

                                         ),
                                         div(class='btn-group',style="border:1px solid #ccc;margin:20px;",
                                             h3("Execute",style="text-align:center;")
                                         )
                                     ),
                                     div(class="col-lg-12",id="microRNA_handson_id",
                                         h3("Preview")

                                     )
                            )
                          )
                      )
                    ),
                    fluidRow(
                      div(class="col-lg-12",
                          tags$button(HTML("Next"),onclick="next_tab('#shiny-tab-construction')",class='btn btn-warning action-button shiny-bound-input')
                      )
                    )
)

visual_tab=tabItem(tabName = "visualization",
                   h2("Network Visualization",style='font-family:Georgia'),
                   div(class ="dropdown btn-dropdown-input",
                       tags$span(style="visibility: hidden; background-color: black; color: rgb(255, 255, 255); text-align: center; border-radius: 6px; padding: 5px 0px; position: absolute; left: 50px; top: 5px; z-index: 1;",
                                 HTML("Click button to display operation options")
                       ),
                       tags$button(class="btn btn-danger",id="dropdown_action",type="button",
                                   tags$span(tags$i(class="fa fa-gear"))
                                   ),
                       tags$ul(class="dropdown-menu",style="width:100%;background-color:white",
                               tags$li(style="margin-left:10px;margin-right:10px;list-style:none",
                                       div(class='row',
                                           div(class='col-lg-2',
                                               div( id="choose_differ_layout",class="form-group",
                                                    h4("Choose Layout",style="font-family:Georgia;font-weight:bold")

                                               ),
                                               div(class="form-group",id="choose_differ_name",
                                                   h4("Change Gene Name",style="font-family:Georgia;font-weight:bold")
                                               ),
                                               div(class="form-group",id="export_network_png",
                                                   h4("Export Network",style="font-family:Georgia;font-weight:bold")
                                               )
                                           ),
                                           div(class='col-lg-3',id='change_network_color'

                                           ),
                                           div(class='col-lg-3',id='change_network_shape'),
                                           div(class='col-lg-3',
                                               div(id='select_network_node',
                                                   h4("Select Node",style="font-family:Georgia;font-weight:bold"),
                                                   div(class='input-group margin',style="margin:0px"
                                                   )
                                               ),
                                               div(
                                                 h4("Reset Network",style="font-family:Georgia;font-weight:bold"),
                                                 actionBttn(
                                                   inputId = "reset_network",
                                                   label = "Reset",
                                                   style = "jelly",
                                                   color = "danger"
                                                 )
                                               ),
                                               div(id='change_node_size',
                                                   h4("Change Node Size",style="font-family:Georgia;font-weight:bold"),
                                                   div(class='input-group margin',style="margin:0px"
                                                   )
                                               ),
                                            )

                                       )
                                )
                          )
                    ),
                   div(id='cy')

)