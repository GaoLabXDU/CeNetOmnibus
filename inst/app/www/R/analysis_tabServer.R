node_property=c()
edge_property=c()
modules=list()
module.configure=list()
moduleinfo=""
nodeNewInfo=""
default.configure=list(color="red",
                       color.attr="All",
                       layout="layout_nicely",
                       shape="circle",
                       shape.attr="All",
                       size=5,
                       label="")
clinical_data=""
survival_exp=""
valid_patient=""
custom_gene_set=""

create_cluster_walktrap_test_ui=function(session)
{
  ui=div(class='row',
         div(class='col-lg-3', numericInput(inputId = 'step_start',label = "Step Begin",value = 1,min = 1,step = 1)),
         div(class='col-lg-3',numericInput(inputId = 'step_step',label = "Test step of Step",value = 1,min = 1,step = 1)),
         div(class='col-lg-3',numericInput(inputId = 'step_stop',label = "Step End",value = 2,min = 2,step = 1))
  )
  removeUI(selector = "#modaltitle")
  insertUI(selector = "infolist>div.modal-dialog>div.modal-content>div.modal-header",where = 'afterBegin',ui = h4(id="modaltitle",class="modal-title",HTML("Set Parameter Test of Random Walk")))
  removeUI(selector = "#modalbody>",multiple = T,immediate = T,session = session)
  insertUI(selector = "#modalbody",where = "beforeEnd",ui = ui,multiple = T,immediate = T)
  removeUI(selector = "#modalSubmit")
  insertUI(selector = "div.modal-footer",where = 'afterBegin',ui = tags$button(id='modalSubmit',class='btn btn-primary',type="button",HTML("Run"),onclick='run_parameter_test("cluster_walktrap")'))
  session$sendCustomMessage('show_community_parameter_test_modal',"")
}
run_cluster_walktrap_test=function(input,output,session)
{
  start=input$step_start
  step=input$step_step
  stop=input$step_stop
  if(step==0)
  {
    sendSweetAlert(session = session,title = "Error",text = "Step can't be 0",type = 'error')
    return()
  }
  if(start>stop)
  {
    sendSweetAlert(session = session,title = "Error",text = "The Begin can't larger than End",type = 'error')
    return()
  }
  summary=data.frame()
  detail=data.frame()
  progress=0
  allprogress=setdiff(seq(from=start,to = stop,by = step),0)
  for(i in allprogress)
  {
    progress=progress+1
    session$sendCustomMessage("test_parameter_status",message = list(status='run',info=paste("Running Step =",i),progress=round(progress/length(allprogress),digits = 2)*100))
    community=cluster_walktrap(graph = net_igraph,steps = i)
    communitySize=sizes(community)
    singleNodeCommunity=as.numeric(names(communitySize[which(communitySize==1)]))
    membership=membership(community)
    com_mod=modularity(x = net_igraph,membership=membership)
    membership[which(membership%in%singleNodeCommunity)]=0
    isolatednode=length(singleNodeCommunity)
    com_count=length(unique(membership))

    tmp=data.frame()
    for(com in setdiff(unique(membership),0))
    {
      mg=names(membership[membership==com])
      subgraph=subgraph(graph = net_igraph,v = mg)
      node_count=length(mg)
      edge_count=gsize(subgraph)
      density=edge_count/(node_count*(node_count-1)/2)
      tmp=rbind(tmp,data.frame(para=i,nodecount=node_count,edgecount=edge_count,density=density,stringsAsFactors = F))
    }
    summary=rbind(summary,data.frame(para=i,singleNode=isolatednode,community=com_count,modularity=com_mod,density=mean(tmp$density,na.rm = T),stringsAsFactors = F))
    detail=rbind(detail,tmp)
  }
  basic_theme=theme(legend.position = 'bottom',
                    axis.line = element_line(linetype = "solid"),
                    panel.grid.minor = element_line(linetype = "blank"),
                    axis.title = element_text(family = "serif",size=14,color='black'),
                    axis.text = element_text(family = "serif",size=14,color='black'),
                    axis.text.x = element_text(family = "serif"),
                    axis.text.y = element_text(family = "serif"),
                    plot.title = element_text(family = "serif", hjust = 0.5,size=18,color='black'),
                    legend.text = element_text(family = "serif",size=14,colour = 'black'),
                    legend.title = element_text(family = "serif",size=14,color='black'),
                    panel.background = element_rect(fill = NA),
                    plot.background = element_rect(colour = NA),
                    legend.key = element_rect(fill = NA),
                    legend.background = element_rect(fill = NA),
                    legend.direction = "horizontal")
  summary$para=as.factor(summary$para)
  detail$para=as.factor(detail$para)
  p1=ggplot(data = summary)+
    geom_bar(mapping = aes(x = para,y = modularity,fill=para),stat='identity')+
    scale_fill_manual(values = colorRampPalette(usedcolors)(length(allprogress)))+
    basic_theme+labs(title="Modularity",x="Step")+
    theme(legend.position ='none')
  p2=ggplot(data = summary)+
    geom_bar(mapping = aes(x = para,y = density,fill=para),stat='identity')+
    scale_fill_manual(values = colorRampPalette(usedcolors)(length(allprogress)))+
    basic_theme+labs(title="Average Density",x="Step")+
    theme(legend.position='none')
  p3=ggplot(data = summary)+
    geom_bar(mapping = aes(x = para,y = community,fill=para),stat='identity')+
    scale_fill_manual(values = colorRampPalette(usedcolors)(length(allprogress)))+
    basic_theme+labs(title="Community Count",x="Step")+
    theme(legend.position='none')
  p4=ggplot(data=detail)+
    geom_boxplot(mapping = aes(x = para,y = nodecount,fill=para))+
    scale_fill_manual(values = colorRampPalette(usedcolors)(length(allprogress)))+
    basic_theme+labs(title="Community Node Count Distribution",x="Step")+
    theme(legend.position='none')
  p5=ggplot(data=detail)+
    geom_boxplot(mapping = aes(x = para,y = edgecount,fill=para))+
    scale_fill_manual(values = colorRampPalette(usedcolors)(length(allprogress)))+
    basic_theme+labs(title="Community Edge Count Distribution",x="Step")+
    theme(legend.position='none')
  p6=ggplot(data=detail)+
    geom_boxplot(mapping = aes(x = para,y = density,fill=para))+
    scale_fill_manual(values = colorRampPalette(usedcolors)(length(allprogress)))+
    basic_theme+labs(title="Community Density Distribution",x="Step")+
    theme(legend.position='none')

  svglite(paste(basepath,"/Plot/community_parameter_test1.svg",sep=""))
  print((p1|p2)/(p3|plot_spacer()))
  dev.off()
  svglite(paste(basepath,"/Plot/community_parameter_test2.svg",sep=""))
  print((p4|p5)/(p6|plot_spacer()))
  dev.off()

  session$sendCustomMessage("test_parameter_status",message = list(status='complete',info=paste('Finish'),progress=100))
  removeUI(selector = "#parameter_test_1",multiple = T,immediate = T,session = session)
  removeUI(selector = "#parameter_test_2",multiple = T,immediate = T,session = session)
  insertUI(selector = "#modalbody",where = 'beforeEnd',ui = plotOutput(outputId = "parameter_test_1",width = "100%",height = "100%"))
  insertUI(selector = "#modalbody",where = 'beforeEnd',ui = plotOutput(outputId = "parameter_test_2",width = "100%",height = "100%"))
  output[['parameter_test_1']]=renderImage({list(src=paste(basepath,"/Plot/community_parameter_test1.svg",sep=""),width="100%",height="100%")},deleteFile = F)
  output[['parameter_test_2']]=renderImage({list(src=paste(basepath,"/Plot/community_parameter_test2.svg",sep=""),width="100%",height="100%")},deleteFile = F)

}
create_cluster_infomap_test_ui=function(session)
{
  ui=div(class='row',
         div(class='col-lg-3', numericInput(inputId = 'step_start',label = "Module Count Begin",value = 1,min = 1,step = 1)),
         div(class='col-lg-3',numericInput(inputId = 'step_step',label = "Module Count Step",value = 1,min = 1,step = 1)),
         div(class='col-lg-3',numericInput(inputId = 'step_stop',label = "Module COunt End",value = 2,min = 2,step = 1))
  )
  removeUI(selector = "#modaltitle")
  insertUI(selector = "infolist>div.modal-dialog>div.modal-content>div.modal-header",where = 'afterBegin',ui = h4(id="modaltitle",class="modal-title",HTML("Set Parameter Test of Random Walk")))
  removeUI(selector = "#modalbody>",multiple = T,immediate = T,session = session)
  insertUI(selector = "#modalbody",where = "beforeEnd",ui = ui,multiple = T,immediate = T)
  removeUI(selector = "#modalSubmit")
  insertUI(selector = "div.modal-footer",where = 'afterBegin',ui = tags$button(id='modalSubmit',class='btn btn-primary',type="button",HTML("Run"),onclick='run_parameter_test("cluster_infomap")'))
  session$sendCustomMessage('show_community_parameter_test_modal',"")
}
run_cluster_infomap_test=function(input,output,session)
{
  start=input$step_start
  step=input$step_step
  stop=input$step_stop
  if(step==0)
  {
    sendSweetAlert(session = session,title = "Error",text = "Step can't be 0",type = 'error')
    return()
  }
  if(start>stop)
  {
    sendSweetAlert(session = session,title = "Error",text = "The Begin can't larger than End",type = 'error')
    return()
  }
  summary=data.frame()
  detail=data.frame()
  progress=0
  allprogress=setdiff(seq(from=start,to = stop,by = step),0)
  for(i in allprogress)
  {
    progress=progress+1
    session$sendCustomMessage("test_parameter_status",message = list(status='run',info=paste("Running Step =",i),progress=round(progress/length(allprogress),digits = 2)*100))
    community=cluster_infomap(graph = net_igraph,nb.trials = i)
    communitySize=sizes(community)
    singleNodeCommunity=as.numeric(names(communitySize[which(communitySize==1)]))
    membership=membership(community)
    com_mod=modularity(x = net_igraph,membership=membership)
    membership[which(membership%in%singleNodeCommunity)]=0
    isolatednode=length(singleNodeCommunity)
    com_count=length(unique(membership))

    tmp=data.frame()
    for(com in setdiff(unique(membership),0))
    {
      mg=names(membership[membership==com])
      subgraph=subgraph(graph = net_igraph,v = mg)
      node_count=length(mg)
      edge_count=gsize(subgraph)
      density=edge_count/(node_count*(node_count-1)/2)
      tmp=rbind(tmp,data.frame(para=i,nodecount=node_count,edgecount=edge_count,density=density,stringsAsFactors = F))
    }
    summary=rbind(summary,data.frame(para=i,singleNode=isolatednode,community=com_count,modularity=com_mod,density=mean(tmp$density,na.rm = T),stringsAsFactors = F))
    detail=rbind(detail,tmp)
  }
  basic_theme=theme(legend.position = 'bottom',
                    axis.line = element_line(linetype = "solid"),
                    panel.grid.minor = element_line(linetype = "blank"),
                    axis.title = element_text(family = "serif",size=14,color='black'),
                    axis.text = element_text(family = "serif",size=14,color='black'),
                    axis.text.x = element_text(family = "serif"),
                    axis.text.y = element_text(family = "serif"),
                    plot.title = element_text(family = "serif", hjust = 0.5,size=18,color='black'),
                    legend.text = element_text(family = "serif",size=14,colour = 'black'),
                    legend.title = element_text(family = "serif",size=14,color='black'),
                    panel.background = element_rect(fill = NA),
                    plot.background = element_rect(colour = NA),
                    legend.key = element_rect(fill = NA),
                    legend.background = element_rect(fill = NA),
                    legend.direction = "horizontal")
  summary$para=as.factor(summary$para)
  detail$para=as.factor(detail$para)
  p1=ggplot(data = summary)+
    geom_bar(mapping = aes(x = para,y = modularity,fill=para),stat='identity')+
    scale_fill_manual(values = colorRampPalette(usedcolors)(length(allprogress)))+
    basic_theme+labs(title="Modularity",x="Module Count")+
    theme(legend.position ='none')
  p2=ggplot(data = summary)+
    geom_bar(mapping = aes(x = para,y = density,fill=para),stat='identity')+
    scale_fill_manual(values = colorRampPalette(usedcolors)(length(allprogress)))+
    basic_theme+labs(title="Average Density",x="Module Count")+
    theme(legend.position='none')
  p3=ggplot(data = summary)+
    geom_bar(mapping = aes(x = para,y = community,fill=para),stat='identity')+
    scale_fill_manual(values = colorRampPalette(usedcolors)(length(allprogress)))+
    basic_theme+labs(title="Community Count",x="Module Count")+
    theme(legend.position='none')
  p4=ggplot(data=detail)+
    geom_boxplot(mapping = aes(x = para,y = nodecount,fill=para))+
    scale_fill_manual(values = colorRampPalette(usedcolors)(length(allprogress)))+
    basic_theme+labs(title="Community Node Count Distribution",x="Module Count")+
    theme(legend.position='none')
  p5=ggplot(data=detail)+
    geom_boxplot(mapping = aes(x = para,y = edgecount,fill=para))+
    scale_fill_manual(values = colorRampPalette(usedcolors)(length(allprogress)))+
    basic_theme+labs(title="Community Edge Count Distribution",x="Module Count")+
    theme(legend.position='none')
  p6=ggplot(data=detail)+
    geom_boxplot(mapping = aes(x = para,y = density,fill=para))+
    scale_fill_manual(values = colorRampPalette(usedcolors)(length(allprogress)))+
    basic_theme+labs(title="Community Density Distribution",x="Module Count")+
    theme(legend.position='none')

  svglite(paste(basepath,"/Plot/community_parameter_test1.svg",sep=""))
  print((p1|p2)/(p3|plot_spacer()))
  dev.off()
  svglite(paste(basepath,"/Plot/community_parameter_test2.svg",sep=""))
  print((p4|p5)/(p6|plot_spacer()))
  dev.off()

  session$sendCustomMessage("test_parameter_status",message = list(status='complete',info=paste('Finish'),progress=100))
  removeUI(selector = "#parameter_test_1",multiple = T,immediate = T,session = session)
  removeUI(selector = "#parameter_test_2",multiple = T,immediate = T,session = session)
  insertUI(selector = "#modalbody",where = 'beforeEnd',ui = plotOutput(outputId = "parameter_test_1",width = "100%",height = "100%"))
  insertUI(selector = "#modalbody",where = 'beforeEnd',ui = plotOutput(outputId = "parameter_test_2",width = "100%",height = "100%"))
  output[['parameter_test_1']]=renderImage({list(src=paste(basepath,"/Plot/community_parameter_test1.svg",sep=""),width="100%",height="100%")},deleteFile = F)
  output[['parameter_test_2']]=renderImage({list(src=paste(basepath,"/Plot/community_parameter_test2.svg",sep=""),width="100%",height="100%")},deleteFile = F)

}
create_cluster_mcl_test_ui=function(session)
{
  ui=list(div(class='row',
               div(class='col-lg-3', numericInput(inputId = 'expansion_start',label = "Expansion Begin",value = 1,min = 1,step = 1)),
               div(class='col-lg-3',numericInput(inputId = 'expansion_step',label = "Expansion  Step",value = 1,min = 1,step = 1)),
               div(class='col-lg-3',numericInput(inputId = 'expansion_stop',label = "Expansion End",value = 2,min = 2,step = 1))
            ),
          div(class='row',
              div(class='col-lg-3', numericInput(inputId = 'inflation_start',label = "Inflation Begin",value = 1,min = 1,step = 1)),
              div(class='col-lg-3',numericInput(inputId = 'inflation_step',label = "Inflation Step",value = 1,min = 1,step = 1)),
              div(class='col-lg-3',numericInput(inputId = 'inflation_stop',label = "Inflation End",value = 2,min = 2,step = 1))
          )
  )
  removeUI(selector = "#modaltitle")
  insertUI(selector = "infolist>div.modal-dialog>div.modal-content>div.modal-header",where = 'afterBegin',ui = h4(id="modaltitle",class="modal-title",HTML("Set Parameter Test of Random Walk")))
  removeUI(selector = "#modalbody>",multiple = T,immediate = T,session = session)
  insertUI(selector = "#modalbody",where = "beforeEnd",ui = ui,multiple = T,immediate = T)
  removeUI(selector = "#modalSubmit")
  insertUI(selector = "div.modal-footer",where = 'afterBegin',ui = tags$button(id='modalSubmit',class='btn btn-primary',type="button",HTML("Run"),onclick='run_parameter_test("cluster_mcl")'))
  session$sendCustomMessage('show_community_parameter_test_modal',"")

}
run_cluster_mcl_test=function(input,output,session)
{
  e.start=input$expansion_start
  e.step=input$expansion_step
  e.stop=input$expansion_stop
  i.start=input$inflation_start
  i.step=input$inflation_step
  i.stop=input$inflation_stop
  if(e.step==0)
  {
    sendSweetAlert(session = session,title = "Error",text = "Expansion Step can't be 0",type = 'error')
    return()
  }
  if(e.start>e.stop)
  {
    sendSweetAlert(session = session,title = "Error",text = "The Expansion Begin can't larger than Expansion End",type = 'error')
    return()
  }
  if(i.step==0)
  {
    sendSweetAlert(session = session,title = "Error",text = "Inflation Step can't be 0",type = 'error')
    return()
  }
  if(i.start>i.stop)
  {
    sendSweetAlert(session = session,title = "Error",text = "The Inflation Begin can't larger than Inflation End",type = 'error')
    return()
  }
  summary=data.frame()
  detail=data.frame()
  progress=0
  allprogress=length(seq(from=e.start,to = e.stop,by = e.step))*length(seq(from=i.start,to = i.stop,by = i.step))
  for(i in seq(from=e.start,to = e.stop,by = e.step))
  {
    for(j in seq(from=i.start,to = i.stop,by = i.step))
    {
      print(paste(i,j))
      progress=progress+1
      session$sendCustomMessage("test_parameter_status",message = list(status='run',info=paste("Running Expansion =",i,'and Inflation =',j),progress=round(progress/allprogress,digits = 2)*100))
      community=mcl(as.matrix(as_adjacency_matrix(net_igraph,type='both')),addLoops = T,expansion = i,inflation = j,allow1 = T,max.iter = 100)
      if(!grepl(pattern = "Error",x = community))
      {
        membership=community$Cluster
        names(membership)=rownames(as_adjacency_matrix(net_igraph,type='both'))

        com_mod=modularity(x = net_igraph,membership=membership)
        isolatecommunity=as.numeric(names(which(table(membership)==1)))
        singleNodeCommunity=names(membership)[membership %in% isolatecommunity]
        membership[membership%in%isolatecommunity]=0
        isolatednode=length(singleNodeCommunity)
        com_count=length(unique(membership))

        tmp=data.frame()
        for(com in setdiff(unique(membership),0))
        {
          mg=names(membership[membership==com])
          subgraph=subgraph(graph = net_igraph,v = mg)
          node_count=length(mg)
          edge_count=gsize(subgraph)
          density=edge_count/(node_count*(node_count-1)/2)
          tmp=rbind(tmp,data.frame(expansion=i,inflation=paste("Inflation",j),nodecount=node_count,edgecount=edge_count,density=density,stringsAsFactors = F))
        }
        summary=rbind(summary,data.frame(expansion=i,inflation=paste("Inflation",j),singleNode=isolatednode,community=com_count,modularity=com_mod,density=mean(tmp$density,na.rm = T),stringsAsFactors = F))
        detail=rbind(detail,tmp)
      }
      else
      {
        summary=rbind(summary,data.frame(expansion=i,inflation=paste("Inflation",j),singleNode=NA,community=NA,modularity=NA,density=NA,stringsAsFactors = F))
        detail=rbind(detail,data.frame(expansion=i,inflation=paste("Inflation",j),nodecount=NA,edgecount=NA,density=NA,stringsAsFactors = F))
      }
    }
  }
  basic_theme=theme(legend.position = 'bottom',
                    axis.line = element_line(linetype = "solid"),
                    panel.grid.minor = element_line(linetype = "blank"),
                    axis.title = element_text(family = "serif",size=14,color='black'),
                    axis.text = element_text(family = "serif",size=14,color='black'),
                    axis.text.x = element_text(family = "serif"),
                    axis.text.y = element_text(family = "serif"),
                    plot.title = element_text(family = "serif", hjust = 0.5,size=18,color='black'),
                    legend.text = element_text(family = "serif",size=14,colour = 'black'),
                    legend.title = element_text(family = "serif",size=14,color='black'),
                    panel.background = element_rect(fill = NA),
                    plot.background = element_rect(colour = NA),
                    legend.key = element_rect(fill = NA),
                    legend.background = element_rect(fill = NA),
                    legend.direction = "horizontal")
  summary$expansion=as.factor(summary$expansion)
  summary$inflation=as.factor(summary$inflation)
  detail$expansion=as.factor(detail$expansion)
  detail$expansion=as.factor(detail$inflation)
  p1=ggplot(data = summary)+
    geom_bar(mapping = aes(x = expansion,y = modularity,fill=expansion),stat='identity')+
    facet_wrap(~inflation,scales = 'free_y')+
    scale_fill_manual(values = colorRampPalette(usedcolors)(allprogress))+
    basic_theme+labs(title="Modularity",x="Expansion")+
    theme(legend.position ='none')
  p2=ggplot(data = summary)+
    geom_bar(mapping = aes(x = expansion,y = density,fill=expansion),stat='identity')+
    facet_wrap(~inflation,scales = 'free_y')+
    scale_fill_manual(values = colorRampPalette(usedcolors)(allprogress))+
    basic_theme+labs(title="Average Density",x="Expansion")+
    theme(legend.position='none')
  p3=ggplot(data = summary)+
    geom_bar(mapping = aes(x = expansion,y = community,fill=expansion),stat='identity')+
    facet_wrap(~inflation,scales = 'free_y')+
    scale_fill_manual(values = colorRampPalette(usedcolors)(allprogress))+
    basic_theme+labs(title="Community Count",x="Expansion")+
    theme(legend.position='none')
  p4=ggplot(data=detail)+
    geom_boxplot(mapping = aes(x = expansion,y = nodecount,fill=expansion))+
    facet_wrap(~inflation,scales = 'free_y')+
    scale_fill_manual(values = colorRampPalette(usedcolors)(allprogress))+
    basic_theme+labs(title="Community Node Count Distribution",x="Expansion")+
    theme(legend.position='none')
  p5=ggplot(data=detail)+
    geom_boxplot(mapping = aes(x = expansion,y = edgecount,fill=expansion))+
    facet_wrap(~inflation,scales = 'free_y')+
    scale_fill_manual(values = colorRampPalette(usedcolors)(allprogress))+
    basic_theme+labs(title="Community Edge Count Distribution",x="Expansion")+
    theme(legend.position='none')
  p6=ggplot(data=detail)+
    geom_boxplot(mapping = aes(x = expansion,y = density,fill=expansion))+
    facet_wrap(~inflation,scales = 'free_y')+
    scale_fill_manual(values = colorRampPalette(usedcolors)(allprogress))+
    basic_theme+labs(title="Community Density Distribution",x="Expansion")+
    theme(legend.position='none')

  svglite(paste(basepath,"/Plot/community_parameter_test1.svg",sep=""))
  print(p1)
  dev.off()
  svglite(paste(basepath,"/Plot/community_parameter_test2.svg",sep=""))
  print(p2)
  dev.off()
  svglite(paste(basepath,"/Plot/community_parameter_test3.svg",sep=""))
  print(p3)
  dev.off()
  svglite(paste(basepath,"/Plot/community_parameter_test4.svg",sep=""))
  print(p4)
  dev.off()
  svglite(paste(basepath,"/Plot/community_parameter_test5.svg",sep=""))
  print(p5)
  dev.off()
  svglite(paste(basepath,"/Plot/community_parameter_test6.svg",sep=""))
  print(p6)
  dev.off()

  session$sendCustomMessage("test_parameter_status",message = list(status='complete',info=paste('Finish'),progress=100))
  removeUI(selector = "#parameter_test_1",multiple = T,immediate = T,session = session)
  removeUI(selector = "#parameter_test_2",multiple = T,immediate = T,session = session)
  removeUI(selector = "#parameter_test_3",multiple = T,immediate = T,session = session)
  removeUI(selector = "#parameter_test_4",multiple = T,immediate = T,session = session)
  removeUI(selector = "#parameter_test_5",multiple = T,immediate = T,session = session)
  removeUI(selector = "#parameter_test_6",multiple = T,immediate = T,session = session)
  insertUI(selector = "#modalbody",where = 'beforeEnd',ui = plotOutput(outputId = "parameter_test_1",width = "100%",height = "100%"))
  insertUI(selector = "#modalbody",where = 'beforeEnd',ui = plotOutput(outputId = "parameter_test_2",width = "100%",height = "100%"))
  insertUI(selector = "#modalbody",where = 'beforeEnd',ui = plotOutput(outputId = "parameter_test_3",width = "100%",height = "100%"))
  insertUI(selector = "#modalbody",where = 'beforeEnd',ui = plotOutput(outputId = "parameter_test_4",width = "100%",height = "100%"))
  insertUI(selector = "#modalbody",where = 'beforeEnd',ui = plotOutput(outputId = "parameter_test_5",width = "100%",height = "100%"))
  insertUI(selector = "#modalbody",where = 'beforeEnd',ui = plotOutput(outputId = "parameter_test_6",width = "100%",height = "100%"))
  output[['parameter_test_1']]=renderImage({list(src=paste(basepath,"/Plot/community_parameter_test1.svg",sep=""),width="100%",height="100%")},deleteFile = F)
  output[['parameter_test_2']]=renderImage({list(src=paste(basepath,"/Plot/community_parameter_test2.svg",sep=""),width="100%",height="100%")},deleteFile = F)
  output[['parameter_test_3']]=renderImage({list(src=paste(basepath,"/Plot/community_parameter_test3.svg",sep=""),width="100%",height="100%")},deleteFile = F)
  output[['parameter_test_4']]=renderImage({list(src=paste(basepath,"/Plot/community_parameter_test4.svg",sep=""),width="100%",height="100%")},deleteFile = F)
  output[['parameter_test_5']]=renderImage({list(src=paste(basepath,"/Plot/community_parameter_test5.svg",sep=""),width="100%",height="100%")},deleteFile = F)
  output[['parameter_test_6']]=renderImage({list(src=paste(basepath,"/Plot/community_parameter_test6.svg",sep=""),width="100%",height="100%")},deleteFile = F)

}
create_cluster_linkcomm_test_ui=function(session)
{
  ui=div(class='row',
         div(class='col-lg-12', checkboxGroupButtons(inputId = "hierarchical_clustering",label = 'Select hierarchical clustering method',
                                                    choices = c("average"="average","ward"="ward","single"="single","complete"="complete",
                                                                "mcquitty"="mcquitty","median"="median",'centroid'='centroid'),size = 'normal',
                                                    status = 'primary',individual = T,
                                                    checkIcon = list(yes = icon("ok",lib = "glyphicon"),
                                                                     no = icon("remove",lib = "glyphicon"))))
  )
  removeUI(selector = "#modaltitle")
  insertUI(selector = "infolist>div.modal-dialog>div.modal-content>div.modal-header",where = 'afterBegin',ui = h4(id="modaltitle",class="modal-title",HTML("Set Parameter Test of LinkComm")))
  removeUI(selector = "#modalbody>",multiple = T,immediate = T,session = session)
  insertUI(selector = "#modalbody",where = "beforeEnd",ui = ui,multiple = T,immediate = T)
  removeUI(selector = "#modalSubmit")
  insertUI(selector = "div.modal-footer",where = 'afterBegin',ui = tags$button(id='modalSubmit',class='btn btn-primary',type="button",HTML("Run"),onclick='run_parameter_test("cluster_linkcomm")'))
  session$sendCustomMessage('show_community_parameter_test_modal',"")

}
run_cluster_linkcomm_test=function(input,output,session)
{
  method=input$hierarchical_clustering
  if(is.null(method))
  {
    sendSweetAlert(session = session,title = "Error",text = "Select At least One Method",type = 'error')
    return()
  }
  summary=data.frame()
  detail=data.frame()
  progress=0
  allprogress=length(method)
  for(i in method)
  {
    progress=progress+1
    session$sendCustomMessage("test_parameter_status",message = list(status='run',info=paste("Running hierarchical_clustering =",i),progress=round(progress/length(method),digits = 2)*100))
    edgeinfo=get.edgelist(net_igraph,names = T)
    colnames(edgeinfo)=c("N1",'N2')
    community=cluster_linkcomm(edgeinfo,hcmethod = i)
    membership=as.numeric(community$cluster)
    names(membership)=community$node

    isolatenode=setdiff(names(V(net_igraph)),names(membership))
    isolatecommunity=seq(from=max(membership)+1,by = 1,length.out = length(isolatenode))
    names(isolatecommunity)=isolatenode
    membership=c(membership,isolatecommunity)

    com_mod=modularity(x = net_igraph,membership=membership)
    isolatednode=length(isolatecommunity)
    membership[membership%in%isolatecommunity]=0
    com_count=length(unique(membership))

    tmp=data.frame()
    for(com in setdiff(unique(membership),0))
    {
      mg=names(membership[membership==com])
      subgraph=subgraph(graph = net_igraph,v = mg)
      node_count=length(mg)
      edge_count=gsize(subgraph)
      density=edge_count/(node_count*(node_count-1)/2)
      tmp=rbind(tmp,data.frame(para=i,nodecount=node_count,edgecount=edge_count,density=density,stringsAsFactors = F))
    }
    summary=rbind(summary,data.frame(para=i,singleNode=isolatednode,community=com_count,modularity=com_mod,density=mean(tmp$density,na.rm = T),stringsAsFactors = F))
    detail=rbind(detail,tmp)
  }
  basic_theme=theme(legend.position = 'bottom',
                    axis.line = element_line(linetype = "solid"),
                    panel.grid.minor = element_line(linetype = "blank"),
                    axis.title = element_text(family = "serif",size=14,color='black'),
                    axis.text = element_text(family = "serif",size=14,color='black'),
                    axis.text.x = element_text(family = "serif"),
                    axis.text.y = element_text(family = "serif"),
                    plot.title = element_text(family = "serif", hjust = 0.5,size=18,color='black'),
                    legend.text = element_text(family = "serif",size=14,colour = 'black'),
                    legend.title = element_text(family = "serif",size=14,color='black'),
                    panel.background = element_rect(fill = NA),
                    plot.background = element_rect(colour = NA),
                    legend.key = element_rect(fill = NA),
                    legend.background = element_rect(fill = NA),
                    legend.direction = "horizontal")
  summary$para=as.factor(summary$para)
  detail$para=as.factor(detail$para)
  p1=ggplot(data = summary)+
    geom_bar(mapping = aes(x = para,y = modularity,fill=para),stat='identity')+
    scale_fill_manual(values = colorRampPalette(usedcolors)(length(method)))+
    basic_theme+labs(title="Modularity",x="Hierarchical Clustering Method")+
    theme(legend.position ='none')
  p2=ggplot(data = summary)+
    geom_bar(mapping = aes(x = para,y = density,fill=para),stat='identity')+
    scale_fill_manual(values = colorRampPalette(usedcolors)(length(method)))+
    basic_theme+labs(title="Average Density",x="Hierarchical Clustering Method")+
    theme(legend.position='none')
  p3=ggplot(data = summary)+
    geom_bar(mapping = aes(x = para,y = community,fill=para),stat='identity')+
    scale_fill_manual(values = colorRampPalette(usedcolors)(length(method)))+
    basic_theme+labs(title="Community Count",x="Hierarchical Clustering Method")+
    theme(legend.position='none')
  p4=ggplot(data=detail)+
    geom_boxplot(mapping = aes(x = para,y = nodecount,fill=para))+
    scale_fill_manual(values = colorRampPalette(usedcolors)(length(method)))+
    basic_theme+labs(title="Community Node Count Distribution",x="Hierarchical Clustering Method")+
    theme(legend.position='none')
  p5=ggplot(data=detail)+
    geom_boxplot(mapping = aes(x = para,y = edgecount,fill=para))+
    scale_fill_manual(values = colorRampPalette(usedcolors)(length(method)))+
    basic_theme+labs(title="Community Edge Count Distribution",x="Hierarchical Clustering Method")+
    theme(legend.position='none')
  p6=ggplot(data=detail)+
    geom_boxplot(mapping = aes(x = para,y = density,fill=para))+
    scale_fill_manual(values = colorRampPalette(usedcolors)(length(method)))+
    basic_theme+labs(title="Community Density Distribution",x="Hierarchical Clustering Method")+
    theme(legend.position='none')

  svglite(paste(basepath,"/Plot/community_parameter_test1.svg",sep=""))
  print((p1|p2)/(p3|plot_spacer()))
  dev.off()
  svglite(paste(basepath,"/Plot/community_parameter_test2.svg",sep=""))
  print((p4|p5)/(p6|plot_spacer()))
  dev.off()

  session$sendCustomMessage("test_parameter_status",message = list(status='complete',info=paste('Finish'),progress=100))

  removeUI(selector = "#parameter_test_1",multiple = T,immediate = T,session = session)
  removeUI(selector = "#parameter_test_2",multiple = T,immediate = T,session = session)
  insertUI(selector = "#modalbody",where = 'beforeEnd',ui = plotOutput(outputId = "parameter_test_1",width = "100%",height = "100%"))
  insertUI(selector = "#modalbody",where = 'beforeEnd',ui = plotOutput(outputId = "parameter_test_2",width = "100%",height = "100%"))
  output[['parameter_test_1']]=renderImage({list(src=paste(basepath,"/Plot/community_parameter_test1.svg",sep=""),width="100%",height="100%")},deleteFile = F)
  output[['parameter_test_2']]=renderImage({list(src=paste(basepath,"/Plot/community_parameter_test2.svg",sep=""),width="100%",height="100%")},deleteFile = F)

}
create_cluster_mcode_test_ui=function(session)
{
  ui=list(div(class='row',
              div(class='col-lg-3', numericInput(inputId = 'vertex_start',label = "Vertex Weight Begin",value = 0.5,min = 0,max = 1,step = 0.1)),
              div(class='col-lg-3',numericInput(inputId = 'vertex_step',label = "Vertex Weight Step",value = 0.1,min = 0,max = 1,step = 0.1)),
              div(class='col-lg-3',numericInput(inputId = 'vertex_stop',label = "Vertex Weight End",value = 1,min = 0,max = 1,step = 0.1))
          ),
          div(class='row',
              div(class='col-lg-3', checkboxGroupButtons(inputId = "if_haircut",label = 'Select if test haircut',
                                                         choices = c("Yes"="true","No"="false"),size = 'normal',
                                                         status = 'primary',individual = T,
                                                         checkIcon = list(yes = icon("ok",lib = "glyphicon"),
                                                                          no = icon("remove",lib = "glyphicon")))
              ),
              div(class='col-lg-3', checkboxGroupButtons(inputId = "if_fluff",label = 'Select if test fluff',
                                                          choices = c("Yes"="true","False"="false"),size = 'normal',status = 'primary',individual = T,
                                                                      checkIcon = list(yes = icon("ok",lib = "glyphicon"),
                                                                                       no = icon("remove",lib = "glyphicon")))
              )
          )
  )
  removeUI(selector = "#modaltitle")
  insertUI(selector = "infolist>div.modal-dialog>div.modal-content>div.modal-header",where = 'afterBegin',ui = h4(id="modaltitle",class="modal-title",HTML("Set Parameter Test of LinkComm")))
  removeUI(selector = "#modalbody>",multiple = T,immediate = T,session = session)
  insertUI(selector = "#modalbody",where = "beforeEnd",ui = ui,multiple = T,immediate = T)
  removeUI(selector = "#modalSubmit")
  insertUI(selector = "div.modal-footer",where = 'afterBegin',ui = tags$button(id='modalSubmit',class='btn btn-primary',type="button",HTML("Run"),onclick='run_parameter_test("cluster_mcode")'))
  session$sendCustomMessage('show_community_parameter_test_modal',"")
}
run_cluster_mcode_test=function(input,output,session)
{
  start=input$vertex_start
  step=input$vertex_step
  stop=input$vertex_stop
  haircut=input$if_haircut
  fluff=input$if_fluff
  if(step==0)
  {
    sendSweetAlert(session = session,title = "Error",text = "Vertex Step can't be 0",type = 'error')
    return()
  }
  if(start>stop)
  {
    sendSweetAlert(session = session,title = "Error",text = "The  Begin can't larger than End",type = 'error')
    return()
  }
  if(is.null(haircut))
  {
    sendSweetAlert(session = session,title = "Error",text = "Choose at least one choice for haircut",type = 'error')
    return()
  }
  if(is.null(fluff))
  {
    sendSweetAlert(session = session,title = "Error",text = "Choose at least one choice for haircut",type = 'error')
    return()
  }
  summary=data.frame()
  detail=data.frame()
  progress=0
  allprogress=length(seq(from=start,to = stop,by = step))*length(haircut)*length(fluff)
  for(hc in haircut)
  {
    for(ff in fluff)
    {
      for(i in seq(from=start,to = stop,by = step))
      {
        progress=progress+1
        session$sendCustomMessage("test_parameter_status",message = list(status='run',info=paste("Running Vertex =",i," haircut =",hc," fluff =",fluff),progress=round(progress/allprogress,digits = 2)*100))
        community=cluster_mcode(graph = net_igraph,vwp = i,haircut = hc,fluff = ff,fdt = 0.8)
        membership=community$cluster
        names(membership)=community$node
        isolatenode=names(membership)[membership==0]
        membership[isolatenode]=seq(from=max(membership)+1,by = 1,length.out = length(isolatenode))
        com_mod=modularity(x = net_igraph,membership=membership)
        isolatednode=length(isolatenode)
        membership[isolatenode]=0
        com_count=length(unique(membership))

        tmp=data.frame()
        for(com in setdiff(unique(membership),0))
        {
          mg=names(membership[membership==com])
          subgraph=subgraph(graph = net_igraph,v = mg)
          node_count=length(mg)
          edge_count=gsize(subgraph)
          density=edge_count/(node_count*(node_count-1)/2)
          tmp=rbind(tmp,data.frame(haircut=paste("haircut=",hc,sep=""),fluff=paste("fluff=",ff,sep=""),para=i,nodecount=node_count,edgecount=edge_count,density=density,stringsAsFactors = F))
        }
        summary=rbind(summary,data.frame(haircut=paste("haircut=",hc,sep=""),fluff=paste("fluff=",ff,sep=""),para=i,singleNode=isolatednode,community=com_count,modularity=com_mod,density=mean(tmp$density,na.rm = T),stringsAsFactors = F))
        detail=rbind(detail,tmp)
      }
    }
  }

  basic_theme=theme(legend.position = 'bottom',
                    axis.line = element_line(linetype = "solid"),
                    panel.grid.minor = element_line(linetype = "blank"),
                    axis.title = element_text(family = "serif",size=14,color='black'),
                    axis.text = element_text(family = "serif",size=14,color='black'),
                    axis.text.x = element_text(family = "serif"),
                    axis.text.y = element_text(family = "serif"),
                    plot.title = element_text(family = "serif", hjust = 0.5,size=18,color='black'),
                    legend.text = element_text(family = "serif",size=14,colour = 'black'),
                    legend.title = element_text(family = "serif",size=14,color='black'),
                    panel.background = element_rect(fill = NA),
                    plot.background = element_rect(colour = NA),
                    legend.key = element_rect(fill = NA),
                    legend.background = element_rect(fill = NA),
                    legend.direction = "horizontal")
  summary$para=as.factor(summary$para)
  detail$para=as.factor(detail$para)
  p1=ggplot(data = summary)+
    geom_bar(mapping = aes(x = para,y = modularity,fill=para),stat='identity')+
    facet_grid(haircut~fluff,scales='free_y')+
    scale_fill_manual(values = colorRampPalette(usedcolors)(allprogress))+
    basic_theme+labs(title="Modularity",x="Hierarchical Clustering Method")+
    theme(legend.position ='none')
  p2=ggplot(data = summary)+
    geom_bar(mapping = aes(x = para,y = density,fill=para),stat='identity')+
    facet_grid(haircut~fluff,scales='free_y')+
    scale_fill_manual(values = colorRampPalette(usedcolors)(allprogress))+
    basic_theme+labs(title="Average Density",x="Hierarchical Clustering Method")+
    theme(legend.position='none')
  p3=ggplot(data = summary)+
    geom_bar(mapping = aes(x = para,y = community,fill=para),stat='identity')+
    facet_grid(haircut~fluff,scales='free_y')+
    scale_fill_manual(values = colorRampPalette(usedcolors)(allprogress))+
    basic_theme+labs(title="Community Count",x="Hierarchical Clustering Method")+
    theme(legend.position='none')
  p4=ggplot(data=detail)+
    geom_boxplot(mapping = aes(x = para,y = nodecount,fill=para))+
    facet_grid(haircut~fluff,scales='free_y')+
    scale_fill_manual(values = colorRampPalette(usedcolors)(allprogress))+
    basic_theme+labs(title="Community Node Count Distribution",x="Hierarchical Clustering Method")+
    theme(legend.position='none')
  p5=ggplot(data=detail)+
    geom_boxplot(mapping = aes(x = para,y = edgecount,fill=para))+
    facet_grid(haircut~fluff,scales='free_y')+
    scale_fill_manual(values = colorRampPalette(usedcolors)(allprogress))+
    basic_theme+labs(title="Community Edge Count Distribution",x="Hierarchical Clustering Method")+
    theme(legend.position='none')
  p6=ggplot(data=detail)+
    geom_boxplot(mapping = aes(x = para,y = density,fill=para))+
    facet_grid(haircut~fluff,scales='free_y')+
    scale_fill_manual(values = colorRampPalette(usedcolors)(allprogress))+
    basic_theme+labs(title="Community Density Distribution",x="Hierarchical Clustering Method")+
    theme(legend.position='none')

  svglite(paste(basepath,"/Plot/community_parameter_test1.svg",sep=""))
  print((p1|p2)/(p3|plot_spacer()))
  dev.off()
  svglite(paste(basepath,"/Plot/community_parameter_test2.svg",sep=""))
  print((p4|p5)/(p6|plot_spacer()))
  dev.off()

  session$sendCustomMessage("test_parameter_status",message = list(status='complete',info=paste('Finish'),progress=100))

  svglite(paste(basepath,"/Plot/community_parameter_test1.svg",sep=""))
  print(p1)
  dev.off()
  svglite(paste(basepath,"/Plot/community_parameter_test2.svg",sep=""))
  print(p2)
  dev.off()
  svglite(paste(basepath,"/Plot/community_parameter_test3.svg",sep=""))
  print(p3)
  dev.off()
  svglite(paste(basepath,"/Plot/community_parameter_test4.svg",sep=""))
  print(p4)
  dev.off()
  svglite(paste(basepath,"/Plot/community_parameter_test5.svg",sep=""))
  print(p5)
  dev.off()
  svglite(paste(basepath,"/Plot/community_parameter_test6.svg",sep=""))
  print(p6)
  dev.off()

  session$sendCustomMessage("test_parameter_status",message = list(status='complete',info=paste('Finish'),progress=100))
  removeUI(selector = "#parameter_test_1",multiple = T,immediate = T,session = session)
  removeUI(selector = "#parameter_test_2",multiple = T,immediate = T,session = session)
  removeUI(selector = "#parameter_test_3",multiple = T,immediate = T,session = session)
  removeUI(selector = "#parameter_test_4",multiple = T,immediate = T,session = session)
  removeUI(selector = "#parameter_test_5",multiple = T,immediate = T,session = session)
  removeUI(selector = "#parameter_test_6",multiple = T,immediate = T,session = session)
  insertUI(selector = "#modalbody",where = 'beforeEnd',ui = plotOutput(outputId = "parameter_test_1",width = "100%",height = "100%"))
  insertUI(selector = "#modalbody",where = 'beforeEnd',ui = plotOutput(outputId = "parameter_test_2",width = "100%",height = "100%"))
  insertUI(selector = "#modalbody",where = 'beforeEnd',ui = plotOutput(outputId = "parameter_test_3",width = "100%",height = "100%"))
  insertUI(selector = "#modalbody",where = 'beforeEnd',ui = plotOutput(outputId = "parameter_test_4",width = "100%",height = "100%"))
  insertUI(selector = "#modalbody",where = 'beforeEnd',ui = plotOutput(outputId = "parameter_test_5",width = "100%",height = "100%"))
  insertUI(selector = "#modalbody",where = 'beforeEnd',ui = plotOutput(outputId = "parameter_test_6",width = "100%",height = "100%"))
  output[['parameter_test_1']]=renderImage({list(src=paste(basepath,"/Plot/community_parameter_test1.svg",sep=""),width="100%",height="100%")},deleteFile = F)
  output[['parameter_test_2']]=renderImage({list(src=paste(basepath,"/Plot/community_parameter_test2.svg",sep=""),width="100%",height="100%")},deleteFile = F)
  output[['parameter_test_3']]=renderImage({list(src=paste(basepath,"/Plot/community_parameter_test3.svg",sep=""),width="100%",height="100%")},deleteFile = F)
  output[['parameter_test_4']]=renderImage({list(src=paste(basepath,"/Plot/community_parameter_test4.svg",sep=""),width="100%",height="100%")},deleteFile = F)
  output[['parameter_test_5']]=renderImage({list(src=paste(basepath,"/Plot/community_parameter_test5.svg",sep=""),width="100%",height="100%")},deleteFile = F)
  output[['parameter_test_6']]=renderImage({list(src=paste(basepath,"/Plot/community_parameter_test6.svg",sep=""),width="100%",height="100%")},deleteFile = F)

}
create_property_box=function(type,id)
{
  id=sub(pattern = " ",replacement = "_",x = id)
  ui=div(class="col-lg-4",id=paste(type,"_",id,sep=""),
      div(class="box box-success",
          div(class="box-header with-border",
              h3(class="box-title",HTML(paste(toupper(type)," ",sub(pattern = "_",replacement = " ",x = toupper(id)),sep=""))),
              div(class="box-tools pull-right",
                  tags$button(class="btn btn-box-tool",type="button","data-widget"="collapse",
                              tags$i(class="fa fa-minus")
                  )
              )
          ),
          div(class="box-body",style="display:block;",
              imageOutput(outputId = paste(type,"_",id,"_plot",sep=""),width = "100%",height = "100%"),
              #tableOutput(outputId = paste(type,"_",id,"_table",sep=""))
              tags$button(class="btn bg-maroon btn-block btn-flat",type='button',HTML("Details"),
                          onclick=paste(ifelse(type=='node','node','edge'),"Details(this)",sep="")
                         )
          )
      )
  )
  return(ui)
}
cluster_mcl=function(graph,expansion=2,inflation=2,allow1=F,max.iter=100)
{
  community=mcl(as.matrix(as_adjacency_matrix(graph,type='both')),addLoops = T,expansion = expansion,inflation = inflation,allow1 = allow1,max.iter = max.iter)
  result=community$Cluster
  names(result)=rownames(as_adjacency_matrix(graph,type='both'))
  return(result)
}
cluster_linkcomm=function(edgeinfo,hcmethod)
{
  community=getLinkCommunities(network = edgeinfo[,c("N1","N2")],hcmethod = hcmethod,directed = F,plot = F)
  result=community$nodeclusters
  result[,1]=as.character(result[,1])
  result[,2]=as.character(result[,2])
  colnames(result)=c('node','cluster')
  return(result)
}
cluster_mcode=function(graph,vwp,haircut,fluff,fdt)
{
  community=cluster(graph = graph,method = 'MCODE',vwp = vwp,haircut = haircut,fluff = fluff,fdt = fdt,plot = F)
  result=as.data.frame(community,stringsAsFactors=F)
  result=data.frame(node=rownames(result),cluster=result$community,stringsAsFactors = F)
  return(result)
}
cluster_cograph=function(netpath,outpath)
{
  # .jinit()
  # .jaddClassPath(path = "Program/Cograph.jar")
  # cograph=.jnew(class = 'com/xidian/Cograph/CographMining',normalizePath(netpath),normalizePath(outpath))
  # .jcall(obj = cograph,returnSig = 'V',method = 'run')
  if(Sys.info()['sysname']=="Windows")
  {
    cmd=paste("cd www/Program & java -cp .;Cograph.jar RunCograph",normalizePath(netpath),normalizePath(outpath))
    msg=shell(cmd = cmd,wait = T,intern = T)
  }
  else
  {
    cmd=paste("cd www/Program;java -cp .:Cograph.jar RunCograph",normalizePath(netpath),normalizePath(outpath))
    msg=system(command = cmd,wait = T,intern = T)
  }
  result=readLines(con = paste(normalizePath(outpath),"Cograph community.txt",sep=""))
  singleNode=c()
  id=1
  for(line in result)
  {
    genes=unlist(strsplit(x = line,split = "\t"))
    if(length(genes)==1)
    {
      after_slice_geneinfo[genes,'module']<<-"Module0"
      singleNode=c(singleNode,genes)
    }
    else
    {
      after_slice_geneinfo[genes,'module']<<-paste("Module",id,sep="")
      id=id+1
      tmp=list(genes)
      names(tmp)=paste("Module",id,sep="")
      modules<<-c(modules,tmp)
    }
  }
  if(length(singleNode)>0)
  {
    tmp=list(singleNode)
    names(tmp)="Module0"
    modules<<-c(tmp,modules)
  }
}
create_module_info=function()
{
  moduleinfo<<-data.frame()
  for(community in names(modules))
  {
    module_genes=modules[[community]]
    subgraph=subgraph(graph = net_igraph,v = module_genes)
    node_count=length(module_genes)
    edge_count=gsize(subgraph)
    density=edge_count/(node_count*(node_count-1)/2)
    node_type_count=data.frame(count=rep(0,times=length(unique(after_slice_geneinfo$.group))),row.names = unique(after_slice_geneinfo$.group))
    nodetype=table(after_slice_geneinfo[module_genes,'.group'])
    node_type_count[names(nodetype),'count']=nodetype
    node_type_count=t(node_type_count)
    colnames(node_type_count)=paste(colnames(node_type_count),".count",sep="")
    rownames(node_type_count)=NULL

    tmpmicro=as.matrix(target[module_genes,rownames(after_slice_micro.exp)])
    subnet=as.matrix(as_adjacency_matrix(subgraph))
    subnet=subnet[module_genes,module_genes]
    path=tmpmicro%*%t(tmpmicro)*subnet
    ave.micro=sum(path)/sum(subnet)

    scores=list()
    for(con in unique(thresh$type))
    {
      module_edges=edgeinfo[edgeinfo$N1%in%module_genes&edgeinfo$N2%in%module_genes,]
      scores=c(scores,mean(module_edges[,con]))
    }
    names(scores)=paste0("Average.",unique(thresh$type))

    nodeDetails=paste("<a onclick=communityDetail('",community,"')>Details</a>",sep="")
    edgeDetails=paste("<a onclick=communityEdgeDetail('",community,"')>Details</a>",sep="")
    display=paste("<a href='#",paste("module_",community,sep=""),"' onclick=displayCommunity('",community,"')>Display</a>",sep="")
    microRNA=paste("<a onclick=microRNA_analysis('",community,"')>Access</a>",sep="")
    moduleinfo<<-rbind(moduleinfo,data.frame("ModuleID"=community,"Node Count"=node_count,"Edge Count"=edge_count,node_type_count,
                                   Density=density,Average.MicroRNA=ave.micro,scores,
                                   Nodes=nodeDetails,Edges=edgeDetails,
                                   Visualization=display,
                                   MicroRNA=microRNA,stringsAsFactors = F))
  }
}
create_module_visualization=function(id)
{
  ui=div(class="col-lg-6",id=paste("module_",id,sep=""),
         div(class="box box-danger",
             div(class="box-header",
                 h4(id),
                 tags$button(id=paste(id,'_setting',sep=""),class="btn btn-default action-button btn-circle-sm dropdown-toggle shiny-bound-input",onclick="module_setting(this)",
                             tags$span(tags$i(class="fa fa-gear"))
                            )
             ),
             div(class="box-body",visNetworkOutput(outputId = paste(id,"_plot",sep=""),width = "100%",height = "500px"))
         )
     )
  return(ui)
}

