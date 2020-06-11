library(shiny)
textButtonInput <- function(inputId, label, buttonid,value = "",readonly=F,width='100%',status='primary') {
  tagList(
    # This makes web page load the JS file in the HTML head.
    # The call to singleton ensures it's only included once
    # in a page.
        singleton(
          tags$head(
            tags$script(src = "js/customerUI.js")
          )
        ),
        div(class='textButtonInput form-group shiny-input-container',style=paste("width:'",width,"'",sep=""),
          tags$label(label, `for` = inputId),
          div(class="input-group",
              tags$span(class='input-group-btn',
                        tags$input(id = inputId, type = "text", value = value,readonly=readonly,class='form-control shiny-bound-input'),
                        tags$button(class=paste('btn btn-',status,' action-button',sep=""),type='button',HTML('Choose'),id=buttonid)
              )
          )
        )
      )
}
value_BoxInput <- function(value, subtitle, icon, color='aqua', width = 4,inputId){
  tagList(
    singleton(
      tags$head(
        tags$script(src = "js/customerUI.js")
      )
    ),
    div(class=paste("col-sm-",width,sep = ""),id= inputId,
      div(class=paste('value_BoxInput small-box bg-',color,sep = ""),style=paste("width:'",width,"'",sep=""),
        div(class="inner",
           
               h3(value),
               h4(subtitle,style ="font-family: Georgia;font-weight:bold")
        ), 
        div(class="icon-large",
            tags$i(class=paste("fab fa-",icon,sep = ""))
        ),
        a( href="#" ,class = "small-box-footer",h4("Details",
                                                   tags$i(class="fa fa-arrow-circle-right"),
                                                   style ="font-family: Georgia;font-weight:bold")
        )
     )       
     
    )
    
  )
}
