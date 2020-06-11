create_property_checkboxgroup=function(type,id,label,items,f)
{
  selection=list()
  for(i in items)
  {
    s=div(class="btn-group btn-goup-toggle",
          tags$button(class="btn checkbtn btn-primary",type=type,
                      tags$span(class="check-btn-icon-yes",tags$i(class='glyphicon glyphicon-ok')),
                      tags$span(class="check-btn-icon-no"),
                      tags$input(type='checkbox',autocomplete="off",name=paste(type,"_centrality",sep=""),value=i,HTML(i),onchange=paste(f,"(this)",sep=""))
          )
    )
    selection=c(selection,list(s))
  }
  ui=div(class='form-group shiny-input-container shiny-input-container-inline',
         tags$label(class='control-label',HTML(label)),
         tags$br(),
         div(id=id,class='checkboxGroupButtons shiny-bound-input',
             div(class='btn-group btn-group-container-sw',"data-toggle"="buttons","aria-label"="...",
                 selection
             )
         )
  )
  return(ui)
}
network_property_panel=tabPanel(title="Network Topology Properties",
                                h2("Part1: Network Topology Properties",style='font-family:Georgia'),
                                div(class="box box-solid box-primary",
                                    div(class="box-header",
                                        h3(class="box-title"),
                                        div(class="box-tools pull-right",
                                            tags$button(class='btn btn-box-tool',"data-widget"="collapse",
                                                        tags$i(class='fa fa-minus')
                                            )
                                        )
                                    ),
                                    div(class="box-body",
                                        create_property_checkboxgroup(type='node',id='node_centrality',label='Nodes Centrality',
                                                                      items=c("Degree","Betweenness","Closeness",'Clustering Coefficient'),f='showNodeCentrality'),
                                        create_property_checkboxgroup(type='edge',id='edge_centrality',label='Edges Centrality',items=c("Betweenness"),f='showEdgeCentrality'),
                                        tags$br(),
                                        div(id="network_property",class="row")
                                    ),
                                    div(class='box-footer',
                                        div(class='pull-right',
                                            downloadButton(outputId='export_network_node_property', label = "Export Node Property"),
                                            downloadButton(outputId='export_network_edge_property', label = "Export Edge Property"),
                                            downloadButton(outputId='export_network_property_plot', label = "Export Plots")
                                        )
                                    )
                                )
)
network_module_panel=tabPanel(title="Network Modules",
                              h2("Part2: Network Modules",style='font-family:Georgia'),
                              div(class="box box-solid box-primary",
                                  div(class='box-header',
                                      h3(class="box-title"),
                                      div(class="box-tools pull-right",
                                          tags$button(class='btn btn-box-tool',"data-widget"="collapse",
                                                      tags$i(class='fa fa-minus')
                                          )
                                      )
                                  ),
                                  div(class='box-body',
                                      div(class="row",
                                          div(class="col-lg-4",
                                              pickerInput(inputId = 'community_algorithm',label = 'Community Detection Algorithm',
                                                          choices = c("NG Algorithm"="cluster_edge_betweenness",
                                                                      "Modularity Optimization"="cluster_fast_greedy",
                                                                      "Label Propagetion"="cluster_label_prop",
                                                                      "Louvain Method"="cluster_louvain",
                                                                      "Maximal Modularity"="cluster_optimal",
                                                                      "Random Walk"="cluster_walktrap",
                                                                      "InfoMap"="cluster_infomap",
                                                                      "Cograph Community"="cluster_cograph",
                                                                      "Malcov Clustering"="cluster_mcl",
                                                                      "Linkcomm"="cluster_linkcomm",
                                                                      "MCODE"="cluster_mcode"
                                                          ),
                                                          width = "100%"
                                              )
                                          ),
                                          div(class="col-lg-2",style="padding:0;margin:0",
                                              div(class="form-group shiny-input-container",
                                                  tags$label(class="control-label"),tags$br(),
                                                  tags$button(id="community_detection",class="btn btn-primary btn-flat action-button shiny-bound-input",HTML("Perform"),
                                                              onclick="run_community_detection(this)"
                                                  )
                                              )
                                          )
                                      ),
                                      div(class="row",
                                          div(class="col-lg-12",
                                              conditionalPanel("input.community_algorithm=='cluster_edge_betweenness'"),
                                              conditionalPanel("input.community_algorithm=='cluster_fast_greedy'"),
                                              conditionalPanel("input.community_algorithm=='cluster_label_prop'"),
                                              conditionalPanel("input.community_algorithm=='cluster_louvain'"),
                                              conditionalPanel("input.community_algorithm=='cluster_optimal'"),
                                              conditionalPanel("input.community_algorithm=='cluster_walktrap'",
                                                               div(class="col-lg-4",style="padding-left:0",
                                                                   numericInput(inputId="walktrap_step",label = "Steps",value = 4,min=1,max=NA,step = 1,width = "100%")
                                                               )
                                              ),
                                              conditionalPanel("input.community_algorithm=='cluster_infomap'",
                                                               div(class="col-lg-4",style="padding-left:0",
                                                                   numericInput(inputId="infomap_nb_trails",label = "Module Counts",value = 10,min=2,max=NA,step = 1)
                                                               )
                                              ),
                                              conditionalPanel("input.community_algorithm=='cluster_cograph'"),
                                              conditionalPanel("input.community_algorithm=='cluster_mcl'",
                                                               div(class='row',
                                                                   div(class='col-lg-2 col-md-6',
                                                                       numericInput(inputId="mcl_expansion",label = "Expansion",value = 2,min = 1,max = Inf,step = 0.1,width = "100%")
                                                                   ),
                                                                   div(class='col-lg-2 col-md-6',
                                                                       numericInput(inputId="mcl_inflation",label = "Inflation",value = 2,min = 1,max = Inf,step = 0.1,width = "100%")
                                                                   ),
                                                                   div(class='col-lg-2 col-md-6',
                                                                       numericInput(inputId="mcl_max_iter",label = "Maximal Iteration",value = 100,min = 1,max = Inf,step = 1,width = "100%")
                                                                   )
                                                               )
                                              ),
                                              conditionalPanel("input.community_algorithm=='cluster_linkcomm'",
                                                               div(class='row',
                                                                   div(class='col-lg-4',
                                                                       pickerInput(inputId = "linkcomm_hcmethod",label = "Hierarchical Clustering Method ",
                                                                                   choices = c("average"="average",'ward'='ward','single'='single','complete'='complete','mcquitty'='mcquitty','median'='median','centroid'='centroid'),
                                                                                   selected='average',width="100%"
                                                                       )
                                                                   )
                                                               )
                                              ),
                                              conditionalPanel("input.community_algorithm=='cluster_mcode'",
                                                               div(class="row",
                                                                   div(class="col-lg-2",
                                                                       numericInput(inputId='mcode_vwp',label = "Vertex Weight Percentage",value = 0.5,min = 0,max = 1,step = 0.1,width = '100%')
                                                                   ),
                                                                   div(class="col-lg-2",
                                                                       div(class='form-group shiny-input-container',
                                                                           tags$label(HTML("Haircut")),
                                                                           switchInput(inputId='mcode_haircut',value = F,onLabel = 'True',offLabel = "False")
                                                                       )
                                                                   )
                                                               ),
                                                               div(class="row",
                                                                   div(class="col-lg-2",
                                                                       div(class='form-group shiny-input-container',
                                                                           tags$label(HTML("Fluff")),
                                                                           switchInput(inputId='mcode_fluff',value = F,onLabel = 'True',offLabel = "False")
                                                                       )                                                  
                                                                   ),
                                                                   conditionalPanel("input.mcode_fluff",
                                                                                    div(class="col-lg-2",
                                                                                        numericInput(inputId='mcode_fdt',label = "Cluster Density Cutoff",value = 0.8,min = 0,max = 1,step = 0.1,width = '100%')
                                                                                    )
                                                                   )
                                                               )
                                              ),
                                              tags$br()
                                          )
                                      ),
                                      div(class="row",
                                          div(class="col-lg-12",
                                              tags$label(HTML("Module Summary"),downloadButton(outputId = "export_module_info",label = "Export")),
                                              div(id="module_info_box")
                                          )
                                      ),
                                      div(class='row',
                                          div(class="col-lg-12",
                                              tags$label(HTML("Module Visualization")),
                                              div(id="module_visualization",class='row')
                                          )
                                      )
                                  ),
                                  
                                  div(class='box-footer',
                                      conditionalPanel('input.community_algorithm=="cluster_edge_betweenness"',
                                                       tags$cite(class="bg-orange-active",HTML("* Newman M E J, Girvan M. Finding and evaluating community structure in networks[J]. Physical review E, 2004, 69(2): 026113."),style="font-weight:bold")
                                      ),
                                      conditionalPanel('input.community_algorithm=="cluster_fast_greedy"',
                                                       tags$cite(class="bg-orange-active",HTML("* Clauset A, Newman M E J, Moore C. Finding community structure in very large networks[J]. Physical review E, 2004, 70(6): 066111."),style="font-weight:bold")
                                      ),
                                      conditionalPanel('input.community_algorithm=="cluster_label_prop"',
                                                       tags$cite(class="bg-orange-active",HTML("* Raghavan U N, Albert R, Kumara S. Near linear time algorithm to detect community structures in large-scale networks[J]. Physical review E, 2007, 76(3): 036106.",style="font-weight:bold"))
                                      ),
                                      conditionalPanel('input.community_algorithm=="cluster_louvain"',
                                                       tags$cite(class="bg-orange-active",HTML("* Blondel V D, Guillaume J L, Lambiotte R, et al. Fast unfolding of communities in large networks[J]. Journal of statistical mechanics: theory and experiment, 2008, 2008(10): P10008."),style="font-weight:bold")
                                      ),
                                      conditionalPanel('input.community_algorithm=="cluster_optimal"',
                                                       tags$cite(class="bg-orange-active",HTML("* Brandes U, Delling D, Gaertler M, et al. On modularity clustering[J]. IEEE transactions on knowledge and data engineering, 2007, 20(2): 172-188."),style="font-weight:bold")
                                      ),
                                      conditionalPanel('input.community_algorithm=="cluster_walktrap"',
                                                       tags$cite(class="bg-orange-active",HTML("* Pons P, Latapy M. Computing communities in large networks using random walks[C]//International symposium on computer and information sciences. Springer, Berlin, Heidelberg, 2005: 284-293."),style="font-weight:bold")
                                      ),
                                      conditionalPanel('input.community_algorithm=="cluster_infomap"',
                                                       tags$cite(class="bg-orange-active",HTML("* Rosvall M, Bergstrom C T. Maps of information flow reveal community structure in complex networks[J]. arXiv preprint physics.soc-ph/0707.0609, 2007."),style="font-weight:bold")
                                      ),
                                      conditionalPanel('input.community_algorithm=="cluster_cograph"',
                                                       tags$cite(class="bg-orange-active",HTML("* Jia S, Gao L, Gao Y, et al. Defining and identifying cograph communities in complex networks[J]. New Journal of Physics, 2015, 17(1): 013044."),style="font-weight:bold")
                                      ),
                                      conditionalPanel('input.community_algorithm=="cluster_mcl"',
                                                       tags$cite(class="bg-orange-active",HTML("* Stijn van Dongen, Graph Clustering by Flow Simulation. PhD thesis, University of Utrecht, May 2000."),style="font-weight:bold")
                                      ),
                                      conditionalPanel('input.community_algorithm=="cluster_linkcomm"',
                                                       tags$cite(class="bg-orange-active",HTML("* Ahn Y Y, Bagrow J P, Lehmann S. Link communities reveal multiscale complexity in networks[J]. nature, 2010, 466(7307): 761."),style="font-weight:bold")
                                      ),
                                      conditionalPanel('input.community_algorithm=="cluster_mcode"',
                                                       tags$cite(class="bg-orange-active",HTML("* Bader G D, Hogue C W V. An automated method for finding molecular complexes in large protein interaction networks[J]. BMC bioinformatics, 2003, 4(1): 2."),style="font-weight:bold")
                                      )
                                  )
                              ),
                              div(id="community_table")
)
enrichment_panel=tabPanel(title="Enrichment Analysis",
                           h2("Part3: Enrichment Analysis",style='font-family:Georgia'),
                           fluidRow(
                             box(width = 7,
                               title = "Select parameters",collapsible = T,collapsed = F,status = 'primary',solidHeader=T,
                               footer=tags$button(id="enrichment_finish",class="btn btn-primary btn-flat action-button shiny-bound-input",
                                                  HTML("Perform"),onclick="run_enrichment_finish(this)"),
                               div(class='row',
                                   div(class='col-lg-6',
                                       prettyRadioButtons(
                                         inputId = "gProfileOnline_Or_custom_analysis",
                                         label = "Enrichment Source",
                                         choices = c("g:Profile (Online)"="gProfile", "Custom Input"="custom_input"),
                                         inline = TRUE
                                       )
                                    ),
                                    conditionalPanel("input.gProfileOnline_Or_custom_analysis=='gProfile'",
                                                      div(class='col-lg-6',
                                                          pickerInput(inputId = 'Organism_enrichment',label = 'Organism:',
                                                                            choices = c(),
                                                                            options = list(size = 8,`live-search` = TRUE),
                                                                            width = "100%"
                                                                )
                                                      ),
                                                      div(class="col-lg-12",
                                                          pickerInput(inputId = 'enrichment_Data_Sources',label = 'Data Sources',
                                                                      choices = c("GO Molecular Function(MF)"="GO:MF",
                                                                                  "GO Cellular Component(CC)"="GO:CC",
                                                                                  "GO Biological Process(BP)"="GO:BP",
                                                                                  "KEGG"="KEGG",
                                                                                  "Reactome"="REAC",
                                                                                  "WikiPathways"="WP"
                                                                      ),
                                                                      multiple = TRUE,
                                                                      options = list("actions-box"=T)
                                                          )
                                                      ),
                                                      div(class='col-lg-6',
                                                          pickerInput(inputId = 'enrichment_Significance_threshold',label = 'Significance threshold',
                                                                      choices = c("Benjamini-Hochberg FDR"="fdr","g:SCS threshold"="g_SCS","Bonferroni Correction"="bonferroni")
                                                                )
                                                      )
                                       ),
                                       conditionalPanel("input.gProfileOnline_Or_custom_analysis=='custom_input'",
                                                        div(class='col-lg-10',
                                                            fileInput(inputId="enrichment_Custom_input_function_gene",label = "Custom input function gene")
                                                        ),
                                                        div(class="col-lg-2",style="padding-left:0px;padding-top:5px;margin:0",
                                                            div(class="form-group shiny-input-container",
                                                                div(class="input-group-btn"),tags$br(),
                                                                tags$button(id="show_custom_input_file",class="btn btn-primary btn-flat action-button shiny-bound-input",
                                                                            HTML("Preview"),onclick="run_show_custom_input_file(this)")
                                                            )
                                                        ),
                                                        div(class='col-lg-6',
                                                            pickerInput(inputId = 'enrichment_Significance_threshold_custom',label = 'Significance threshold',
                                                                        choices = c("Original P-value"="","Benjamini-Hochberg FDR"="fdr","Bonferroni Correction"="bonferroni")
                                                            )
                                                        )
                                       ),
                                       div(class='col-lg-6',
                                           numericInput(inputId = "enrichment_User_threshold", label = "User threshold", value = 0.05,min = 0,max = 1,step = 0.01)
                                       )
                               ),
                               div(class='row',
                                   div(class='col-lg-6',
                                       prettyRadioButtons(
                                         inputId = "choose_which_gene_to_analysis",
                                         label = "Gene Set Source",
                                         choices = c("Modules Gene"="Modules_Gene", "Custom Gene"="Custom_Gene"),
                                         inline = TRUE
                                       )
                                    ),
                                    conditionalPanel("input.choose_which_gene_to_analysis=='Modules_Gene'",
                                                      div(class='col-lg-6',
                                                          pickerInput(inputId = 'enrichment_Module_analysis1',label = 'Module analysis',
                                                                      choices = c(), 
                                                                      multiple = TRUE,
                                                                      options = list(size = 8,`live-search` = TRUE,"actions-box"=T),
                                                                      width = "100%"
                                                          )
                                                      )
                                     ),
                                    conditionalPanel("input.choose_which_gene_to_analysis=='Custom_Gene'",
                                                      div(class='col-lg-12',
                                                          textAreaInput(inputId="custom_input_gene",label = "Custom input gene",
                                                                        value ="",placeholder = "Please input gene set, one gene per line...",
                                                                        height = "100px")
                                                      )
                                    ),
                                   div(class='col-lg-6',
                                       pickerInput(inputId = 'enrichment_Numeric_IDs_treated_as',label = 'Gene ID Map',
                                                   choices = c(),
                                                   options = list(size = 8,`live-search` = TRUE)
                                       )
                                   ),
                                   div(class="col-lg-6",
                                       prettyRadioButtons(
                                         inputId = "enrichment_choose_show",
                                         label = "Plot Type",
                                         choices = c("Bar Plot"="bar_plot", "Point Plot"="point_plot"),
                                         inline = TRUE
                                       )
                                   )
                                   
                               )
                               ),
                             box(width = 5,
                               title = "Custom Gene Preview",collapsible = T,collapsed = F,status = 'primary',solidHeader=T,
                               formattableOutput('custom_preview_panel',width = '30%')
                             )
                            ),
                           div(id="all_enrichment_show")
                           
                           
)
survival_panel=tabPanel(title="Survival Analysis",
                         h2("Part4: Survival Analysis",style='font-family:Georgia'),
                         div(class="box box-solid box-primary",
                             div(class="box-header",
                                 h3(class="box-title"),
                                 div(class="box-tools pull-right",
                                     tags$button(class="btn btn-box-tool","data-widget"="collapse",
                                                 tags$i(class="fa fa-minus")
                                     )
                                 )
                             ),
                             div(class="box-body",
                                 tabsetPanel(type="tabs",
                                             tabPanel(title="Parameter",
                                                      div(class="col-lg-4",style="padding:0px",
                                                          tags$fieldset(
                                                            tags$legend(HTML("Clinical Information")),
                                                            div(class='col-lg-4',style="padding:0px",
                                                                tags$button(class="btn bg-navy btn-block btn-flat",
                                                                            onclick="demo_clinical()",
                                                                            tags$i(class='fa fa-upload'),
                                                                            HTML("Upload Demo Data")
                                                              
                                                            )),
                                                            div(class="col-lg-12",style="padding:0px",
                                                                fileInput(inputId="clinical_file",label = "Clinical Data")
                                                            ),
                                                            div(class='col-lg-12',style="padding:0px",
                                                                prettyRadioButtons(inputId = 'clinical_seperator',label = 'Seprator',choices = c("Tab"="\t",'Comma'=',','Space'=' ','Semicolon'=';'),status='primary',inline=T)
                                                            ),
                                                            div(class="col-lg-12",style="padding:0px",
                                                                prettyRadioButtons(inputId = 'clinical_header',label = 'Header',choices = c("With header"=T,'Without header'=F),selected=T,status='primary',inline=T)
                                                            ),
                                                            div(class="col-lg-12",style="padding:0px",
                                                                prettyRadioButtons(inputId = 'clinical_first_col',label = 'First Column For Row Name?',choices = c("Yes"=T,'No'=F),selected=F,status='primary',inline=T)
                                                            )
                                                          )
                                                      ),
                                                      div(class="col-lg-5",
                                                          tags$fieldset(
                                                            tags$legend(HTML("Expression Data")),
                                                            div(class="row",
                                                                div(class="col-lg-4",
                                                                    div(class="form-group shiny-input-container",
                                                                        tags$label(HTML("Use Current Expression?")),
                                                                        switchInput(inputId = "survival_exp_con",value = F,onLabel = "Yes",offLabel = "No")
                                                                    )
                                                                ),
                                                                conditionalPanel("!input.survival_exp_con",
                                                                                 div(class="col-lg-6",style="padding:0px",id="surv_exp_data_panel",
                                                                                     fileInput(inputId="survival_exp_data",label = "Expression Data")
                                                                                 )
                                                                )
                                                            ),
                                                            conditionalPanel("!input.survival_exp_con",
                                                                             div(class="row",
                                                                                 div(class='col-lg-12',
                                                                                     prettyRadioButtons(inputId = 'survival_exp_seperator',label = 'Seprator',choices = c("Tab"="\t",'Comma'=',','Space'=' ','Semicolon'=';'),status='primary',inline=T)
                                                                                 ),
                                                                                 div(class="col-lg-12",
                                                                                     prettyRadioButtons(inputId = 'survival_exp_header',label = 'Header',choices = c("With header"=T,'Without header'=F),selected=T,status='primary',inline=T)
                                                                                 ),
                                                                                 div(class="col-lg-12",
                                                                                     prettyRadioButtons(inputId = 'survival_exp_first_column',label = 'First Column For Row Name?',choices = c("Yes"=T,'No'=F),selected=T,status='primary',inline=T)
                                                                                 )
                                                                             )
                                                            )
                                                          )
                                                      ),
                                                      div(class="col-lg-3",
                                                          tags$fieldset(
                                                            tags$legend(HTML("Valid Patiens")),
                                                            div(class="col-lg-12",id="survival_valid_sample_panel",style="padding:0px;margin:0px",
                                                                uiOutput(outputId = "clinical_patient_count",class="col-lg-12"),
                                                                uiOutput(outputId = "exp_patient_count",class="col-lg-12"),
                                                                uiOutput(outputId = "clinical_valid_patient_count",class="col-lg-12")
                                                            )
                                                          )
                                                      ),
                                                      # tags$br(),
                                                      div(class="col-lg-12",style="padding:0px",
                                                          tags$fieldset(
                                                            tags$legend("Survival Model Parameter"),
                                                            div(class="row",
                                                                div(class="col-lg-3",
                                                                    pickerInput(inputId = "survival_model",label = "Survival Model",choices = c("Kaplan-Meier Analysis"="km_analysis",'Cox Model'='cox_model'))#,'Random Survival Forest'='random.forest'))
                                                                ),
                                                                div(class="col-lg-3",
                                                                    pickerInput(inputId='clinical_survival_time',label="Survival Time",choices = c(),options = list(title="Select Column for Survival Time"))
                                                                ),
                                                                div(class="col-lg-3",
                                                                    pickerInput(inputId='clinical_survival_status',label="Survival Status",choices = c(),options = list(title="Select Column for Survival Status"))
                                                                ),
                                                                div(class='col-lg-3',
                                                                    pickerInput(inputId = "clinical_survival_status_variable",label = "Censor Label (For \"Alive\" or \"Lost\")",choices = c())
                                                                )
                                                            ),
                                                            conditionalPanel("input.survival_model!='km_analysis'",
                                                                             div(class="row",
                                                                                 div(class="col-lg-4",
                                                                                     pickerInput(inputId = "survival_extern_factor_continous",label = "External Included Continus Factors",choices = c(),multiple = T,options = list(`live-search` = TRUE,`actions-box`=T))
                                                                                 ),
                                                                                 div(class="col-lg-4",
                                                                                     pickerInput(inputId = "survival_extern_factor_categorical",label = "External Included Categorical Factors",choices = c(),multiple = T,options = list(`live-search` = TRUE,`actions-box`=T))
                                                                                 ),
                                                                                 div(class="col-lg-4",
                                                                                     pickerInput(inputId = "survival_stratified_factor",label = "Stratified Factors",choices = c(),multiple = T,options = list(`live-search` = TRUE,`actions-box`=T))
                                                                                 )
                                                                             )
                                                            ),
                                                            div(class="row",
                                                                div(class="col-lg-3",
                                                                    pickerInput(inputId = "clinical_gene_source",label = "Gene Set Source",choices = c("Modules"="module",'Single Gene'='single.gene','Custom'='custom'))
                                                                ),
                                                                
                                                                conditionalPanel("input.clinical_gene_source=='module'",
                                                                                 div(class="col-lg-3",
                                                                                     pickerInput(inputId = "clinical_module",label = "Module ID",choices = c(),multiple = T,options = list("actions-box"=T))
                                                                                 ),
                                                                                 conditionalPanel("input.survival_model=='cox_model'",
                                                                                                  div(class="col-lg-3",
                                                                                                      div(class="form-group shiny-input-container",
                                                                                                          tags$label("Cluster Patients with Module?"),
                                                                                                          switchInput(inputId = "survival_module_cluster_sample",label = "",value = T,onLabel = "Yes",offLabel = "No")
                                                                                                      )
                                                                                                  )
                                                                                 )
                                                                ),
                                                                conditionalPanel("input.clinical_gene_source=='single.gene'",
                                                                                 conditionalPanel("input.survival_model!='km_analysis'",
                                                                                                  div(class='col-lg-2',
                                                                                                      div(class="form-group shiny-input-container",
                                                                                                          tags$label("Seprate Patients with Expression?"),
                                                                                                          switchInput(inputId = "survival_single_group_sample",label = "",value = T,onLabel = "Yes",offLabel = "No")
                                                                                                      )
                                                                                                  )
                                                                                 ),
                                                                                 conditionalPanel("input.survival_model=='km_analysis'||input.survival_single_group_sample",
                                                                                                  div(class="col-lg-3",
                                                                                                      sliderTextInput(inputId = "single_quantile",label = "Bifurcate Quantile",choices = seq(0,1,0.05),selected = 0.5,animate = F,grid = T)
                                                                                                  )
                                                                                 ),
                                                                                 div(class='col-lg-10',
                                                                                     textAreaInput(inputId = "clinical_single_gene",label = "Gene Label",value = "",placeholder = "Please Input Gene Name",rows = 10,resize = 'none')
                                                                                 )
                                                                ),
                                                                conditionalPanel("input.clinical_gene_source=='custom'",
                                                                                 conditionalPanel("input.survival_model!='km_analysis'",
                                                                                                  div(class='col-lg-3',
                                                                                                      div(class="form-group shiny-input-container",
                                                                                                          tags$label("Cluster Patients with Custom Gene Set?"),
                                                                                                          switchInput(inputId = "survival_custom_cluster_sample",label = "",value = T,onLabel = "Yes",offLabel = "No")
                                                                                                      )
                                                                                                  )
                                                                                 ),
                                                                                 div(class="col-lg-10",
                                                                                     textAreaInput(inputId="survival_custom_gene_input",label = "Custom Gene Set",value = "",width = "100%",rows = 10,placeholder = "Input Custom Genes",resize = 'none')
                                                                                 )
                                                                )
                                                            ),
                                                            tags$hr()
                                                          )
                                                      ),
                                                      div(class="row",
                                                          div(class="col-lg-2 pull-right",
                                                              tags$button(class="btn btn-block btn-primary pull-right",type="button",HTML("Execute"),onclick="survival(this)")
                                                          )
                                                      )
                                             ),
                                             tabPanel(title="Clinical Data Preview",div(id="clinical_data_preview",style="margin:10px")),
                                             tabPanel(title="Expression Data Preview",div(id="survival_exp_preview",style="margin:10px"))
                                 )
                             )
                         ),
                         div(id="survival_result_panel",class="row")
)
analysis_tab=tabItem(tabName = "analysis",
                     tabsetPanel(type="pills",
                                 network_property_panel,
                                 network_module_panel,
                                 enrichment_panel,
                                 survival_panel
                      )
)