create_modal_setting=function(id)
{
  valid_label_column=c("All")
  candidate_column=colnames(after_slice_geneinfo)
  label_column=candidate_column
  names(label_column)=label_column
  shapes=list("Label In"=c("ellipse","circle",'database',"box","text"),
              "Label Out"=c("circularImage","diamond","dot","star","triangle","triangleDown","square")
  )
  names(shapes[[1]])=shapes[[1]]
  names(shapes[[2]])=shapes[[2]]
  colorcandidate=list(
    conditionalPanel(condition="input.module_color=='All'",
                     div(class="row",
                         div(class="col-lg-2",colourInput(inputId = "All_color",label = "All",value = ifelse(module.configure[[id]]$color.attr=='All',module.configure[[id]]$color,'red')))
                     )
                    )
  )
  shapecandidate=list(
    conditionalPanel(condition="input.module_shape=='All'",
                     div(class="row",
                         div(class="col-lg-2",
                             selectInput(inputId = "All_shape",
                                         label = "All",choices = shapes,
                                         selected = ifelse(module.configure[[id]]$shape.attr=='All',module.configure[[id]]$shape,"circle")
                                         )
                         )
                     )
    )
 )

  for(column in candidate_column)
  {
    items=as.character(unique(after_slice_geneinfo[,column]))
    if(length(items)>typeLimit)
    {
      next
    }
    valid_label_column=c(valid_label_column,column)
    coloritems=list()
    shapeitems=list()
    if(column==module.configure[[id]]$color.attr)
    {
      for(item in items)
      {
        coloritems=c(coloritems,list(div(class="col-lg-2",
                                         colourInput(inputId = paste(item,"_color",sep=""),
                                                                      label = item,
                                                                      value = module.configure[[id]]$color[[item]]))))
      }
    }
    else
    {
      for(item in items)
      {
        coloritems=c(coloritems,list(div(class="col-lg-2",colourInput(inputId = paste(item,"_color",sep=""),label = item,value = "red"))))
      }
    }

    if(column==module.configure[[id]]$shape.attr)
    {
      for(item in items)
      {
        shapeitems=c(shapeitems,list(div(class="col-lg-2",
                                         selectInput(inputId = paste(item,"_shape",sep=""),label = item,
                                                     choices = shapes,
                                                     selected = module.configure[[id]]$shape[[item]]))))
      }

    }
    else
    {
      for(item in items)
      {
        shapeitems=c(shapeitems,list(div(class="col-lg-2",selectInput(inputId = paste(item,"_shape",sep=""),label = item,choices = shapes,selected = "circle"))))
      }
    }


    colorui=conditionalPanel(condition = paste("input.module_color=='",column,"'",sep=""),div(class="row",coloritems))
    shapeui=conditionalPanel(condition = paste("input.module_shape=='",column,"'",sep=""),div(class="row",shapeitems))

    colorcandidate=c(colorcandidate,list(colorui))
    shapecandidate=c(shapecandidate,list(shapeui))
  }
  names(valid_label_column)=valid_label_column
  ui=div(div(class="row",
             div(class="col-lg-4",
                 selectInput(inputId = "module_layout",label = "Layout",
                             choices =  c("Star"="layout_as_star","Tree"="layout_as_tree","Circle"="layout_in_circle","Nicely"="layout_nicely","Grid"="layout_on_grid","Sphere"="layout_on_sphere","Random"="layout_randomly","D.H. Algorithm"="layout_with_dh","Force Directed"="layout_with_fr","GEM"="layout_with_gem","Graphopt"="layout_with_graphopt","Kamada-Kawai"="layout_with_kk","Large Graph Layout"="layout_with_lgl","Multidimensional Scaling"="layout_with_mds","Sugiyama"="layout_with_sugiyama"),
                             selected = module.configure[[id]]$layout
                 )
                ),
             div(class="col-lg-4",
                 selectInput(inputId = "module_label",label = "Labels",choices = label_column,selected = module.configure[[id]]$label)
                )
        ),
        div(class="row",
            div(class="col-lg-4",
                selectInput(inputId = "module_color",label = "Color Map",choices = valid_label_column,selected = module.configure[[id]]$color.attr)
            ),
            div(class="col-lg-12",style="background-color:#F8F9F9",
                colorcandidate
            )
        ),
        div(class="row",
           div(class="col-lg-4",
               selectInput(inputId = "module_shape",label = "Shape Map",choices = valid_label_column,selected=module.configure[[id]]$shape.attr)
           ),
           div(class="col-lg-12",style="background-color:#F8F9F9",
               shapecandidate
           )
        )
  )
  return(ui)
}

