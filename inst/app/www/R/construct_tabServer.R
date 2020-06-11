condition=data.frame(abbr=c('PCC','LA','MS','MI','CMI'),
                     used=F,
                     description=c('Pearson Correlation Coefficient','Liquid Association','MicroRNA Significance','Mutual Information',"Conditional Mutual Information"),
                     core=0,
                     task="",
                     others="",
                     stringsAsFactors = F
)
rownames(condition)=condition$abbr
validcore=detectCores(logical = F)
network=""
net_igraph=""
thresh=data.frame()
edgeinfo=data.frame()

readData=function(type,tasks)
{
  if(type=="PCC")
  {
    data=readRDS(paste(basepath,'/all.cor.RData',sep=""))
    if('all' %in% tasks)
    {
      data=list(data)
      names(data)='all'
      datalist=list(data)
      names(datalist)='PCC'
    }
    else
    {
      datalist=list()
      for(task in tasks)
      {
        groups=unlist(strsplit(x = task,split = "---"))
        group1=rownames(after_slice_geneinfo)[which(after_slice_geneinfo$.group==groups[1])]
        group2=rownames(after_slice_geneinfo)[which(after_slice_geneinfo$.group==groups[2])]
        
        tmp=list(data[group1,group2])
        names(tmp)=task
        datalist=c(datalist,tmp)
      }
      datalist=list(datalist)
      names(datalist)="PCC"
    }
  }
  else
  {
    data=readRDS(paste(basepath,'/',type,'.RData',sep=""))
    datalist=list(data)
    names(datalist)=type
  }
  return(datalist)
}

filter_box=function(type,tasks)
{
  title=h4(type)
  icon=tags$button(class="btn btn-box-tool",type="button","data-widget"="collapse",
                   tags$i(class="fa fa-minus")
  )  
  
  tool=div(class="box-tools pull-right",icon)
  header=div(class="box-header with-border",title,tool)
  plot_panel=list()
  for(task in tasks)
  {
    panel=div(class="col-lg-4",id=paste("density_plot",type,task,sep="_"),type=type,task=task,style="border:2px solid #f4f4f4;")
    plot_panel=c(plot_panel,list(panel))
  }
  body=div(class="box-body",plot_panel)
  foot=div(class="box-footer",
           tags$button(class="btn btn-default action-button pull-right",HTML('Cancel'),onclick="cancel_thresh(this)"),
           tags$button(class="btn btn-success action-button pull-right",HTML('Confirm'),onclick="comfirm_thresh(this)")
          )
  box=div(class="box box-primary",id=paste("density_plot_",type,sep=""),header,body,foot)
  all=div(class="col-lg-12",box)
  return(all)
}

