visual_tab=tabItem(tabName = "visualization",
                   h2("Network Visualization",style='font-family:Georgia'),
                   div(class='row',
                       div(class='col-lg-2',
                           div( id="choose_differ_layout",class="form-group",
                                h4("choose layout",style="font-family:Georgia;font-weight:bold") 
                                
                           ),
                           div(class="form-group",id="choose_differ_name",
                               h4("change gene name",style="font-family:Georgia;font-weight:bold")
                           ),
                           div(class="form-group",id="export_network_png",
                               h4("export network",style="font-family:Georgia;font-weight:bold")
                           )
                       ),
                       div(class='col-lg-3',id='change_network_color'
                           
                       ),
                       div(class='col-lg-3',id='change_network_shape'),
                       div(class='col-lg-3',id='select_network_node',
                           h4("Select node",style="font-family:Georgia;font-weight:bold"),
                           div(class='input-group margin',style="margin:0px"
                           ) 
                       )
                   ),
                   div(id='cy')
                   
)