create_progress=function(msg,id=paste("#",as.numeric(Sys.time()),"_progress",sep=""))
{
  ui=div(class='progress active',id=id,
         div(class='progress-bar progress-bar-primary progress-bar-striped',"aria-valuenow"="100","aria-valuemin"="0","aria-valuemax"="100",style="width:100%",
             tags$span(msg)
         )
  )
}

create_alert_box=function(header,msg,class){
  ui=div(class=paste("alert alert-info alert-dismissible",class),
         h4(tags$i(class="icon fa fa-info"),HTML(header)),
         HTML(msg)
    )
  return(ui)
}

km.analysis=function(data,time,status,factor)
{
  surv_obj=Surv(data[,time],data[,status])
  fit=do.call(what = survfit,args = list(formula=as.formula(paste("surv_obj~",factor,sep="")), data = data))
  p.val <-surv_pvalue(fit)$pval.txt
  group=unique(data$group)
  group.color=c(usedcolors[5],usedcolors[3])
  names(group.color)=group

  p=ggsurvplot(fit = fit,pval = T)
  pp=ggplot_build(p$plot)

  coor_x=get('limits',envir = pp$layout$coord)$x

  text=data.frame(text=p.val,x=(coor_x[2]-coor_x[1])/8,y=0.25,stringsAsFactors = F)
  p$plot$data$strata=as.character(p$plot$data$group)
  p$plot=ggplot(data = p$plot$data)+geom_path(mapping = aes(x=time,y =surv,colour=strata),size=1.1)+
    geom_point(mapping = aes(x=time,y = surv,fill=strata,colour=strata),size=5,shape='+')+
    xlab('Time')+ylab('Survival probability')+ylim(0,1)+xlim(coor_x)+
    scale_color_manual(values=group.color)+
    geom_text(mapping = aes(x = x,y = y,label=text),data = text,size=5,inherit.aes = F)+
    theme(axis.title = element_text(family = "serif"),axis.text = element_text(family = "serif",colour = "black", vjust = 0.25),
          axis.text.x = element_text(family = "serif",colour = "black"),
          axis.text.y = element_text(family = "serif",colour = "black"),
          plot.title = element_text(family = "serif", hjust = 0.5,size=14),
          legend.text = element_text(family = "serif"),
          legend.title = element_text(family = "serif"),
          legend.key = element_rect(fill = NA),
          legend.background = element_rect(fill = NA),
          legend.direction = "horizontal",
          legend.position = 'bottom',
          panel.background = element_rect(fill = NA))
  return(p)
}

