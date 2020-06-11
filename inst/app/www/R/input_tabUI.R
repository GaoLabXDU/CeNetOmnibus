input_tab= tabItem(tabName = "input",
                   div(class="row",
                       div(class="col-lg-2",
                           tags$button(id="Cenet_demo", type="button",class="btn bg-navy btn-block btn-flat",
                              tags$i(class="fa fa-upload",'aria-hidden'="true"),HTML("Upload Demo Data")            
                           )
                       )
                   ),
                   h2("Step1: Expression Input",style='font-family:Georgia'),
                   fluidRow(
                     box(#第一部分
                       title = "Expression",collapsible = T,collapsed = F,status = 'success',solidHeader=T,footer = tags$button(id = 'express_preview', type = "button",class = "btn btn-success action-button pull-right",HTML('Preview'),width='20'), 
                       fileInput('ceRNA',label='mRNA/lncRNA/circRNA Expression'),
                       div(class='col-lg-6',style='display:inline-block;padding:0px',
                           prettyRadioButtons(inputId = 'ceRNA_seperator',label = 'Seprator',choices = c("Tab"="\t",'Comma'=',','Space'=' ','Semicolon'=';'),status='success',inline=T)
                       ),
                       div(style='display:inline-block;padding:0px',
                           textInput('ceRNA_seprator_cus',label='Custom Seprator')),
                       #prettyRadioButtons(inputId = 'ceRNA_quote',label = 'Quote',choices = c("None"="",'Double Quote'='\"','Single Quote'='\''),selected='',status='success',inline=T),
                       prettyRadioButtons(inputId = 'ceRNA_header',label = 'Header',choices = c("With header"=T,'Without header'=F),selected=T,status='success',inline=T),
                       #prettyRadioButtons(inputId = 'ceRNA_row_col',label = 'Representation',choices = c("Rows For Genes"=T,'Columns For Genes'=F),selected=T,status='success',inline=T),
                       prettyRadioButtons(inputId = 'ceRNA_first_col',label = 'First Column For Row Name?',choices = c("Yes"=T,'No'=F),selected=F,status='success',inline=T),
                       #第二部分
                       tags$hr(),
                       fileInput('micro',label='MicroRNA Expression'),
                       div(prettyRadioButtons(inputId = 'micro_seperator',label = 'Seperator',choices = c("Tab"="\t",'Comma'=',','Space'=' ','Semicolon'=';'),selected="\t",status='success',inline=T),style='display:inline-block;'),
                       div(textInput('micro_seprator_cus',label='Custom Seprator'),style='display:inline-block;padding-left:20px'),
                       #prettyRadioButtons(inputId = 'micro_quote',label = 'Quote',choices = c("None"="",'Double Quote'='\"','Single Quote'='\''),selected='',status='success',inline=T),
                       prettyRadioButtons(inputId = 'micro_header',label = 'Header',choices = c("With header"=T,'Without header'=F),selected=T,status='success',inline=T),
                       #prettyRadioButtons(inputId = 'micro_row_col',label = 'Representation',choices = c("Rows For Genes"=T,'Columns For Genes'=F),selected=T,status='success',inline=T),
                       prettyRadioButtons(inputId = 'micro_first_col',label = 'First Column For Row Name?',choices = c("Yes"=T,'No'=F),selected=F,status='success',inline=T)
                     ),
                     box(title = "Expression Preview",collapsible = T,collapsed = F,status = 'success',solidHeader=T,
                         tabsetPanel(
                           #tabsetPanel(
                           tabPanel(title='CeRNA',
                                    
                                    tableOutput('ceRNA_preview')
                                    
                           ),
                           tabPanel(title='MicroRNA',
                                    div(
                                      tableOutput('microRNA_preview')
                                    )
                           ),
                           id='Preview_panel'
                         )
                     )
                   ),
                   h2("Step2: Target Input",style='font-family:Georgia'),
                   fluidRow(
                     box(title = "MicroRNA Target",collapsible = T,collapsed = F,status = 'danger',solidHeader=T,footer = tags$button(id = 'target_preview', type = "button",class = "btn btn-danger action-button pull-right",HTML('Preview'),width='20'),
                         fileInput('target',label='MicroRNA Target'),
                         div(prettyRadioButtons(inputId = 'target_seperator',label = 'Seperator',choices = c("Tab"="\t",'Comma'=',','Space'=' ','Semicolon'=';'),status='danger',inline=T),
                             style='display:inline-block;'),
                         div(textInput('target_seprator_cus',label='Custom Seprator'),style='display:inline-block;padding-left:20px'),
                         #prettyRadioButtons(inputId = 'target_quote',label = 'Quote',choices = c("None"="",'Double Quote'='\"','Single Quote'='\''),selected='',status='danger',inline=T),
                         prettyRadioButtons(inputId = 'target_header',label = 'Header',choices = c("With header"=T,'Without header'=F),selected=T,status='danger',inline=T),
                         prettyRadioButtons(inputId = 'target_first_col',label = 'First Column For Row Name?',choices = c("Yes"=T,'No'=F),selected=F,status='danger',inline=T)
                         
                     ),
                     box(title = 'MicroRNA Target Preview',collapsible = T,collapsed = F,status = 'danger',solidHeader = T,
                         tableOutput('target_preview_panel')
                     )
                   ),
                   h2('Step3: Gene Information Input',style='font-family:Georgia'),
                   fluidRow(
                     box(title = "Gene Information",collapsible = T,collapsed = F,status = 'warning',solidHeader=T,
                         footer = list(downloadButton(outputId = "geneinfo_export",label = "Export"),
                                    tags$button(id = 'geneinfo_preview', type = "button",class = "btn btn-warning action-button pull-right",HTML('Preview'),width='20')),
                         selectInput('geneinfo_source',label='Gene Information Source',choices = c('Biomart'='biomart','Custom'='custom'),selected='biomart'),
                         conditionalPanel(
                           condition='input.geneinfo_source=="biomart"',
                           div(class='col-lg-4',
                               textButtonInput(inputId = 'archieve',label = 'Ensembl Archieve',value='www.ensembl.org',buttonid = 'archieve_choose',status = 'warning',readonly = 'readonly'),
                               style='display:inline-block;padding:0px'
                           ),
                           div(class='col-lg-2'),
                           div(class='col-lg-4',
                               textButtonInput(inputId = 'database',label = 'Database(Species)',value='hsapiens_gene_ensembl',buttonid = 'database_choose',status = 'warning',readonly = 'readonly')
                           ),
                           tags$br(),
                           div(class='col-lg-4',style='padding:0px',
                               textButtonInput(inputId = 'filter',label = 'Input Gene Type',value='',buttonid='filter_choose',readonly = 'readonly',status = 'warning')                           
                           ),
                           tags$br(),
                           div(class='col-lg-12',style='padding:0px',
                               selectInput(inputId='attribution',label = 'Attribution',choices = "",selected = T,selectize = T)
                           ),
                           tags$br(),
                           div(class='col-lg-4',style='padding:0px',
                               selectInput('select_gene_source',label='Select Gene Source',choices = c('From Input File'='input','Custom'='custom'),selected='input')
                           ),
                           div(class='col-lg-2'),
                           div(class='col-lg-4',style='padding:0px',
                               conditionalPanel(condition = 'input.select_gene_source=="input"',
                                                textButtonInput(inputId='gene',label = 'Select Genes',value = 'Current Selected Gene#: 0',buttonid = 'gene_choose',readonly = 'readonly',status='warning')
                               )
                           ),
                           conditionalPanel(condition = 'input.select_gene_source=="custom"',
                                            div(class='col-lg-12',style="padding:0px",
                                                textAreaInput(inputId = 'custom_select_gene',label = 'Custom Select Genes',resize = 'vertical',rows=8)  
                                            )
                           )
                         ),
                         conditionalPanel(
                           condition='input.geneinfo_source=="custom"',
                           fileInput('geneinfo',label='Gene Information'),
                           div(prettyRadioButtons(inputId = 'geneinfo_seperator',label = 'Seperator',choices = c("Tab"="\t",'Comma'=',','Space'=' ','Semicolon'=';'),status='warning',inline=T),
                               style='display:inline-block;'),
                           div(textInput('geneinfo_seprator_cus',label='Custom Seprator'),style='display:inline-block;padding-left:20px;'),
                           #prettyRadioButtons(inputId = 'geneinfo_quote',label = 'Quote',choices = c("None"="",'Double Quote'='\"','Single Quote'='\''),selected='',status='warning',inline=T),
                           prettyRadioButtons(inputId = 'geneinfo_header',label = 'Header',choices = c("With header"=T,'Without header'=F),selected=T,status='warning',inline=T),
                           prettyRadioButtons(inputId = 'geneinfo_first_col',label = 'First Column For Row Name?',choices = c("Yes"=T,'No'=F),selected=T,status='warning',inline=T),
                           tags$hr()
                         )
                         
                     ),
                     box(title = 'Gene Information Preview',collapsible = T,collapsed = F,status = 'warning',solidHeader = T,
                         tableOutput('geneinfo_preview_panel')
                     )
                   ),
                   fluidRow(
                     div(class="col-lg-12",
                         tags$button(HTML("Next"),onclick="next_tab('#shiny-tab-process')",class='btn btn-warning action-button shiny-bound-input')
                     )
                   )
)