condition_density_plot=function(basepath,data,type,task,value,direction="<")
{
  #data
  #data=condition.values[[type]][[task]]
  if(all(rownames(data)==colnames(data)))
  {
    data=as.vector(data[upper.tri(data)])
  }
  else
  {
    data=as.vector(data)
  }
  #operation
  direction=get(direction)
  
  valid=which(direction(data,value))
  text1=paste("Thresh:",value)
  text2=paste("Remain: ",round(length(valid)/length(data)*100,digits = 2),"%",sep="")
  if(length(data)>1)
  {
    density=density(x = data,from = min(data,na.rm = T),to = max(data,na.rm = T),na.rm = T)
  }
  else
  {
    density=data.frame(x=data,y=1)
  }
  density=data.frame(x=density$x,y=density$y)
  density$area="false"
  density$area[which(direction(density$x,value))]='true'
  text=data.frame(label=c(text1,text2),x=max(density$x)*0.8,y=c(max(density$y),max(density$y)*0.93),stringsAsFactors = F)
  
  
  figurepath=paste(basepath,'/Plot/density_plot_',type,"_",task,".svg",sep="")
  print(figurepath)
  svglite(figurepath)
  p=ggplot(data = density)+geom_line(mapping = aes(x = x,y = y),size=1.5)+
    geom_area(mapping = aes(x = x,y=y,fill=area),alpha=0.8)+
    geom_vline(xintercept = value,size=1.2,colour=usedcolors[5],linetype="dashed")+
    scale_fill_manual(values = c("true"=usedcolors[6],"false"="#FFFFFF"))+
    labs(title = paste("Condition:",type),subtitle = paste("Task:",sub(pattern = "---",replacement = " vs ",x = task)))+xlab(type)+ylab("Density")+
    geom_text(mapping = aes(x = x,y = y,label=label),data=text,size=6,family='serif')+
    theme(axis.title = element_text(family = "serif"),axis.text = element_text(family = "serif",colour = "black", vjust = 0.25), 
          axis.text.x = element_text(family = "serif",colour = "black"), 
          axis.text.y = element_text(family = "serif",colour = "black"), 
          plot.title = element_text(family = "serif", hjust = 0.5,size=14),
          panel.background = element_rect(fill = NA),legend.position = 'none',
          plot.subtitle = element_text(family = "serif",size = 12, colour = "black", hjust = 0.5,vjust = 1))
  print(p)
  dev.off()
}
draw_density=function(basepath,output,session,type,tasks)
{
  # Read data
  for(task in tasks)
  {
    removeUI(selector = paste("#density_plot_",type,"_",task,">",sep=""),immediate = T,multiple = T)
    insertUI(selector = paste("#density_plot",type,task,sep="_"),where = 'beforeEnd',
             ui = create_progress(msg="Creating Plot...",id=paste("density_plot",type,task,"progress",sep="_")),immediate = T,session = session)
  }
  datalist=readData(type,tasks)

  for(task in tasks)
  {
    condition_density_plot(basepath = basepath,data=datalist[[type]][[task]],type = type,task = task,value=0)
    #removeUI(selector = paste("#density_plot",type,task,"image",sep="_"),immediate = T)
    #removeUI(selector = paste(paste("#density_plot",type,task,sep="_"),"div.row"),immediate = T)
    insertUI(selector = paste("#density_plot",type,task,sep="_"),where = "beforeEnd",
             ui = filter_bar(type,task),immediate = T)
    insertUI(selector = paste("#density_plot",type,task,sep="_"),
             where = 'beforeEnd',
             ui = imageOutput(outputId = paste("density_plot",type,task,"image",sep="_"),width = "100%",height = "100%"),
             immediate = T,session = session
    )
    # Map(function(task){
    #   figurepath=paste(basepath,'/Plot/density_plot_',type,"_",task,".svg",sep="")
    #   output[[paste("density_plot",type,task,"image",sep="_")]]<- renderImage({
    #     list(src=figurepath,width="100%",height="100%")
    #   },deleteFile = F)
    # },tasks)
    for(task in tasks)
    {
      local({
        tmptask=task
        figurepath=paste(basepath,'/Plot/density_plot_',type,"_",task,".svg",sep="")
        output[[paste("density_plot",type,tmptask,"image",sep="_")]]<- renderImage({
          list(src=figurepath,width="100%",height="100%")
        },deleteFile = F)
        session$sendCustomMessage('distribution_plot',list(status='finish',value="",id=paste("density_plot",type,tmptask,"progress",sep="_")))
      })
    }
  }
}
filter_bar=function(type,task)
{
  direction=selectInput(inputId = paste("direction",type,task,sep="_"),label = "Direction",choices = list("<"="<",">"=">","<="="<=",">="=">=","=="="=="),multiple = F)
  thresh=div(class="input-group",id=paste("thresh",type,task,sep="_"),
             div(class="input-group-btn",
                 tags$button(class="btn btn-default",type="button",HTML("<i class='fa fa-minus'></i>"),onclick="step_change(this)")#paste("thresh_change('",type,"','",task,"')",sep=""))
             ),
             tags$input(class="form-control",type="text",value=0,style="text-align:center",onchange="thresh_change(this)"),
             div(class="input-group-btn",
                 tags$button(class="btn btn-default",type="button",HTML("<i class='fa fa-plus'></i>"),onclick="step_change(this)")#paste("thresh_change('",type,"','",task,"')",sep=""))
             )
  )
  step=tags$input(class="form-control",type="text",value=0.01,style="text-align:center")
  result=div(class="row",
             div(class="col-lg-3",direction),
             div(class="col-lg-3",tags$label(class="control-label",HTML("Step")),step),
             div(class="col-lg-6",tags$label(class="control-label",HTML("Thresh")),thresh)
  )
  return(result)
}