cox.analysis=function(session,clinical,exp,time,status,ifgroup,gene,external_continous,
                      external_categorical,strata_factor,single_grouped=F)
{
  if(ifgroup)
  {
    patient.cluster=kmeans(t(exp[gene,]),centers = 2)$cluster
    clinical$group=""

    for(cl in unique(patient.cluster))
    {
      clinical[names(patient.cluster)[which(patient.cluster==cl)],'group']=paste("Group",cl,sep="")
    }

    clinical=clinical[which(clinical$group!=""),]
    clinical$group=as.factor(clinical$group)
  }

  surv_obj=Surv(clinical[,time],clinical[,status])
  if(!is.null(external_categorical))
  {
    for(f in external_categorical)
    {
      clinical[,f]=as.factor(clinical[,f])
    }
  }
  if(length(intersect(external_continous,external_categorical))>0)
  {
    factor=intersect(external_continous,external_categorical)
    sendSweetAlert(session = session,title = "Error...",text = paste("Factors(",paste(factor,collapse = ", "),") conflict between stratified and categorical.",sep=""),type = "error")
    return()
  }
  if(length(intersect(strata_factor,external_categorical))>0)
  {
    factor=intersect(strata_factor,external_categorical)
    sendSweetAlert(session = session,title = "Warning...",text = paste("Factors(",paste(factor,collapse = ", "),") conflict between stratified and categorical, and will be regard as stratified factors",sep=""),type = "warning")
    external_categorical=setdiff(external_categorical,strata_factor)
  }
  if(length(intersect(strata_factor,external_continous))>0)
  {
    factor=intersect(strata_factor,external_continous)
    sendSweetAlert(session = session,title = "Warning...",text = paste("Factors(",paste(factor,collapse = ", "),") conflict between stratified and continous, and will be regard as stratified factors",sep=""),type = "warning")
    external_continous=setdiff(external_continous,strata_factor)
  }

  if(is.null(strata_factor))
  {
    strata_formula=NULL
  }
  else
  {
    strata_formula=paste(paste("strata(",strata_factor,')',sep=""),collapse = "+")
  }

  if(is.null(c(external_continous,external_categorical)))
  {
    factor_formula=NULL
  }
  else
  {
    factor_formula=paste(c(external_continous,external_categorical),collapse = "+")
  }
  if(ifgroup)
  {
    factor_formula=paste(factor_formula,"group",sep="+")
  }
  else if(!single_grouped)
  {
    factor_formula=paste(factor_formula,paste(gene,collapse = "+"),sep = "+")
    clinical=cbind(clinical,t(exp[gene,rownames(clinical)]))
  }
  if(single_grouped)
  {
    factor_formula=paste(factor_formula,"group",sep="+")
  }
  formula=paste("surv_obj~",paste(strata_formula,factor_formula,sep="+"),sep="")
  formula=gsub(pattern = "\\+\\+",replacement = "\\+",x=formula)
  formula=gsub(pattern = "~\\+",replacement = "~",x = formula)
  formula=gsub(pattern = "\\+$",replacement = "",x = formula)
  fit=do.call(coxph,list(formula = as.formula(formula),data = clinical))
  return(fit)
  # browser()
  # p=ggadjustedcurves(fit = fit)
  # return(p)
}

create_survival_result_box=function(session,label,id,model)
{
  panel1=div(class="panel box box-success",
             div(class="box-header with-border",
                 h4(class="box-title",
                    tags$a(class="","data-toggle"="collapse",href=paste("#",id,"_",model,"_","survival_curve_panel",sep=""),"aria-expanded"="true","data-parent"=paste("#",paste(id,model,sep="_"),'_group',sep=""),
                           HTML("Survival Curve")
                    )
                )
             ),
             div(class="panel-collapse collapse in","aria-expanded"="true",id=paste(id,"_",model,"_","survival_curve_panel",sep=""),
                 div(class="box-body",
                     imageOutput(outputId = paste(id,model,"survival_curve",sep="_"),width = "100%",height = "100%")
                 )
             )
  )
  panel2=div(class="panel box box-info",
             div(class="box-header with-border",
                 h4(class="box-title",
                    tags$a(class="collapsed","data-toggle"="collapse",href=paste("#",id,"_",model,"_","survival_cluster_panel",sep=""),"aria-expanded"="false","data-parent"=paste("#",paste(id,model,sep="_"),'_group',sep=""),
                           HTML("Patient Cluster")
                    )
                 )
             ),
             div(class="panel-collapse collapse","aria-expanded"="false",id=paste(id,"_",model,"_","survival_cluster_panel",sep=""),
                 div(class="box-body",
                     imageOutput(outputId = paste(id,model,"survival_cluster",sep="_"),width = "100%",height = "100%")
                 )
             )
  )
  panel3=div(class="panel box box-warning",
             div(class="box-header with-border",
                 h4(class="box-title",
                    tags$a(class="collapsed","data-toggle"="collapse",href=paste("#",id,"_",model,"_","survival_table_panel",sep=""),"aria-expanded"="false","data-parent"=paste("#",paste(id,model,sep="_"),'_group',sep=""),
                           HTML("Survival Table")
                    )
                 )
             ),
             div(class="panel-collapse collapse","aria-expanded"="false",id=paste(id,"_",model,"_","survival_table_panel",sep=""),
                 div(class="box-body",
                     rHandsontableOutput(outputId = paste(id,model,"survival_table",sep="_"),width = "100%",height = "100%")
                 )
             )
  )
  box=div(class="col-lg-6 col-md-12",
          div(class="box box-primary",id=paste(id,model,sep="_"),
              div(class="box-header with-border",
                  h4(label,downloadButton(outputId =paste(id,'_survival_export',sep=""),label = "Export",onclick=paste('export_survival_plot("',id,'","km_analysis")',sep="")))
              ),
              div(class="box-body",
                  div(class="box-group",id=paste(id,model,"group",sep="_"),
                      panel1,
                      panel2,
                      panel3
                  )
              )

          )
      )
  insertUI(selector = "#survival_result_panel",where = "beforeEnd",ui = box,immediate = T,session = session)

}