# network_construnction=function(after_slice_geneinfo)
# {
#   gc()
#   print(thresh)
#   allgene=rownames(after_slice_geneinfo)[which(!is.na(after_slice_geneinfo$.group))]
#   network<<-matrix(data = NA,nrow = length(allgene),ncol = length(allgene))
#   rownames(network)<<-allgene
#   colnames(network)<<-allgene
# 
#   tasks=unique(thresh$task)
#   if(length(which(tasks=="all"))>0)
#   {
#     network[upper.tri(network)]<<-0
#   }
#   else
#   {
#     for(t in tasks)
#     {
#       groups=unlist(strsplit(x = t,split = "---"))
#       group1=rownames(after_slice_geneinfo)[which(after_slice_geneinfo$.group==groups[1])]
#       group2=rownames(after_slice_geneinfo)[which(after_slice_geneinfo$.group==groups[2])]
#       if(all(group1==group2))
#       {
#         network[group1,group2][upper.tri(network[group1,group2])]<<-0
#       }
#       else
#       {
#         network[group1,group2]<<-0
#       }
#     }
#   }
#   for(type in unique(thresh$type))
#   {
#     condition.values=readData(type,unlist(strsplit(condition[type,'task'],split = ";")))
#     type.thresh=thresh[which(thresh$type==type),]
#     network<<-network+1
#     for(i in seq(1,dim(type.thresh)[1]))
#     {
#       task=type.thresh$task[i]
#       direction=get(type.thresh$direction[i])
#       value=type.thresh$thresh[i]
#       if(task=='all')
#       {
#         tmp=!direction(condition.values[[type]][[task]],value)
#         tmp[is.na(tmp)]=T
#         network<<-network-tmp
#       }
#       else
#       {
#         groups=unlist(strsplit(x = task,split = "---"))
#         group1=rownames(after_slice_geneinfo)[which(after_slice_geneinfo$.group==groups[1])]
#         group2=rownames(after_slice_geneinfo)[which(after_slice_geneinfo$.group==groups[2])]
#         #network[group1,group2]<<-network[group1,group2]+1
#         tmp=!direction(condition.values[[type]][[task]][group1,group2],value)
#         tmp[is.na(tmp)]=T
#         network[group1,group2]<<-network[group1,group2]-tmp
#         # if(!all(group1==group2))
#         # {
#         #   network[group2,group1]<<-network[group2,group1]+t(tmp)
#         # }
#       }
#     }
#   }
#   network[which(network<length(unique(thresh$type)))]<<-0
#   network[which(network!=0)]<<-1
#   net_igraph<<-graph_from_adjacency_matrix(network,mode='undirected',diag=F)
#   edgeinfo<<-as.data.frame(as_edgelist(net_igraph),stringsAsFactors = F)
#   colnames(edgeinfo)<<-c('N1','N2')
#   edgeinfo[,'N1.group']<<-after_slice_geneinfo[edgeinfo$N1,'.group']
#   edgeinfo[,'N2.group']<<-after_slice_geneinfo[edgeinfo$N2,'.group']
# 
#   genetypesorder=t(apply(X = edgeinfo[,c("N1.group",'N2.group')],MARGIN = 1,FUN = order))
#   reorderindex=which(genetypesorder[,1]>genetypesorder[,2])
#   edgeinfo[reorderindex,c("N1","N2")]<<-edgeinfo[reorderindex,c("N2","N1")]
#   edgeinfo[reorderindex,c("N1.group","N2.group")]<<-edgeinfo[reorderindex,c("N2.group","N1.group")]
#   edgeinfo[,'type']<<-apply(X = edgeinfo[,c('N1.group',"N2.group")],MARGIN = 1,FUN = paste,collapse="---")
# 
#   for(type in unique(thresh$type))
#   {
#     if('all' %in% names(condition.values[[type]]))
#     {
#       edgeinfo[,type]<<-condition.values[[type]][['all']][as.matrix(edgeinfo[,1:2])]
#     }
#     else
#     {
#       for(group in unique(edgeinfo$type))
#       {
#         index=which(edgeinfo$type==group)
#         if(is.null(condition.values[[type]][[group]]))
#         {
#           edgeinfo[index,type]<<-NA
#         }
#         else
#         {
#           edgeinfo[index,type]<<-condition.values[[type]][[group]][as.matrix(edgeinfo[index,c('N1','N2')])]
#         }
#       }
#     }
#   }
#   print(sum(network,na.rm = T))
# }