create_cox_survival_result_box=function(session,label,id,model)
{
  panel1=div(class="panel box box-success",
             div(class="box-header with-border",
                 h4(class="box-title",
                    tags$a(class="","data-toggle"="collapse",href=paste("#",id,"_",model,"_","survival_coefficient_panel",sep=""),"aria-expanded"="true","data-parent"=paste("#",paste(id,model,sep="_"),'_group',sep=""),
                           HTML("Coefficient Estimates")
                    )
                 )
             ),
             div(class="panel-collapse collapse in","aria-expanded"="true",id=paste(id,"_",model,"_","survival_coefficient_panel",sep=""),
                 div(class="box-body",
                     tableOutput(outputId = paste(id,model,"survival_coefficient",sep="_"))
                 )
             )
  )
  panel2=div(class="panel box box-info",
             div(class="box-header with-border",
                 h4(class="box-title",
                    tags$a(class="collapsed","data-toggle"="collapse",href=paste("#",id,"_",model,"_","survival_hazard_panel",sep=""),"aria-expanded"="false","data-parent"=paste("#",paste(id,model,sep="_"),'_group',sep=""),
                           HTML("Hazard Ratio")
                    )
                 )
             ),
             div(class="panel-collapse collapse","aria-expanded"="false",id=paste(id,"_",model,"_","survival_hazard_panel",sep=""),
                 div(class="box-body",
                     tableOutput(outputId = paste(id,model,"survival_hazard",sep="_"))
                 )
             )
  )
  # panel3=div(class="panel box box-warning",
  #            div(class="box-header with-border",
  #                h4(class="box-title",
  #                   tags$a(class="collapsed","data-toggle"="collapse",href=paste("#",id,"_",model,"_","survival_table_panel",sep=""),"aria-expanded"="false","data-parent"=paste("#",paste(id,model,sep="_"),'_group',sep=""),
  #                          HTML("Survival Table")
  #                   )
  #                )
  #            ),
  #            div(class="panel-collapse collapse","aria-expanded"="false",id=paste(id,"_",model,"_","survival_table_panel",sep=""),
  #                div(class="box-body",
  #                    rHandsontableOutput(outputId = paste(id,model,"survival_table",sep="_"),width = "100%",height = "100%")
  #                )
  #            )
  # )
  box=div(class="col-lg-6 col-md-12",
          div(class="box box-primary",id=paste(id,model,sep="_"),
              div(class="box-header with-border",
                  h4(label)
              ),
              div(class="box-body",
                  div(class="box-group",id=paste(id,model,"group",sep="_"),
                      panel1,
                      panel2
                  )
              )

          )
  )
  insertUI(selector = "#survival_result_panel",where = "beforeEnd",ui = box,immediate = T,session = session)

}

Heatmaps=function(exp,clinical,imagepath)
{
  if(sum(exp<0)==0)
  {
    exp=t(scale(log(t(exp)+1)))
  }
  clinical=clinical[order(clinical$group),]
  exp=exp[,rownames(clinical)]
  #remove all NA row
  index=which(rowSums(is.na(exp))==dim(exp)[2])
  if(length(index)>0)
  {
    exp=exp[(-1*index),]
  }

  exp=t(exp)

  group=unique(clinical$group)
  group.color=c(usedcolors[5],usedcolors[3])
  names(group.color)=group
  ann_colors = list(
    Group=group.color
  )
  annotation_legend_param=list(lenged_direction='horizontal',nrow=2)
  sampleAnno=rowAnnotation(df=data.frame(Group=clinical$group,stringsAsFactors = F),
                           col=ann_colors,show_legend=T,
                           annotation_name_gp=gpar(fontsize=12,fontfamily='serif',fontface='bold'),
                           annotation_legend_param = annotation_legend_param)
  #colnames(exp)=geneinfo[colnames(exp),'external_gene_name']
  png(imagepath,family = "serif",res = 100,width = 1000,height = 1000)
  p=Heatmap(matrix = exp,
             #top_annotation = colA,#left_annotation=rowA,
             left_annotation = sampleAnno,#top_annotation = geneAnno,
             #column_title = 'COR',
             column_title_gp = gpar(fontsize=14,fontfamily='serif',fontface='bold'),
             cluster_rows = F,cluster_columns = T,
             show_column_dend = F,
             show_column_names=T,show_row_names = F,
             row_names_gp=gpar(fontsize=12,fontfamily='serif'),column_names_gp=gpar(fontsize=8,fontfamily='serif'),
             col = colorRamp2(breaks = c(min(exp,na.rm = T),median(exp,na.rm=T),max(exp,na.rm = T)), c(usedcolors[3],'#000000',usedcolors[5])),
             heatmap_legend_param=list(legend_direction='horizontal',nrow=1,title='',legend_width=unit(50, "mm")),na_col="#ffffff")
  draw(p,heatmap_legend_side='bottom',annotation_legend_side='bottom',ht_gap=unit(0.05,'cm'), merge_legend = TRUE)
  dev.off()
  #p1=as.ggplot(as.grob(~draw(p1)))
  #return(p1)
}

SingleExpress=function(exp,thresh,clinical)
{
  group=unique(clinical$group)
  color=c(usedcolors[5],usedcolors[3])
  names(color)=c("High Expressed","Low Expressed")
  d=as.numeric(exp)
  data=density(d,na.rm = T)
  data=data.frame(x=data$x,y=data$y,group="High Expressed",stringsAsFactors = F)
  data[which(data$x<thresh),'group']="Low Expressed"
  text=data.frame(label=paste("Thresh=",round(thresh,digits = 2),sep=""),x=max(data$x)*0.8,y=max(data$y),stringsAsFactors = F)

  p=ggplot(data = data)+geom_line(mapping = aes(x = x,y = y),size=1.5)+
    geom_area(mapping = aes(x = x,y=y,fill=group),alpha=0.8)+
    geom_vline(xintercept = thresh,size=1.2,colour=usedcolors[5],linetype="dashed")+
    scale_fill_manual(values = color)+
    geom_text(mapping = aes(x = x,y = y,label=label),data=text,size=6,family='serif')+
    theme(legend.position = 'top',panel.background = element_rect(fill = NA))
  return(p)
}