edgeType=function(type1,type2)
{
  invalid.index=which(type1>type2)
  invalid.type1=type1[invalid.index]
  type1[invalid.index]=type2[invalid.index]
  type2[invalid.index]=invalid.type1
  return(paste(type1,type2,sep="---"))
}

network_construnction=function(after_slice_geneinfo)
{
  print(thresh)
  allgene=rownames(after_slice_geneinfo)[which(!is.na(after_slice_geneinfo$.group))]
  edgeinfo<<-data.frame()
  gc()

  tasks=unique(thresh$task)
  for(type in unique(thresh$type))
  {    
    session$sendCustomMessage('network_construction',list(status='update',value=paste("Applying Condition ",type,"...",sep=""),id="network_construction_progress"))
    tmpedges=data.frame()
    type.thresh=thresh[which(thresh$type==type),]
    datalist=readData(type,unlist(strsplit(condition[type,'task'],split = ";")))
    #colnames(edgeinfo)[ncol(edgeinfo)]<<-type
    for(i in seq(1,dim(type.thresh)[1]))
    {
      task=type.thresh$task[i]
      direction=get(type.thresh$direction[i])
      value=type.thresh$thresh[i]
      tmpedge=which(direction(datalist[[type]][[task]],value),arr.ind = T)
      tmpedge=data.frame(N1=rownames(datalist[[type]][[task]])[tmpedge[,1]],N2=colnames(datalist[[type]][[task]])[tmpedge[,2]],stringsAsFactors = F)
      tmpedge$value=datalist[[type]][[task]][as.matrix(tmpedge[,c(1,2)])]

      if(all(rownames(datalist[[type]][[task]])==colnames(datalist[[type]][[task]])))
      {
        tmpedge=tmpedge[which(tmpedge$N1<tmpedge$N2),]
      }
      else
      {
        misorder.index=which(tmpedge$N1>tmpedge$N2)
        if(length(misorder.index)>0)
        {
          misorder.N1=tmpedge$N1[misorder.index]
          tmpedge$N1[misorder.index]=tmpedge$N2[misorder.index]
          tmpedge$N2[misorder.index]=misorder.N1
        }
      }
      tmpedges=rbind(tmpedges,tmpedge)
      rownames(tmpedges)=paste(tmpedges$N1,tmpedges$N2,sep="+")

      #edgeinfo[paste(tmpedge$n1,tmpedge$n2,sep="+"),type]<<-tmpedge$value
    }
    if(nrow(edgeinfo)==0)
    {
      edgeinfo<<-tmpedges
      colnames(edgeinfo)[ncol(edgeinfo)]<<-type
    }
    else
    {
      commonedge=intersect(rownames(edgeinfo),rownames(tmpedges))
      edgeinfo<<-edgeinfo[commonedge,]
      edgeinfo<<-data.frame(edgeinfo,value=tmpedges[commonedge,'value'])
      colnames(edgeinfo)[ncol(edgeinfo)]<<-type
    }
  }
  edgeinfo<<-data.frame(edgeinfo,N1.group=after_slice_geneinfo[edgeinfo$N1,'.group'],stringsAsFactors = F)
  edgeinfo<<-data.frame(edgeinfo,N2.group=after_slice_geneinfo[edgeinfo$N2,'.group'],stringsAsFactors = F)
  edgeinfo<<-data.frame(edgeinfo,type=edgeType(edgeinfo$N1.group,edgeinfo$N2.group),stringsAsFactors = F)
  #rownames(edgeinfo)<<-paste(edgeinfo$N1,edgeinfo$N2,sep="+")
  #
  # invalid.edge.index=which(is.na(edgeinfo),arr.ind = T)
  # edgeinfo<<-edgeinfo[(invalid.edge.index[,1]*-1),]
  session$sendCustomMessage('network_construction',list(status='update',value="Network Constructing...",id="network_construction"))
  net_igraph<<-graph_from_edgelist(as.matrix(edgeinfo[,1:2]),directed = F)
  isolate.node=setdiff(allgene,unique(c(edgeinfo$N1,edgeinfo$N2)))
  net_igraph<<-add_vertices(net_igraph,nv = length(isolate.node),name=isolate.node)
}