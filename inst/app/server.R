####################################
#### Google Analytics - server.R ###
####################################

print(options('shiny.maxRequestSize'))

shinyServer(function(input,output,session) {

  FLAGS=list(reintersect=T)
  source('www/R/input_tabServer.R',local = T)
  source('www/R/construct_tabServer.R',local = T)
  source('www/R/analysis_tabServer.R',local = T)
  source('www/R/process_tabServer.R',local = T)

  connectEnsembl(session)

  if(is.null(projName)){
    projName <<- session$token
  }
  basepath = paste(tmpdir,'/Project_',projName,sep="");
  dir.create(path = basepath,recursive = T)
  print(paste("Session:",session$token,'is started!'))
  dir.create(paste(basepath,'Plot',sep="/"))
  dir.create(paste(basepath,'code',sep="/"))
  dir.create(paste(basepath,'data',sep="/"))
  dir.create(paste(basepath,'log',sep="/"))
  print(paste("Templete File Dictionary:",basepath))
  visual_layout=""
  
  ############Input Page Action##########
  observeEvent(input$Cenet_demo,{
    removeUI(selector = "#modalbody>",multiple = T,immediate = T)
    insertUI(selector = "#modalbody", ui=create_progress("Loading Demo Data..."),where = 'beforeEnd',immediate = T)
    session$sendCustomMessage('network_construction',list(status='update',value="Upload Demo Data...",id="modalbody"))
    sep_cus = ""
    sep = "\t"
    header = TRUE
    rowname = FALSE
    filepath = paste(getwd(),"demo","ceRNA_exp.txt",sep = "/")
    #filepath = gsub("/","\\\\",filepath)
      ### ceRNA_preview
    tryCatch({
        
        session$sendCustomMessage('reading',list(div='ceRNA_preview',status='ongoing'))
        
        if(sep_cus!="")
        {
          sep=sep_cus
        }
        if(is.null(filepath))
        {
          rna.exp<<-'No Data'
        }else
        {
          rna.exp<<-read.table(file = filepath,header = header,sep = sep,quote = "",nrow=-1,stringsAsFactors = F,check.names = F)
        }
        if(rowname)
        {
          rownames(rna.exp)<<-rna.exp[,1];
          rna.exp<<-rna.exp[,-1]
        }
        select.gene<<-rownames(rna.exp)
        Sys.sleep(2)
        session$sendCustomMessage('reading',list(div='ceRNA_preview',status='finish'))
        output$ceRNA_preview=renderTable({
          return(head(rna.exp,n = 20))
        },escape = F,hover=T,width='100%',bordered = T,striped=T,rownames=T,colnames=T,align='c')
      },error=function(e)
      {
        session$sendCustomMessage('reading',list(div='ceRNA_preview',status='finish'))
        sendSweetAlert(session = session,title = "Error...",text = e$message,type = 'error')
      })
      
      ### micro_preview
      rowname = TRUE
      filepath = paste(getwd(),"demo","micro_exp.txt",sep = "/")
     # filepath = gsub("/","\\\\",filepath)
      session$sendCustomMessage('reading',list(div='microRNA_preview',status='ongoing'))
      tryCatch({
        if(sep_cus!="")
        {
          sep=sep_cus
        }
        if(is.null(filepath))
        {
          micro.ex<<-'No Data'
        }else
        {
          micro.exp<<-read.table(file = filepath,header = header,sep = sep,quote = "",nrow=-1,stringsAsFactors = F,check.names = F)
        }
        # if(!row)
        # {
        #   micro.exp<<-t(micro.exp)
        # }
        if(rowname)
        {
          rownames(micro.exp)<<-micro.exp[,1]
          micro.exp<<-micro.exp[,-1]
        }
        Sys.sleep(2)
        session$sendCustomMessage('reading',list(div='microRNA_preview',status='finish'))
        output$microRNA_preview=renderTable({
          return(head(micro.exp,n = 20))
        },escape = F,hover=T,width='100%',bordered = T,striped=T,rownames=T,colnames=T,align='c')
      },error=function(e){
        session$sendCustomMessage('reading',list(div='microRNA_preview',status='finish'))
        sendSweetAlert(session = session,title = "Error...",text = e$message,type = 'error')
      })
      ###target input
      rowname = FALSE
      filepath = paste(getwd(),"demo","target.txt",sep = "/")
      #filepath = gsub("/","\\\\",filepath)
      session$sendCustomMessage('reading',list(div='target_preview_panel',status='ongoing'))
     
      tryCatch({
        if(sep_cus!="")
        {
          sep=sep_cus
        }
        if(is.null(filepath))
        {
          target<<-'No Data'
        }else
        {
          target<<-read.table(file = filepath,header = header,sep = sep,quote = "",stringsAsFactors = F,check.names = F)
        }
        if(rowname)
        {
          rownames(target)<<-target[,1]
          target<<-target[,-1]
        }
        Sys.sleep(2)
        session$sendCustomMessage('reading',list(div='target_preview_panel',status='finish'))
        output$target_preview_panel=renderTable({
          return(t(head(t(head(target,n = 20)),n = 20)))
        },escape = F,hover=T,width='100%',bordered = T,striped=T,rownames=T,colnames=T,align='c')
      },error=function(e){
        session$sendCustomMessage('reading',list(div='target_preview_panel',status='finish'))
        sendSweetAlert(session = session,title = "Error...",text = e$message,type = 'error')
      })
      ###geneinfo input
      rowname = TRUE
      filepath = paste(getwd(),"demo","geneinfo.txt",sep = "/")
      #filepath = gsub("/","\\\\",filepath)
      session$sendCustomMessage('reading',list(div='geneinfo_preview_panel',status='ongoing'))
    
      tryCatch({
        if(sep_cus!="")
        {
          sep=sep_cus
        }
        if(is.null(filepath))
        {
          geneinfo<<-'No Data'
        }else
        {
          geneinfo<<-read.table(file = filepath,header = header,sep = sep,quote = "",nrow=-1,stringsAsFactors = F)
        }
        if(rowname)
        {
          rownames(geneinfo)<<-geneinfo[,1]
        }
        type=as.data.frame(lapply(X = geneinfo,FUN = class))
        non_character=names(type[which(type!='character')])
        for(col in non_character)
        {
          geneinfo[,col]<<-as.character(geneinfo[,col])
        }
        Sys.sleep(2);
        session$sendCustomMessage('reading',list(div='geneinfo_preview_panel',status='finish'))
        output$geneinfo_preview_panel=renderTable({
          return(head(geneinfo,n = 20))
        },escape = F,hover=T,width='100%',bordered = T,striped=T,rownames=T,colnames=T,align='c')
      },error=function(e){
        session$sendCustomMessage('reading',list(div='geneinfo_preview_panel',status='finish'))
        sendSweetAlert(session = session,title = "Error...",text = e$message,type = 'error')
      })
      session$sendCustomMessage('network_construction',list(status='finish',value="modalbody"))
      
  })
  observeEvent(input$onclick,{
    isolate({msg=fromJSON(input$onclick)})
    if(msg$id=='express_preview')
    {
      ### ceRNA_preview
      tryCatch({
        session$sendCustomMessage('reading',list(div='ceRNA_preview',status='ongoing'))
        isolate({
          sep_cus=input$ceRNA_seprator_cus;
          sep=input$ceRNA_seperator;
          filepath=input$ceRNA$datapath;
          header=as.logical(input$ceRNA_header);
          #quote=input$ceRNA_quote
          #row=as.logical(input$ceRNA_row_col)
          rowname=as.logical(input$ceRNA_first_col)
          #browser()
        })
        if(sep_cus!="")
        {
          sep=sep_cus
        }
        if(is.null(filepath))
        {
          rna.exp<<-'No Data'
        }else
        {
          rna.exp<<-read.table(file = filepath,header = header,sep = sep,quote = "",nrow=-1,stringsAsFactors = F,check.names = F)
        }
        if(rowname)
        {
          rownames(rna.exp)<<-rna.exp[,1];
          rna.exp<<-rna.exp[,-1]
        }
        select.gene<<-rownames(rna.exp)
        Sys.sleep(2)
        session$sendCustomMessage('reading',list(div='ceRNA_preview',status='finish'))
        output$ceRNA_preview=renderTable({
          return(head(rna.exp,n = 20))
        },escape = F,hover=T,width='100%',bordered = T,striped=T,rownames=T,colnames=T,align='c')
      },error=function(e)
      {
        session$sendCustomMessage('reading',list(div='ceRNA_preview',status='finish'))
        sendSweetAlert(session = session,title = "Error...",text = e$message,type = 'error')
      })
      
      ### micro_preview
      session$sendCustomMessage('reading',list(div='microRNA_preview',status='ongoing'))
      isolate({
        sep_cus=input$micro_seprator_cus;
        sep=input$micro_seperator;
        filepath=input$micro$datapath;
        header=as.logical(input$micro_header);
        #quote=input$micro_quote
        #row=as.logical(input$micro_row_col)
        rowname=as.logical(input$micro_first_col)
      })
      tryCatch({
        if(sep_cus!="")
        {
          sep=sep_cus
        }
        if(is.null(filepath))
        {
          micro.ex<<-'No Data'
        }else
        {
          micro.exp<<-read.table(file = filepath,header = header,sep = sep,quote = "",nrow=-1,stringsAsFactors = F,check.names = F)
        }
        # if(!row)
        # {
        #   micro.exp<<-t(micro.exp)
        # }
        if(rowname)
        {
          rownames(micro.exp)<<-micro.exp[,1]
          micro.exp<<-micro.exp[,-1]
        }
        Sys.sleep(2)
        session$sendCustomMessage('reading',list(div='microRNA_preview',status='finish'))
        output$microRNA_preview=renderTable({
          return(head(micro.exp,n = 20))
        },escape = F,hover=T,width='100%',bordered = T,striped=T,rownames=T,colnames=T,align='c')
      },error=function(e){
        session$sendCustomMessage('reading',list(div='microRNA_preview',status='finish'))
        sendSweetAlert(session = session,title = "Error...",text = e$message,type = 'error')
      })
    }
    else if(msg$id=='target_preview')
    {
      session$sendCustomMessage('reading',list(div='target_preview_panel',status='ongoing'))
      isolate({
        sep_cus=input$target_seprator_cus;
        sep=input$target_seperator;
        filepath=input$target$datapath;
        header=as.logical(input$target_header);
        #quote=input$target_quote
        rowname=as.logical(input$target_first_col)
      })
      tryCatch({
        if(sep_cus!="")
        {
          sep=sep_cus
        }
        if(is.null(filepath))
        {
          target<<-'No Data'
        }else
        {
          target<<-read.table(file = filepath,header = header,sep = sep,quote = "",stringsAsFactors = F,check.names = F)
        }
        if(rowname)
        {
          rownames(target)<<-target[,1]
          target<<-target[,-1]
        }
        Sys.sleep(2)
        session$sendCustomMessage('reading',list(div='target_preview_panel',status='finish'))
        output$target_preview_panel=renderTable({
          return(t(head(t(head(target,n = 20)),n = 20)))
        },escape = F,hover=T,width='100%',bordered = T,striped=T,rownames=T,colnames=T,align='c')
      },error=function(e){
        session$sendCustomMessage('reading',list(div='target_preview_panel',status='finish'))
        sendSweetAlert(session = session,title = "Error...",text = e$message,type = 'error')
      })
      
    }
    else if(msg$id=='geneinfo_preview')
    {
      session$sendCustomMessage('reading',list(div='geneinfo_preview_panel',status='ongoing'))
      
      isolate({
        sep_cus=input$geneinfo_seprator_cus;
        sep=input$geneinfo_seperator;
        filepath=input$geneinfo$datapath;
        header=as.logical(input$geneinfo_header);
        #quote=input$geneinfo_quote
        rowname=as.logical(input$geneinfo_first_col)
      })
      tryCatch({
        if(sep_cus!="")
        {
          sep=sep_cus
        }
        if(is.null(filepath))
        {
          geneinfo<<-'No Data'
        }else
        {
          geneinfo<<-read.table(file = filepath,header = header,sep = sep,quote = "",nrow=-1,stringsAsFactors = F)
        }
        if(rowname)
        {
          rownames(geneinfo)<<-geneinfo[,1]
        }
        type=as.data.frame(lapply(X = geneinfo,FUN = class))
        non_character=names(type[which(type!='character')])
        for(col in non_character)
        {
          geneinfo[,col]<<-as.character(geneinfo[,col])
        }
        Sys.sleep(2);
        session$sendCustomMessage('reading',list(div='geneinfo_preview_panel',status='finish'))
        output$geneinfo_preview_panel=renderTable({
          return(head(geneinfo,n = 20))
        },escape = F,hover=T,width='100%',bordered = T,striped=T,rownames=T,colnames=T,align='c')
      },error=function(e){
        session$sendCustomMessage('reading',list(div='geneinfo_preview_panel',status='finish'))
        sendSweetAlert(session = session,title = "Error...",text = e$message,type = 'error')
      })
      
    }
    FLAGS[['reintersect']]<<-T
  })
  observeEvent(input$ensembl_info,{
    isolate({
      msg=fromJSON(input$ensembl_info)
    })
    if(msg$id=='database_choose')
    {
      session$sendCustomMessage('ensembl_database_info',list(title='Database',body=toJSON(specials)))
    }
    else if(msg$id=='archieve_choose')
    {
      session$sendCustomMessage('ensembl_archieve_info',list(title='Archieve',body=toJSON(archieves)))
    }
    else if(msg$id=='filter_choose')
    {
      session$sendCustomMessage('ensembl_filter_info',list(title='Input Type',body=toJSON(filters)))
    }
    else if(msg$id=='gene_choose')
    {
      session$sendCustomMessage('select_gene',list(title='Gene',body=toJSON(list(all=data.frame(gene=rownames(rna.exp),stringsAsFactors = F),select=select.gene))))
    }
  })
  observeEvent(input$Update_Ensembl,{
    isolate({
      special=input$database
      url=input$archieve
    })
    Sys.sleep(1)
    updateEnsembl(special,url,session)
  })
  observeEvent(input$attribution_update,{
    addAttribution(session)
  })
  observeEvent(input$Update_Select_Gene,{
    isolate({
      msg=input$Update_Select_Gene
    })
    select.gene<<-unlist(msg$select_gene)
  })
  observeEvent(input$sweetAlert,{
    isolate({
      msg=input$sweetAlert
    })
    sendSweetAlert(session = session,title = msg$title,text = msg$text,type = msg$type)
  })
  observeEvent(input$ensembl_gene_info,{
    isolate({
      msg=input$ensembl_gene_info
    })
    filter=msg$filter
    attr=unlist(msg$attr)
    attr=attr[which(attr!="")]
    attr=unlist(strsplit(x = attr,split = ":"))
    attr=attr[seq(2,length(attr),2)]
    gene=unlist(msg$gene)
    select.gene<<-gene
    attr=unique(c(filter,attr))
    session$sendCustomMessage('reading',list(div='geneinfo_preview_panel',status='ongoing'))
    feature=getBM(attributes = attr,filters = filter,values = select.gene,mart = ensembl)
    newfeature=data.frame()
    for(g in unique(feature[,1]))
    {
      index=which(feature[,1]==g)
      tmpFeature=t(as.data.frame(apply(X = feature[index,],MARGIN = 2,FUN = mergeEnsembl),stringsAsFactors = F))
      newfeature=rbind(newfeature,tmpFeature[1,],stringsAsFactors=F)
    }
    colnames(newfeature)=colnames(tmpFeature)
    rownames(newfeature)=newfeature[,filter]
    session$sendCustomMessage('reading',list(div='geneinfo_preview_panel',status='finish'))
    geneinfo<<-newfeature
    output$geneinfo_preview_panel=renderTable({
      return(head(geneinfo,n = 20))
    },escape = F,hover=T,width='100%',bordered = T,striped=T,rownames=T,colnames=T,align='c')
    # session$sendCustomMessage('geneinfo',toJSON(geneinfo))
  })
  output$geneinfo_export <- downloadHandler(
    filename = function() {
      return("geneinfo.txt")
    },
    content = function(file) {
      write.table(x=geneinfo,file = file, quote = F,sep = "\t",row.names = T,col.names = T)
    }
  )
  #########Process Page Action########
  observeEvent(input$interclick,{
    if(is.character(rna.exp)){
      sendSweetAlert(session = session,title = "Error..",text = "ceRNA Not Exist!",type = "error");
      return();
    }
    else if(is.character(micro.exp)){
      sendSweetAlert(session = session,title = "Error..",text = "microRNA Not Exist!",type = "error");
      return();
    }
    else if(is.character(target)){
      sendSweetAlert(session = session,title = "Error..",text = "Target Not Exist!",type = "error");
      return();
    }
    else if(is.character(geneinfo)){
      sendSweetAlert(session = session,title = "Error..",text = "Geneinfo Not Exist!",type = "error");
      return();
    }
    else{
      if(FLAGS[['reintersect']]){
        FLAGS[['reintersect']]<<-F
        sect_gene=intersect(rownames(rna.exp),rownames(target));
        sect_gene=intersect(sect_gene,rownames(geneinfo));
        sect_micro=intersect(rownames(micro.exp),names(target));
        sect_sample=intersect(names(rna.exp),names(micro.exp));
        sect_output_rna.exp<<-rna.exp[sect_gene,sect_sample];
        sect_output_micro.exp<<-micro.exp[sect_micro,sect_sample]
        sect_output_target<<-target[sect_gene,sect_micro];
        sect_output_geneinfo<<-geneinfo[sect_gene,]
        #sect_output_geneinfo$.group<<-NA
        after_slice_micro.exp<<-sect_output_micro.exp
        after_slice_rna.exp<<-sect_output_rna.exp
        after_slice_geneinfo<<-sect_output_geneinfo
        validNum1 = length(sect_gene);
        validNum2 = length(sect_micro);
        validNum3 = length(sect_sample);
        ValidNum = data.frame(rnaNum = validNum1,microNum = validNum2,sampleNum = validNum3,stringsAsFactors = F);
        session$sendCustomMessage('Valid-Num',ValidNum);
      }
    }
  })
  observeEvent(input$process_showdetails,{
    isolate({
      msg=input$process_showdetails;
    })
    if(msg$id=='Rnaoutput'){
        obj=list(title='Valid ceRNA',details=toJSON(data.frame(detail= rownames(after_slice_rna.exp),stringsAsFactors =F)));
        session$sendCustomMessage('outdetails',obj);
    }
    if(msg$id=='MicroRnaoutput'){
       obj=list(title='Valid microRNA',details=toJSON(data.frame(detail= rownames(after_slice_micro.exp),stringsAsFactors =F)));
       session$sendCustomMessage('outdetails',obj);
    }
    if(msg$id=='Sampleoutput'){
    
       obj=list(title='Valid Sample',details=toJSON(data.frame(detail= intersect(names(after_slice_micro.exp),names(after_slice_rna.exp)),stringsAsFactors =F)));
       session$sendCustomMessage('outdetails',obj);
    }
  })
  observeEvent(input$Update_Biotype_Map,{
    choice=colnames(sect_output_geneinfo)
    choice=setdiff(choice,".group")
    choicenum=lapply(X = sect_output_geneinfo,FUN = unique)
    choicenum=lapply(X = choicenum,FUN = length)
    names(choicenum)=choice
    choicenum=unlist(choicenum)
    invalidchoice=names(choicenum)[which(choicenum>typeLimit)]
    validchoice=names(choicenum)[which(choicenum<=typeLimit)]
    if(!is.null(biotype_map))
    {
      updatePrettyRadioButtons(session = session,inputId = 'biotype_map',label = 'Mapping Columns',choices = choice,selected = head(validchoice,n=1),inline=T,prettyOptions=list(shape='round',status='success'))
    }
    else
    {
      updatePrettyRadioButtons(session = session,inputId = 'biotype_map',label = 'Mapping Columns',choices = choice,selected = biotype_map,inline=T,prettyOptions=list(shape='round',status='success'))
    }
    session$sendCustomMessage('invalidColumn',data.frame(choice=invalidchoice,stringsAsFactors = F))
  })
  observe({
    biotype_map<<-input$biotype_map
    if(!is.null(biotype_map)&&biotype_map!='None')
    {
     
      choice=unique(sect_output_geneinfo[,biotype_map])
      if(length(choice)>typeLimit)
      {
        session$sendCustomMessage('update_candidate_biotype',list(item=sort(choice),signal='invalid'))
      }
      else
      {
        session$sendCustomMessage('update_candidate_biotype',list(item=sort(choice),signal='valid'))
      }
    }
  })
  observeEvent(input$show_biotype_group,{
    isolate({
      #biotype=input$biotype_map
      msg=input$show_biotype_group
      data=msg$data
      biotype=msg$biotype
    })
    sect_output_geneinfo$.group<<-NA
    if(is.null(biotype))
    {
      sect_output_geneinfo[,'.group']<<-"Default"
      sendSweetAlert(session = session,title = "Warning..",
                     text = 'Group All Genes to Group "Default"!',type = 'warning')    }
    else
    {
      for(group in names(data))
      {
        subset=unlist(data[[group]])
        sect_output_geneinfo[sect_output_geneinfo[,biotype] %in% subset,'.group']<<-group
      }
    }
    after_slice_geneinfo <<- sect_output_geneinfo[which(!is.na(sect_output_geneinfo$.group)),]
    after_slice_rna.exp <<- sect_output_rna.exp[rownames(after_slice_geneinfo),]
    ValidNum = data.frame(rnaNum = length(rownames(after_slice_rna.exp)),stringsAsFactors = F);
    
    if(is.null(biotype))
    {
      p=ggplot(data =after_slice_geneinfo)+geom_bar(mapping = aes_string(x = '.group'))+
        labs(title='Group Genes Statistics',x='Group',y='Gene Count')+
        theme(legend.position = 'bottom',panel.background = element_rect(fill = NA))
    }
    else
    {
      if(length(unique(after_slice_geneinfo[,biotype]))>8)
      {
        p=ggplot(data =after_slice_geneinfo)+geom_bar(mapping = aes_string(x = '.group',fill=biotype))+
          labs(title='Group Genes Statistics',x='Group',y='Gene Count')+
          scale_fill_manual(values = colorRampPalette(usedcolors)(length(unique(after_slice_geneinfo[,biotype]))))+
          theme(legend.position = 'bottom',panel.background = element_rect(fill = NA))
      }else
      {
        p=ggplot(data =after_slice_geneinfo)+geom_bar(mapping = aes_string(x = '.group',fill=biotype))+
          labs(title='Group Genes Statistics',x='Group',y='Gene Count')+
          theme(legend.position = 'bottom',panel.background = element_rect(fill = NA))
      }
    }
    p=p+theme(axis.title = element_text(family = "serif"),axis.text = element_text(family = "serif",colour = "black", vjust = 0.25), 
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
    svglite(paste(basepath,"Plot",'Gene_Group.svg',sep="/"))
    print(p)
    dev.off()
    
    output$biotype_group_statics_graph=renderImage({
      list(src=normalizePath(paste(basepath,"Plot",'Gene_Group.svg',sep="/")),height="100%",width="100%")    
    },deleteFile=F)
    
    session$sendCustomMessage('Valid_valuebox_rna',ValidNum);
    session$sendCustomMessage('clear_construction_task',"")
    
  })
  # download picture
  output$downloadData_group <- downloadHandler(
    filename = function() {
       return("Group_statistic.svg");
    },
    content = function(file) {
      file.copy(from = paste(basepath,"Plot",'Gene_Group.svg',sep="/"),to = file);
    }
  )
  
  sample_filter_choose=list()
  observeEvent(input$Sample_Filter,{
    isolate({
      msg=input$Sample_Filter
      #sep=msg$sep
      group=msg$group
      exist=msg$exist
      value=as.numeric(msg$value)
      direction=msg$direction
      thresh=as.numeric(msg$thresh)
    })
    if(group=="micro_invalid_name")
    {
      # gene_filter_choose['micro'] <<- list(c(number,line))
      tmpdata=data.frame(count=(colSums(get(direction)(sect_output_micro.exp,thresh)))/nrow(sect_output_micro.exp),
                             color='Remove',stringsAsFactors = F)
      draw_x<-(max(tmpdata$count)+min(tmpdata$count))/2  
      x2<-quantile(tmpdata$count,value,type=3) 
      draw_x2<-round(x2,3)
      tmpdata$color[which(tmpdata$count>x2)]='Remain'
    
      liuxiasum<-length(which(tmpdata$count>x2))
      text1=paste("Valid Sample Ratio=",round(x2,3))
      text2=paste("Remain:",liuxiasum)
      sample_filter_choose['micro_invalid_name']<<-list(c(value,direction,thresh,liuxiasum))
      p=ggplot()+
        geom_histogram(data = tmpdata,mapping = aes(x=count,fill=color),color="black",bins = 100) +
        scale_fill_manual(values=c('Remove'="white",'Remain'= "#9b59b6"))+
        geom_vline(xintercept=x2, colour="#990000", linetype="dashed",size=1.1)+
        labs(title = "MicroRNA Sample Quality Control")+xlab("Valid MicroRNA Ratio")+ylab('Sample Count')+
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
              panel.background = element_rect(fill = NA)) +labs(fill = "If Remain")
      pp=ggplot_build(p)
      axis_y<-get(x = "range",envir = pp$layout$panel_scales_y[[1]]$range)
      axis_x<-get(x = "range",envir = pp$layout$panel_scales_x[[1]]$range)
      x_pianyi=(axis_x[2]-axis_x[1])*0.2
      if(var(tmpdata$count)!=0){
        if(skewness(tmpdata$count)<0){
          text=data.frame(label=c(text1,text2),x=axis_x[1]+x_pianyi,y=c(axis_y[2],axis_y[2]*0.95),stringsAsFactors = F)
        }else{
          text=data.frame(label=c(text1,text2),x=axis_x[2]-x_pianyi,y=c(axis_y[2],axis_y[2]*0.95),stringsAsFactors = F)
        }
      }else{
        text=data.frame(label=c(text1,text2),x=axis_x[1]+x_pianyi,y=c(axis_y[2],axis_y[2]*0.95),stringsAsFactors = F)
      }
      p=p+geom_text(data=text,mapping = aes(x = x,y = y,label=label),size=6,family='serif',inherit.aes = F)+
        xlim(axis_x[1]-x_pianyi*5/150, axis_x[2]+x_pianyi*5/150)


      svglite(paste(basepath,"Plot","microSampleFilter.svg",sep = "/"))
      print(p)
      dev.off()
  
      if(exist=="F"){
        print(paste("#","sample_Group_",group,'_panel',sep=""))
        insertUI(
          selector = paste("#","sample_Group_",group,'_panel',sep=""),
          where='beforeEnd',
          ui=imageOutput(outputId = paste(group,'_plot',sep=""),height = "100%"),
          immediate = T
        )
        
        # insertUI(
        #  selector = paste("#","sample_Group_",group,'_panel',sep=""),
        #  where='beforeEnd',
        #  ui=div(class="box-footer",
        #         downloadButton("downloadData_micro_sample", "Download"),
        #         tags$button(class = "btn btn-success action-button pull-right shiny-bound-input",
        #                     onclick=paste("slice('#","sample_Group_",group,"_panel')",sep=""),
        #                     style="margin:5px",height = "100%",HTML("Filter"))),
        #  immediate = T
        # )
      }
      
      output[[paste(group,'_plot',sep="")]]=renderImage({
        list(src=paste(basepath,"Plot","microSampleFilter.svg",sep = "/"),width="100%",height="100%")
      },deleteFile = F)
    }
    
    else if(group=="ce_invalid_name"){
      
      tmpdata=data.frame(count=(colSums(get(direction)(sect_output_rna.exp,thresh)))/nrow(sect_output_rna.exp),
                         color='Remove',stringsAsFactors = F)
      value=as.numeric(value)
      draw_x<-(max(tmpdata$count)+min(tmpdata$count))/2  
      x2<-quantile(tmpdata$count,value,type=3)
      tmpdata$color[which(tmpdata$count>x2)]='Remain'
      draw_x2<-round(x2,3)
      
      liuxiasum<-length(which(tmpdata$count>x2))
      text1=paste("Valid Sample Ratio=",round(x2,3))
      text2=paste("Remain:",liuxiasum)
      sample_filter_choose['ce_invalid_name']<<-list(c(value,direction,thresh,liuxiasum))
      
      p=ggplot()+
        geom_histogram(data = tmpdata,mapping = aes(x=count,fill=color),color="black",bins = 100) +
        scale_fill_manual(values=c('Remove'="white",'Remain'= "#9b59b6"))+
        geom_vline(aes(xintercept=x2), colour="#990000", linetype="dashed",size=1.1)+
        labs(title = "CeRNA Sample Quality Control")+xlab("Valid CeRNA Ratio")+ylab('Sample Count')+
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
              panel.background = element_rect(fill = NA)) +labs(fill = "If Remain")
      pp=ggplot_build(p)
      axis_y<-get(x = "range",envir = pp$layout$panel_scales_y[[1]]$range)
      axis_x<-get(x = "range",envir = pp$layout$panel_scales_x[[1]]$range)
      x_pianyi=(axis_x[2]-axis_x[1])*0.2
      if(var(tmpdata$count)!=0){
        if(skewness(tmpdata$count)<0){
          text=data.frame(label=c(text1,text2),x=axis_x[1]+x_pianyi,y=c(axis_y[2],axis_y[2]*0.95),stringsAsFactors = F)
        }else{
          text=data.frame(label=c(text1,text2),x=axis_x[2]-x_pianyi,y=c(axis_y[2],axis_y[2]*0.95),stringsAsFactors = F)
        }
      }else{
        text=data.frame(label=c(text1,text2),x=axis_x[1]+x_pianyi,y=c(axis_y[2],axis_y[2]*0.95),stringsAsFactors = F)
      }
      p=p+geom_text(data=text,mapping = aes(x = x,y = y,label=label),size=6,family='serif',inherit.aes = F)+
        xlim(axis_x[1]-x_pianyi*5/150, axis_x[2]+x_pianyi*5/150)
      
      svglite(paste(basepath,"Plot","RNASampleFilter.svg",sep = "/"))
      print(p)
      dev.off()
      if(exist=="F"){
        print(paste("#","sample_Group_",group,'_panel',sep=""))
        insertUI(
          selector = paste("#","sample_Group_",group,'_panel',sep=""),
          where='beforeEnd',
          ui=imageOutput(outputId = paste(group,'_plot',sep=""),height = "100%"),
          immediate = T
        )
        
        # insertUI(
        #   selector = paste("#","sample_Group_",group,'_panel',sep=""),
        #   where='beforeEnd',
        #   ui=div(class="box-footer",
        #          downloadButton("downloadData_rna_sample", "Download"),
        #          tags$button(class = "btn btn-success action-button pull-right shiny-bound-input",
        #                      onclick=paste("slice('#","sample_Group_",group,"_panel')",sep=""),
        #                      style="margin:5px",height = "100%",HTML("Filter"))),
        #   immediate = T
        # )
      }
      
     
      output[[paste(group,'_plot',sep="")]]=renderImage({
        list(src=paste(basepath,"Plot","RNASampleFilter.svg",sep = "/"),width="100%",height="100%")
      },deleteFile = F)
    }
  })
  
  observeEvent(input$Sample_Slice_Signal,{
    # isolate({
    #   msg=input$Sample_Slice_Signal
    #   group=msg$group
    #   line=msg$line
    #   line=as.numeric(line)
    #   thresh=as.numeric(msg$thresh)
    #   direction=msg$direction
    # })
    after_slice_geneinfo <<- sect_output_geneinfo[which(!is.na(sect_output_geneinfo$.group)),]
    
    after_slice_micro.exp<<-sect_output_micro.exp[rownames(after_slice_geneinfo),]
    after_slice_rna.exp<<-sect_output_rna.exp[rownames(after_slice_geneinfo),]
    if(length(sample_filter_choose)==0){
      sendSweetAlert(session = session,title = "Warning..",
                     text = 'Please click one preview at least!..',type = 'warning')
    }
    else{
      num1 = length(colnames(sect_output_micro.exp))
      num2=length(colnames(sect_output_rna.exp))
      flag_micro=0
      flag_ce=0
      for(type in names(sample_filter_choose)){
        # sample_filter_choose['micro_invalid_name']<<-list(c(value,direction,thresh))
        line =as.numeric(sample_filter_choose[[type]][1])  
        direction = sample_filter_choose[[type]][2]
        thresh=as.numeric(sample_filter_choose[[type]][3]) 
        
        if(type=="micro_invalid_name"){
          expressgene_num=(colSums(get(direction)(sect_output_micro.exp,thresh)))/nrow(sect_output_micro.exp)
          x2<-quantile(expressgene_num,line,type=3) 
          
          liuxiasum<-length(colnames(sect_output_micro.exp[,which(expressgene_num>x2)]))
          remain_ratio_micro<-liuxiasum/length(colnames(sect_output_micro.exp))
          if(abs((1-line)-remain_ratio_micro)<=0.05){
            after_slice_micro.exp<<-sect_output_micro.exp[rownames(after_slice_geneinfo),which(expressgene_num>x2)]
            num1=liuxiasum
           
          }
          else{
            flag_micro=1
          }
          
        }
        else{
          expressgene_num2=(colSums(get(direction)(sect_output_rna.exp,thresh)))/nrow(sect_output_rna.exp)
          x2<-quantile(expressgene_num2,line,type=3) 
          liuxiasum<-length(colnames(sect_output_rna.exp[,which(expressgene_num2>x2)]))
          remain_ratio_ce<-liuxiasum/length(colnames(sect_output_rna.exp))
          if(abs((1-line)-remain_ratio_ce)<=0.05){
            after_slice_rna.exp<<-sect_output_rna.exp[rownames(after_slice_geneinfo),which(expressgene_num2>x2)]
            num2=liuxiasum
          }
          else{
            flag_ce=1
          }
        }
      }
      if(flag_micro==1){
        delete_ratio_micro=(1-round(remain_ratio_micro,3))*100
        msg=HTML(paste("<h4>Large Error!</h4>",
                       "<h4>This parameter will delete ",delete_ratio_micro,"% samples.</h4>",
                       "<h4>Please choose Percentile of MicroRNA again.</h4>",sep="")) 
        # msg=HTML("<h4>Invalid Slice! </h4><h4>You will delete more than 5% of the selection ratio.</h4><h4>Please choose micro_slice again.</h4>")
        sendSweetAlert(session = session,title = "Warning..",text = msg,type = 'warning',html = T)
      }
      else if(flag_ce==1){
        delete_ratio_ce=(1-round(remain_ratio_ce,3))*100
        msg=HTML(paste("<h4>Large Error!</h4>",
                       "<h4>This parameter will delete ",delete_ratio_ce,"% samples.</h4>",
                       "<h4>Please choose Percentile of CeRNA again.</h4>",sep=""))
        sendSweetAlert(session = session,title = "Warning..",text = msg,type = 'warning',html = T)
      }
      else{
     
        intersect_sample_num<-length(intersect(colnames(after_slice_micro.exp),colnames(after_slice_rna.exp))) 
        # sendSweetAlert(session = session,title = "Success..",text =paste0("Filter Ok! Sample Remain: ",intersect_sample_num) ,type = 'success')
        msg=HTML(paste("<h4>Valid MicroRNA Sample: ",num1,"</h4>",
                       "<h4>Valid CeRNA Sample: ",num2,"</h4>",
                       "<h4>Valid Sample: ",intersect_sample_num,"</h4>",sep=""))
        sendSweetAlert(session = session,title = "Success..",
                       text = msg,
                       type = 'success',html = T)
        
        a=intersect(colnames(after_slice_micro.exp),colnames(after_slice_rna.exp))
        after_slice_micro.exp<<-after_slice_micro.exp[rownames(after_slice_geneinfo),a]
        after_slice_rna.exp<<-after_slice_rna.exp[rownames(after_slice_geneinfo),a]
        
        ValidNum = data.frame(sampleNum = intersect_sample_num,stringsAsFactors = F);
        session$sendCustomMessage('Valid_valuebox_sample',ValidNum);
        
      }
      
    }
    

  })
  
  output$downloadData_sample <- downloadHandler(
    filename = "Sample_Filter_Plot.zip",
    content = function(file) {
      files=c()
      for(str in names(sample_filter_choose)){
        if(str=="micro_invalid_name"){
          files = c(files,paste(basepath,"Plot","microSampleFilter.svg",sep = "/"))
        }else{
          files = c(files,paste(basepath,"/Plot/RNASampleFilter.svg",sep = ""))
        }
      }
      zip(zipfile = file,files = files,flags = "-j")
      # file.copy(from = paste(basepath,"plot","Gene_filter.zip",sep = "/"),to = file);
    }
  )
  
  
  observeEvent(input$creatFilter_request,{
    removeUI(selector = "#Gene_Filter_all>:not(:first-child)",immediate = T,multiple = T)
    level=unique(sect_output_geneinfo$.group)
    level=level[!is.na(level)]
    session$sendCustomMessage('gene_type_infomation',data.frame(group=level))
  
  })
  
  gene_filter_choose = list()
  observeEvent(input$Gene_Filter_Signal,{
    isolate({
      msg=input$Gene_Filter_Signal
      group=msg$group
      group=sub(pattern = "gene_slice_value_",replacement = "",x = group)
      type=msg$type
      number=as.numeric(msg$number)
      exist=msg$exist
      line=msg$line
    })
    
    #paint picture
    if(type=="micro"){ 
      gene_filter_choose['micro'] <<- list(c(number,line))
      
      after_slice_micro.exp<<- sect_output_micro.exp[,colnames(after_slice_micro.exp)]
      validGene=rownames(after_slice_micro.exp)
      validSample = rowSums(after_slice_micro.exp>=number)
      ratio=as.numeric(line)
      xdata = data.frame(SampleRatio=validSample/length(colnames(after_slice_micro.exp)),stringsAsFactors = F)
      ypoint=length(which(xdata$SampleRatio<=ratio))/length(validGene)
      temp.data=data.frame(x=c(0,ratio),xend=c(ratio,ratio),y=c(ypoint,0),yend=c(ypoint,ypoint),stringsAsFactors = F)
      draw_x<-(max(xdata$SampleRatio)+min(xdata$SampleRatio))/2
      number_ori=length(validGene)
      number_after=length(which(xdata$SampleRatio>ratio))
      x1 = min(xdata$SampleRatio)+0.2*max(xdata$SampleRatio)+min(xdata$SampleRatio)
      text_to_plot=data.frame(x=c(x1,x1),y=c(0.95,0.90),col=c("blue","blue"),text=c(paste("Original genes:",number_ori),paste("After seg:",number_after)))
      ypoint =round(ypoint,2)
      
      xdata = data.frame(SampleRatio=validSample/length(colnames(after_slice_micro.exp)),
                         color=as.character(c(xdata$SampleRatio>ratio)),
                         stringsAsFactors = F
      )
      svglite(paste(basepath,"Plot","microStatistic.svg",sep = "/"))
      
      text1=paste("Sample Ratio:",ratio)
      text2=paste("Remain:",number_after)
      
      p=ggplot(xdata,aes(x=SampleRatio,fill=..x..>ratio))+
        geom_histogram(color="black",bins = 100) +
        scale_fill_manual(values=c('FALSE'="white",'TRUE'= "#9b59b6"))+
        geom_vline(aes(xintercept=ratio), colour="#990000", linetype="dashed")
      pp=ggplot_build(p)
      draw_y<-get(x = "range",envir = pp$layout$panel_scales_y[[1]]$range)
      draw_x<-get(x = "range",envir = pp$layout$panel_scales_x[[1]]$range)
      x_pianyi=(draw_x[2]-draw_x[1])*0.2
      if(var(xdata$SampleRatio)!=0){
        if(skewness(xdata$SampleRatio)<0){
          text=data.frame(label=c(text1,text2),x=draw_x[1]+x_pianyi,y=c(draw_y[2],draw_y[2]*0.95),stringsAsFactors = F)
        }
        else{
          text=data.frame(label=c(text1,text2),x=draw_x[2]-x_pianyi,y=c(draw_y[2],draw_y[2]*0.95),stringsAsFactors = F)
        }
      }
      else{
        text=data.frame(label=c(text1,text2),x=draw_x[1]+x_pianyi,y=c(draw_y[2],draw_y[2]*0.95),stringsAsFactors = F)
      }
      
      print(p+xlim(draw_x[1]-x_pianyi*5/150, draw_x[2]+x_pianyi*5/150)+
              geom_text(mapping = aes(x = x,y = y,label=label),data=text,size=6,family='serif')+
              labs(title = "MicroRNA Filter")+
              xlab("Sample Ratio")+ylab('Valid MicroRNA Count')+
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
                    panel.background = element_rect(fill = NA)) +labs(fill = "If Remain")
       
       )
      
      dev.off()
      #file.copy(from = paste(basepath,"Plot","microStatistic.svg",sep = "/"),to = paste('www/templePlot/microStatistic',session$token,'.svg',sep = ""))
      
      if(exist=="F"){
        print(paste("#","gene_Group_",group,'_panel',sep=""))
        insertUI(
          selector = paste("#","gene_Group_",group,'_panel',sep=""),
          where='beforeEnd',
          ui=imageOutput(outputId = paste(group,'_plot',sep=""),height = "100%"),
          immediate = T
        )
        # insertUI(
        #   selector = paste("#","gene_Group_",group,'_panel',sep=""),
        #   where='beforeEnd',
        #   ui=div(class="box-footer",
        #        downloadButton("downloadData_micro", "Download"),
        #        tags$button(class = "btn btn-success action-button pull-right shiny-bound-input",onclick=paste("slice_gene('#","gene_Group_",group,"_panel')",sep=""),style="margin:5px",height = "100%",HTML("Filter"))
        #        ),
        #   immediate = T
        # )
      }
      # output$downloadData_micro <- downloadHandler(
      #   filename = function() {
      #     return("Micro_gene_filter.svg");
      #   },
      #   content = function(file) {
      #     file.copy(from = paste(basepath,"Plot","microStatistic.svg",sep = "/"),to = file);
      #   }
      # )
      output[[paste(group,'_plot',sep="")]]=renderImage({
        list(src=paste(basepath,"Plot","microStatistic.svg",sep = "/"),width="100%",height="100%")
      },deleteFile = F)
      #qiefen
      
    }
    else{
      gene_filter_choose[group] <<- list(c(number,line))
      validGene=rownames(sect_output_geneinfo[which(sect_output_geneinfo$.group==group),])
      temp_data = sect_output_rna.exp[validGene,colnames(after_slice_rna.exp)]
      validSample = rowSums(temp_data>=number)
      ratio=as.numeric(line)
      xdata = data.frame(SampleRatio=validSample/length(colnames(after_slice_rna.exp)),stringsAsFactors = F)
      ypoint=length(which(xdata$SampleRatio<=ratio))/length(validGene)
      temp.data=data.frame(x=c(0,ratio),xend=c(ratio,ratio),y=c(ypoint,0),yend=c(ypoint,ypoint),stringsAsFactors = F)
      draw_x<-(max(xdata$SampleRatio)+min(xdata$SampleRatio))/2
      number_ori=length(validGene)
      number_after=length(which(xdata$SampleRatio>ratio))
      ypoint =round(ypoint,2)
      svglite(paste(basepath,"/Plot/",group,"Statistic.svg",sep = ""))
      x1 = min(xdata$SampleRatio)+0.2*max(xdata$SampleRatio)+min(xdata$SampleRatio)
      text_to_plot=data.frame(x=c(x1,x1),y=c(0.95,0.90),col=c("blue","blue"),text=c(paste("Original genes:",number_ori),paste("After seg:",number_after)))
      
      xdata = data.frame(SampleRatio=validSample/length(colnames(after_slice_micro.exp)),
                         color=as.character(c(xdata$SampleRatio>ratio)),
                         stringsAsFactors = F
      )
      
      text1=paste("Sample Ratio:",ratio)
      text2=paste("Remain:",number_after)
      
      p=ggplot(xdata,aes(x=SampleRatio,fill=..x..>ratio))+
        geom_histogram(color="black",bins = 100) +
        scale_fill_manual(values=c('FALSE'="white",'TRUE'= "#9b59b6"))+
        geom_vline(aes(xintercept=ratio), colour="#990000", linetype="dashed")
      pp=ggplot_build(p)
      draw_y<-get(x = "range",envir = pp$layout$panel_scales_y[[1]]$range)
      draw_x<-get(x = "range",envir = pp$layout$panel_scales_x[[1]]$range)
      x_pianyi=(draw_x[2]-draw_x[1])*0.2
    
      if(var(xdata$SampleRatio)!=0){
        if(skewness(xdata$SampleRatio)<0){
          text=data.frame(label=c(text1,text2),x=draw_x[1]+x_pianyi,y=c(draw_y[2],draw_y[2]*0.95),stringsAsFactors = F)
        }
        else{
          text=data.frame(label=c(text1,text2),x=draw_x[2]-x_pianyi,y=c(draw_y[2],draw_y[2]*0.95),stringsAsFactors = F)
        }
      }
      else{
        text=data.frame(label=c(text1,text2),x=draw_x[1]+x_pianyi,y=c(draw_y[2],draw_y[2]*0.95),stringsAsFactors = F)
      }
      
      print(p+xlim(draw_x[1]-x_pianyi*5/150, draw_x[2]+x_pianyi*5/150)+
              geom_text(mapping = aes(x = x,y = y,label=label),data=text,size=6,family='serif')+
              labs(title = paste("Group",group,"Genes Filter"))+xlab("Sample Ratio")+ylab('Valid RNA Count')+
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
                    panel.background = element_rect(fill = NA)) +labs(fill = "If Remain")
      )
      
      
      dev.off()
      #file.copy(from = paste(basepath,"/Plot/",group,"Statistic.svg",sep = ""),to = paste('www/templePlot/',group,'Statistic',session$token,'.svg',sep = ""))
      
      if(exist=="F"){
        (paste("#","gene_Group_",group,'_panel',sep=""))
        insertUI(
          selector = paste("#","gene_Group_",group,'_panel',sep=""),
          where='beforeEnd',
          ui=imageOutput(outputId = paste(group,'_plot',sep=""),height = "100%"),
          immediate = T
        )
        # insertUI(
        #   selector = paste("#","gene_Group_",group,'_panel',sep=""),
        #   where='beforeEnd',
        #   ui=div(class="box-footer",
        #          downloadButton(paste(group,'_download',sep=""), "Download"),
        #          tags$button(class = "btn btn-success action-button pull-right shiny-bound-input",onclick=paste("slice_gene('#","gene_Group_",group,"_panel')",sep=""),style="margin:5px",height = "100%",HTML("Filter"))),
        #   immediate = T
        # )
      }
      # output[[paste(group,'_download',sep="")]] <- downloadHandler(
      #   filename = function() {
      #     return(paste(group,'_gene_filter','.svg',sep=""));
      #   },
      #   content = function(file) {
      #     file.copy(from = paste(basepath,"/Plot/",group,"Statistic.svg",sep = ""),to = file);
      #   }
      # )
      output[[paste(group,'_plot',sep="")]]=renderImage({
        list(src= paste(basepath,"/Plot/",group,"Statistic.svg",sep = ""),width="100%",height="100%")
      },deleteFile = F)
    }
  })
  observeEvent(input$Gene_Slice_Signal,{
    # isolate({
    #   msg = input$Gene_Slice_Signal
    #   group = msg$group
    #   group=sub(pattern = "gene_Group_",replacement = "",x = group)
    #   group=sub(pattern = "_panel",replacement = "",x = group)
    #   number=as.numeric(msg$number)
    #   type = msg$type
    #   line = msg$line
    #   line = as.numeric(line)
    # })

    finnal = TRUE
    msg_pre = ""

    if(length(gene_filter_choose)==0){
      sendSweetAlert(session = session,title = "Warning..",text = 'Please click one preview at least!..',type = 'warning')
      
    }else{
    
      for(type in names(gene_filter_choose)){
        number = gene_filter_choose[[type]][1]
        line = gene_filter_choose[[type]][2]
    
        if(type=="micro"){
          output_micro.exp = sect_output_micro.exp[,colnames(after_slice_micro.exp)]
          validGene=rownames(output_micro.exp)
          validSample = rowSums(output_micro.exp>=number)
          xdata = data.frame(SampleRatio=validSample/length(colnames(output_micro.exp)),stringsAsFactors = F)
          intersect_name = rownames(xdata)[which(xdata$SampleRatio>line)]
          ratio = sum(xdata$SampleRatio==line)/length(validGene)
          if(ratio<0.05){
            after_slice_micro.exp<<- output_micro.exp[intersect_name,]
            msg_pre = paste(msg_pre,"<h4>Valid MicroRNA: ",dim(after_slice_micro.exp)[1],"</h4>",sep = "")
            # num1 = length(rownames(after_slice_micro.exp))
            
            #sendSweetAlert(session = session,title = "Success..",text = paste("Filter Success! Valid microRNA Remain:",num1),type = 'success')
            
          }
          else{
            
            sendSweetAlert(session = session,title = "Warning..",text = 'Group micro:Invlid value please choose again',type = 'warning')
            finnal =FALSE
            break
          }
        }
        else{
          #append group gene to after_slice_rna.exp
          validGene = rownames(sect_output_geneinfo[which(sect_output_geneinfo$.group==type),])
          output_rna.exp = sect_output_rna.exp[validGene,colnames(after_slice_rna.exp)]
          
          validSample = rowSums(output_rna.exp>=number)
          xdata = data.frame(SampleRatio=validSample/length(colnames(output_rna.exp)),stringsAsFactors = F)
          intersect_name = rownames(xdata)[which(xdata$SampleRatio>line)]
          ratio = sum(xdata$SampleRatio==line)/length(validGene)
          if(ratio<0.05){
            delete = setdiff(rownames(after_slice_rna.exp),validGene)
            remain = sect_output_rna.exp[intersect_name,colnames(after_slice_rna.exp)]
            after_slice_rna.exp<<-after_slice_rna.exp[delete,]
            after_slice_rna.exp<<-rbind(after_slice_rna.exp,remain)
            msg_pre = paste(msg_pre,"<h4>Valid CeRNA for group ",type,": ",length(intersect_name),"</h4>",sep = "")
           # after_slice_geneinfo<<-sect_output_geneinfo[rownames(after_slice_rna.exp),]
            #num1 = length(rownames(after_slice_rna.exp))
            #sendSweetAlert(session = session,title = "Success..",text = paste("Filter Success! Valid ceRNA Remain:",num1),type = 'success')
          }
          else{
            sendSweetAlert(session = session,title = "Warning..",text = paste("Group ",type,":Invlid value please choose again",sep = ""),type = 'warning')
            finnal = FALSE
            break
          }
        }
      }
      if(finnal){
       
        num1 = length(rownames(after_slice_micro.exp))
        num2 = length(rownames(after_slice_rna.exp))
        after_slice_geneinfo <<- after_slice_geneinfo[rownames(after_slice_rna.exp),]
        #after_slice_geneinfo <<-sect_output_geneinfo[sect_name,]
        msg=HTML(msg_pre)
        sendSweetAlert(session = session,title = "Success..",text = msg,type = 'success',html = T)
        
        ValidNum1 = data.frame(microNum = num1,stringsAsFactors = F);
        ValidNum2 = data.frame(rnaNum = num2,stringsAsFactors = F);
        
        session$sendCustomMessage('Valid_valuebox_micro',ValidNum1);
        session$sendCustomMessage('Valid_valuebox_rna',ValidNum2);
      }else{
        after_slice_micro.exp <<- sect_output_micro.exp[,colnames(after_slice_micro.exp)]
        after_slice_geneinfo <<- sect_output_geneinfo[which(!is.na(sect_output_geneinfo$.group)),]
        after_slice_rna.exp <<- sect_output_rna.exp[rownames(after_slice_geneinfo),]     }
      
    }
    
    #   list(src=normalizePath(paste(basepath,"Plot",'ph1.svg',sep="/")),height="100%",width="100%")    
    # },deleteFile=F)
    # session$sendCustomMessage('clear_construction_task',"")
  })
  output$downloadData_gene <- downloadHandler(
    filename = "Gene_Filter_Plot.zip",
    content = function(file) {
      files=c()
      for(str in names(gene_filter_choose)){
        if(str=="micro"){
          files = c(files,paste(basepath,"Plot","microStatistic.svg",sep = "/"))
        }else{
          files = c(files,paste(basepath,"/Plot/",str,"Statistic.svg",sep = ""))
        }
      }
      zip(zipfile = file,files = files,flags = "-j")
      # file.copy(from = paste(basepath,"plot","Gene_filter.zip",sep = "/"),to = file);
    }
  )

  observeEvent(input$ceRNA_Transform_Signal,{
    isolate({
      msg = input$ceRNA_Transform_Signal
      log_trans=msg$log_trans
      norm_trans=msg$norm_trans
    })
    after_slice_rna.exp <<- sect_output_rna.exp[rownames(after_slice_rna.exp),colnames(after_slice_rna.exp)]
    action_min=function(x){
      (x-min(x))/(max(x)-min(x))
    }
    action_zero=function(x){
      (x-mean(x))/sd(x)
    }
    if(log_trans=="log2"){
      after_slice_rna.exp <<- log2(after_slice_rna.exp+1)
    }
    else if(log_trans=="log"){
      after_slice_rna.exp <<- log(after_slice_rna.exp+1)
    }
    else if(log_trans=="log10"){
      after_slice_rna.exp <<- log10(after_slice_rna.exp+1)
    }
    if(norm_trans=="Min_Max_scaling"){
      after_slice_rna.exp <<- t(apply(after_slice_rna.exp, 1, action_min))
    }
    else if(norm_trans=="Zero_Mean_normalization"){
      after_slice_rna.exp <<- t(apply(after_slice_rna.exp, 1, action_zero))
    }else if(norm_trans=="Custom_input"){
      source(file = paste(basepath,"/code/cerna_f.txt",sep = ""),local = environment())
      after_slice_rna.exp <<- ce_action_custom(after_slice_rna.exp)
    }
    removeUI(selector = "#ceRNA_handson_id>div",immediate = T)
    insertUI(selector = "#ceRNA_handson_id",where = 'beforeEnd',ui = rHandsontableOutput(outputId = "ceRNA_aftertrans_data_show"),immediate = T)
    output$ceRNA_aftertrans_data_show=renderRHandsontable({
      rownum=dim(after_slice_rna.exp)[1]
      colnum=dim(after_slice_rna.exp)[2]
      if(rownum>24){
        rownum=24
      }
      if(colnum>12){
        colnum=12
      }
      rhandsontable(after_slice_rna.exp[1:rownum,1:colnum]) %>%
        hot_col(col = seq(1,colnum),halign = "htCenter")
    })
  })
  observeEvent(input$Cancel_ceRNA_data_show,{
    removeUI(selector = "#ceRNA_handson_id>div",immediate = T)
    after_slice_rna.exp <<- sect_output_rna.exp[rownames(after_slice_rna.exp),colnames(after_slice_rna.exp)]
    sendSweetAlert(session = session,title = "Success..",text = "Cancel Successfully",type = 'success')
  })
  observeEvent(input$ceRNA_Norm_signal_custom,{
    removeUI(selector = '#modalbody>',multiple = T,immediate = T)
    insertUI(selector = '#modalbody',where = 'beforeEnd',immediate = T,
             ui=div(class='row',
                  div(class="col-lg-12",
                    div(class="alert alert-info alert-dismissible",
                        h4(tags$i(class="icon fa fa-check",HTML("Alert!"))
                        ),
                        h4(HTML("Please provide a function, whose input is a <i>gene*sample</i> data frame and output is the transformed input."),style="font-size:16px")
                    )
                  ),
                  div(class='col-lg-6',
                      textAreaInput(inputId = 'ceRna_norm_funcion_input',label = 'New Condition Function',rows = 20,placeholder = 'Please paste the calculate function of the new condition...',width='130%',resize='both')
                  ),
                  div(class='col-lg-6',
                      tags$label(class="control-label",HTML("Example")),
                      verbatimTextOutput("placeholder", placeholder = TRUE)
                  )
            )
    )
    example_input = 'function(exp){
    action_min = function(x){
      (x-min(x))/(max(x)-min(x))
    }
    exp_trans = t(apply(exp, 1, action_min))
    return (exp_trans)
}'
    output$placeholder <- renderText({ example_input })
    session$sendCustomMessage('ceRNA_Norm_signal_custom_insert',"success")
  })
  observeEvent(input$microRNA_Norm_signal_custom,{
    removeUI(selector = '#modalbody>',multiple = T,immediate = T)
    insertUI(selector = '#modalbody',where = 'beforeEnd',immediate = T,
             ui=div(class='row',
                    div(class="col-lg-12",
                        div(class="alert alert-info alert-dismissible",
                            h4(tags$i(class="icon fa fa-check",HTML("Alert!"))
                            ),
                            h4(HTML("Please provide a function, whose input is a <i>gene*sample</i> data frame and output is the transformed input."),style="font-size:16px")
                        )
                    ),
                    div(class='col-lg-6',
                        textAreaInput(inputId = 'ceRna_norm_funcion_input',label = 'New Condition Function',rows = 20,placeholder = 'Please paste the calculate function of the new condition...',width='130%',resize='both')
                    ),
                    div(class='col-lg-6',
                        tags$label(class="control-label",HTML("Example")),
                        verbatimTextOutput("placeholder_micro", placeholder = TRUE)
                    )
             )
    )
    example_input = 'function(exp){
    action_min = function(x){
      (x-min(x))/(max(x)-min(x))
    }
    exp_trans = t(apply(exp, 1, action_min))
    return (exp_trans)
}'
    output$placeholder_micro <- renderText({ example_input })
    session$sendCustomMessage('microRNA_Norm_signal_custom_insert',"success")
  })
  observeEvent(input$ceRNA_Norm_signal_custom_insert_ok,{
    isolate({
      custom_func = input$ceRna_norm_funcion_input
    })
    if(R.oo::equals(custom_func,"")){
      session$sendCustomMessage('ceRNA_Norm_signal_custom_sig',"fail")
    }else{
      custom_func = paste("ce_action_custom = ",custom_func,sep = "")
      write(x = custom_func,file =paste(basepath,"/code/cerna_f.txt",sep = ""))
      session$sendCustomMessage('ceRNA_Norm_signal_custom_sig',"success")
    }
  })
  observeEvent(input$microRNA_Norm_signal_custom_insert_ok,{
    isolate({
      custom_func = input$ceRna_norm_funcion_input
    })
    if(R.oo::equals(custom_func,"")){
      session$sendCustomMessage('microRNA_Norm_signal_custom_sig',"fail")
    }else{
      custom_func = paste("micro_action_custom = ",custom_func,sep = "")
      write(x = custom_func,file =paste(basepath,"/code/micro_f.txt",sep = ""))
      session$sendCustomMessage('microRNA_Norm_signal_custom_sig',"success")
    }
  })
  observeEvent(input$microRNA_Transform_Signal,{
    isolate({
      msg = input$microRNA_Transform_Signal
      log_trans=msg$log_trans
      norm_trans=msg$norm_trans
    })
    after_slice_micro.exp <<- sect_output_micro.exp[rownames(after_slice_micro.exp),colnames(after_slice_micro.exp)]
    action_min=function(x){
      (x-min(x))/(max(x)-min(x))
    }
    action_zero=function(x){
      (x-mean(x))/sd(x)
    }
    if(log_trans=="log2"){
      after_slice_micro.exp <<- log2(after_slice_micro.exp+1)
    }
    else if(log_trans=="log"){
      after_slice_micro.exp <<- log(after_slice_micro.exp+1)
    }
    else if(log_trans=="log10"){
      after_slice_micro.exp <<- log10(after_slice_micro.exp+1)
    }
    if(norm_trans=="Min_Max_scaling"){
      after_slice_micro.exp <<- t(apply(after_slice_micro.exp, 1, action_min))
    }
    else if(norm_trans=="Zero_Mean_normalization"){
      after_slice_micro.exp <<- t(apply(after_slice_micro.exp, 1, action_zero))
    }else if(norm_trans=="Custom_input"){
      source(file = paste(basepath,"/code/micro_f.txt",sep = ""),local = environment())
      after_slice_micro.exp <<- micro_action_custom(after_slice_micro.exp)
    }
    removeUI(selector = "#microRNA_handson_id>div",immediate = T)
    insertUI(selector = "#microRNA_handson_id",where = 'beforeEnd',ui = rHandsontableOutput(outputId = "microRNA_aftertrans_data_show"),immediate = T)
    output$microRNA_aftertrans_data_show=renderRHandsontable({
      rownum=dim(after_slice_micro.exp)[1]
      colnum=dim(after_slice_micro.exp)[2]
      if(rownum>24){
        rownum=24
      }
      if(colnum>12){
        colnum=12
      }
      rhandsontable(after_slice_micro.exp[1:rownum,1:colnum])
    })
  })
  observeEvent(input$Cancel_microRNA_data_show,{
    removeUI(selector = "#microRNA_handson_id>div",immediate = T)
    after_slice_micro.exp <<- sect_output_micro.exp[rownames(after_slice_micro.exp),colnames(after_slice_micro.exp)]
    sendSweetAlert(session = session,title = "Success..",text = "Cancel Successfully",type = 'success')
  })
  #########Construction Page Action########
  observeEvent(input$construction_data_confirm,{
    if(R.oo::equals(after_slice_rna.exp,"")){
      sendSweetAlert(session = session,title = "Error...",text = "Please do this step after the step2",type = 'error')
    }else{
      samples=intersect(colnames(after_slice_rna.exp),colnames(after_slice_micro.exp))
      gene=intersect(rownames(after_slice_rna.exp),rownames(after_slice_geneinfo))
      after_slice_geneinfo<<-after_slice_geneinfo[gene,]
      after_slice_rna.exp<<-after_slice_rna.exp[gene,samples]
      after_slice_micro.exp<<-after_slice_micro.exp[,samples]
    }
  })
  observeEvent(input$add_new_condition,{
    isolate({
      msg=input$add_new_condition
      core=input$use_core
    })
    if(R.oo::equals(after_slice_geneinfo,"")){
      sendSweetAlert(session = session,title = "Error...",text = "No genetic data here!..Check the previous steps",type = 'error')
      return()
    }
    if(dim(after_slice_geneinfo)[1]==0){
      sendSweetAlert(session = session,title = "Error...",text = "No genetic data here!..Check the previous steps",type = 'error')
      return()
    }
    choice=c(condition[which(!condition$used),'abbr'],'custom')
    if(length(choice)>1)
      names(choice)=c(paste(condition[which(!condition$used),'description'],'(',condition[which(!condition$used),'abbr'],')',sep=""),'Custom')
    else
      names(choice)='Custom'
    
    if(all(is.na(after_slice_geneinfo$.group)))
    {
      after_slice_geneinfo$.group<<-'Default'
      sendSweetAlert(session = session,title = "Warning",text = 'Group All Genes in Defaut',type = 'warning')
    }
    
    groupstaistic=as.data.frame(table(after_slice_geneinfo$.group),stringsAsFactors = F)
    rownames(groupstaistic)=groupstaistic$Var1
    .group=sort(groupstaistic$Var1)
    groupstaistic=groupstaistic[.group,]
    pairs=data.frame(v1=rep(.group,each=length(.group)),v2=rep(.group,times=length(.group)),stringsAsFactors = F)
    pairs=pairs[which(pairs$v1<=pairs$v2),]
    #pairs=data.frame(v1=rep(groupstaistic$Var1,times=dim(groupstaistic)[1]),v2=rep(groupstaistic$Var1,each=dim(groupstaistic)[1]),stringsAsFactors = F)
    #pairs=unique(t(apply(X = pairs,MARGIN = 1,FUN = sort)))
    show=paste(pairs[,1],'(',groupstaistic[pairs[,1],'Freq'],') vs ',pairs[,2],'(',groupstaistic[pairs[,2],'Freq'],')',sep="")
    values=paste(pairs[,1],"---",pairs[,2],sep="")
    show=c('All',show)
    values=c('all',values)
    cores=seq(0,validcore-sum(condition$core))
    
    if(length(msg)>1)
    {
      choice=msg$type
      cores=seq(0,validcore-sum(condition$core)+condition[msg$type,'core'])
      type=msg$type
      tasks=msg$tasks
    }
    else
    {
      type=choice[1]
      core=cores[1]
      tasks='all'
    }
    
    removeUI(selector = '#modalbody>',multiple = T,immediate = T)
    insertUI(selector = '#modalbody',where = 'beforeEnd',immediate = T,
             ui=div(
               div(class='row',
                   div(class='col-lg-6',
                       selectInput(inputId = 'condition_type',label = 'Choose New Measurement',choices = choice,multiple = F,selected = type)
                   ),
                   div(class='col-lg-6',
                       selectInput(inputId = 'use_core',label = 'Choose Parallel Cores',choices = cores ,multiple = F,selected = as.character(core))
                   )
               ),
               conditionalPanel(condition = "input.condition_type=='MI'||input.condition_type=='CMI'",
                                div(class="row",
                                    div(class="col-lg-4",
                                        pickerInput(inputId = "mi_disc_method",label = "Discretization Method",choices = c("Equal Frequencie"="equalfreq","Equal Width Binning"="equalwidth","Global Equal Width Binning"="globalequalwidth"))
                                    ),
                                    div(class="col-lg-4",
                                        numericInput(inputId = "mi_nbins",label = "Number Of Bins (Default: #sample^(1/3))",value =floor(ncol(after_slice_rna.exp)^(1/3)),min = 2,max = ncol(after_slice_rna.exp),width = "100%")
                                    ),
                                    div(class="col-lg-4",
                                        pickerInput(inputId = "mi_est_method",label = "Entropy Estimator",choices = c("Empirical Probability Distribution"="emp","Miller-Madow Asymptotic Bias Corrected Empirical Estimator"="mm","Shrinkage Estimate of a Dirichlet Probability Distribution"="shrink","Schurmann-Grassberger Estimate"="sg"))
                                    )
                                )
               ),
               div(class='row',
                   div(class="col-lg-12",
                       multiInput(inputId = 'group_pairs',label = 'Group Pairs',choiceNames = show,choiceValues = values,selected = tasks,width = "100%")
                   )
               ),
               conditionalPanel(condition = 'input.condition_type=="custom"',
                                hr(),
                                div(class='row',
                                    div(class='col-lg-3 col-xs-12',
                                        textInput(inputId = 'custom_condition_description',label = 'New Condition Full Name')
                                    ),
                                    div(class='col-lg-3 col-xs-12',
                                        textInput(inputId = 'custom_condition_abbr',label = 'New Condition Abbreviation')
                                    ),
                                    # ),
                                    # div(class="row",
                                    div(class='col-lg-6 col-xs-12',
                                        div(class='form-group',
                                            tags$label(HTML('Available Variables')),
                                            tags$ul(class='form-control',style="border-color:#fff;padding:0px",
                                                    tags$li(tags$i(class='fa fa-tag text-light-blue'),HTML('rna.exp'),style="display:inline-block;padding-left:0px;padding-right:5px"),
                                                    tags$li(tags$i(class='fa fa-tag text-light-blue'),HTML('micro.exp'),style="display:inline-block;padding-left:0px;padding-right:5px"),
                                                    tags$li(tags$i(class='fa fa-tag text-light-blue'),HTML('target'),style="display:inline-block;padding-left:0px;padding-right:5px")
                                            )
                                        )
                                    )
                                ),
                                div(class='row',
                                    div(class='col-lg-12',
                                        div(class='col-lg-6',
                                            textAreaInput(inputId = 'custom_condition_code',label = 'New Condition Function',rows = 20,placeholder = 'Please paste the calculate function of the new condition...',width='130%',resize='both')
                                        ),
                                        div(class='col-lg-6',
                                            tags$label(class="control-label",HTML("Example")),
                                            verbatimTextOutput("placeholder_cus", placeholder = TRUE)
                                        )
                                    )
                                )
               )
             )
    )
    example_input = 'MS=function(g1,g2)
{
  allset=colnames(target)
  set1=allset[target[g1,]==1];
  set2=allset[target[g2,]==1];
  x=length(intersect(set1,set2));
  m=length(set2);
  n=length(setdiff(allset,set2));
  k=length(set1);
  pvalue=1-phyper(x-1,m,n,k);
  return(pvalue)
}'
    output$placeholder_cus <- renderText({ example_input })
    session$sendCustomMessage('conditions',condition)
  })
  observeEvent(input$choose_new_condition,{
    isolate({
      msg=input$choose_new_condition
      core=as.numeric(msg$core)
      tasks=msg$tasks
      tasks=paste(unlist(tasks),collapse = ";")
      type=msg$type
      description=msg$description
      abbr=msg$abbr
      code=msg$code
    })
    if(type=='custom')
    {
      condition<<-rbind(condition,data.frame(description=description,abbr=abbr,used=T,core=core,task=tasks,others="",stringsAsFactors = F,row.names = abbr))
      #rownames(condition)<<condition$abbr
      write(x = code,file = paste(basepath,"/code/",abbr,'.R',sep=""))
      #thresh<<-rbind(thresh,data.frame(type=condition$abbr,task=tasks,direction="<",thresh=0,stringsAsFactors = F))
    }
    
    else
    {
      condition[type,'used']<<-T
      condition[type,'core']<<-core
      condition[type,'task']<<-tasks
      if(type=="CMI"||type=="MI")
      {
        isolate({
          disc_method=input$mi_disc_method
          nbin=input$mi_nbins
          est=input$mi_est_method
        })
        condition[type,'others']<<-gsub(pattern = "\"",replacement = "\\\\\"",x = toJSON(x = list(disc=disc_method,nbin=nbin,est=est),auto_unbox = T))
      }
      #thresh<<-rbind(thresh,data.frame(type=condition$abbr,task=tasks,direction="<",thresh=0,stringsAsFactors = F))
    }
  })
  observeEvent(input$remove_condition,{
    isolate({
      msg=input$remove_condition
    })
    condition[msg$type,'used']<<-F
    condition[msg$type,'core']<<-0
    condition[msg$type,'others']<<-""
    thresh<<-thresh[thresh$type!=msg$type,]
    removeUI(selector = paste("div.col-lg-12 > #density_plot_",msg$type,sep=""),immediate = T)
  })
  observeEvent(input$compute_condition,{
    isolate({
      type=input$compute_condition$type
    })
    core=condition[type,'core']
    tasks=condition[type,'task']
    logpath=normalizePath(paste(basepath,'/log/',type,'.txt',sep=""))
    if(file.exists(logpath))
    {
      file.remove(logpath)
    }
    if(type=="PCC")
    {
      if(dir.exists(paths = normalizePath(paste(basepath,'/log/',sep=""))))
      {
        dir.create(path = normalizePath(paste(basepath,'/log/',sep="")),recursive = T)
      }
      session$sendCustomMessage('calculation_eta',list(type=type,task="all",msg="Data Prepare",status='run'))
      filepath=paste(basepath,"/data/rna.exp.RData",sep="")
      saveRDS(file=filepath,object=after_slice_rna.exp)
      #system(paste("www/Program/COR.exe",filepath,basepath,"all",sep=" "),wait = F)
      scriptpath="www/Program/PCC.R"
      resultpath=paste(basepath,'/all.cor.RData',sep="")
      system(paste("Rscript",scriptpath,filepath,logpath,resultpath),wait = F)

    }
    else
    {
      if(dir.exists(paths = paste(basepath,'/log/')))
      {
        dir.create(paths = paste(basepath,'/log/'),recursive = T)
      }
      file.create(logpath)
      session$sendCustomMessage('calculation_eta',list(type=type,task="all",msg="Data Prepare",status='run'))
      datapath=paste(basepath,"/data/tmpdatas.RData",sep="")
      scriptpath="www/Program/ComputeCondition.R"
      codepath=""
      resultpath=paste(basepath,'/',type,'.RData',sep="")
      if(file.exists(paste(basepath,'/code/',type,'.R',sep="")))
      {
        codepath=paste(basepath,'/code/',type,'.R',sep="")
      }
      else if(file.exists(paste('www/Program/',type,'.R',sep="")))
      {
        codepath=paste('www/Program/',type,'.R',sep="")
      }
      else
      {
        sendSweetAlert(session = session,title = "Error..",text = "No Code",type = 'error')
      }

      rna.exp=after_slice_rna.exp
      micro.exp=after_slice_micro.exp
      target=sect_output_target[rownames(rna.exp),rownames(micro.exp)]
      geneinfo=after_slice_geneinfo
      save(rna.exp,micro.exp,target,geneinfo,file = datapath)
      if(condition[type,'others']=="")
      {
        system(paste("Rscript",scriptpath,datapath,codepath,type,core,logpath,tasks,resultpath),wait = F)
      }
      else
      {
        system(paste("Rscript",scriptpath,datapath,codepath,type,core,logpath,tasks,resultpath,condition[type,'others']),wait = F)
      }
    }
  })
  observeEvent(input$compute_status,{
    isolate({
      msg=input$compute_status
      type=msg$type
    })
    time=function(s)
    {
      s=floor(s)
      out=""
      if(s>=86400)
      {
        out=paste0(out,floor(s/86400),'d')
        s=s%%86400
      }
      if(s>=3600)
      {
        out=paste0(out,floor(s/3600),'h')
        s=s%%3600
      }
      if(s>=60)
      {
        out=paste0(out,floor(s/60),'m')
        s=s%%60
      }
      out=paste0(out,s,'s')
      return(out)
    }
    print(paste("Check",type,'Status...'))
    logpath=paste(basepath,'/log/',type,'.txt',sep="")
    if(file.exists(logpath))
    {
      tasks=unlist(strsplit(x = condition[type,'task'],split = ";"))
      if(type=="PCC")
      {
        content=readLines(logpath)
        lastline=content[length(content)]
        progress=min(length(content),3)/3*100
        if(grepl(pattern = "^All Finish.$",x = lastline))
        {
          session$sendCustomMessage('calculation_eta',
                                    list(type=type,msg=lastline,status='stop',progress=paste(100,"%",sep=""),complete=paste(length(tasks),"/",length(tasks),sep="")))
        }
        else
        {
          session$sendCustomMessage('calculation_eta',list(type=type,msg=lastline,status='run',progress=paste(progress,"%",sep=""),complete=paste(0,"/",length(tasks),sep="")))
        }
      }
      else
      {
        content=readLines(logpath)
        indexes=which(grepl(pattern = "^\\[\\{\"task",x = content))
        if(length(indexes)>0)
        {
          endtime=as.numeric(Sys.time())
          index=max(indexes)
          info=fromJSON(content[index])
          complete=nchar(content[index+1])#完成???
          if(is.na(complete))
            complete=1
          eta=(endtime-info$time)/complete*(info$total-complete)#预计时间
          finish.task=length(which(grepl(pattern = "^Finish",x = content)))#总完成任务数
          status="run"
          msg=paste("Running:",info$task,"&nbsp;&nbsp;&nbsp;&nbsp;ETA:",time(eta))
          progress=format(x = complete/info$total*100,nsmall=2)
          if(length(which(grepl(pattern = "^All Finish.$",x = content)))>0)
          {
            msg="All Finish."
            status='stop'
            progress=100
          }
          session$sendCustomMessage('calculation_eta',
                                    list(type=type,msg=msg,progress=paste(progress,"%",sep=""),status=status,complete=paste(finish.task,"/",length(tasks),sep="")))
        }
      }
    }
    else
    {
      session$sendCustomMessage('calculation_eta',list(type=type,msg="",status='run'))
    }
  })
  observeEvent(input$condition_filter_response,{
    isolate({
      type=input$condition_filter_response$type
      tasks=input$condition_filter_response$tasks
    })
    removeUI(selector = paste("div.col-lg-12 > #density_plot_",type,sep=""),immediate = T)
    insertUI(selector = "#condition_preview",where = 'beforeEnd',
             ui =filter_box(type,tasks),
             immediate = T
    )
  })
  observeEvent(input$condition_finish,{
    isolate({
      type=input$condition_finish$type
    })
    tasks=condition[type,'task']
    tasks=unlist(strsplit(x = tasks,split = ";"))
    draw_density(basepath,output,session,type,tasks)
    condition[type,'core']<<-0
  })
  observeEvent(input$update_condition_thresh,{
    isolate({
      msg=input$update_condition_thresh
      direction=input[[paste("direction",msg$type,msg$task,sep="_")]]
      type=msg$type
      task=msg$task
      value=msg$value
    })
    session$sendCustomMessage('distribution_plot',list(status='update',value="Updating Plot...",id=paste("density_plot",type,task,"progress",sep="_")))
    data=readData(type,task)
    data=data[[type]][[task]]
    condition_density_plot(basepath = basepath,data=data,type = type,task = task,value = value,direction = direction)
    output[[paste("density_plot",msg$type,msg$task,"image",sep="_")]]=renderImage({
      figurepath=paste(basepath,'/Plot/density_plot_',msg$type,"_",msg$task,".svg",sep="")
      list(src=figurepath,width="100%",height="100%")
    },deleteFile = F)
    session$sendCustomMessage('distribution_plot',list(status='finish',value="",id=paste("density_plot",type,task,"progress",sep="_")))
    
  })
  observeEvent(input$add_condition_thresh,{
    isolate({
      msg=input$add_condition_thresh
      newthresh=msg$thresh
      type=msg$type
    })
    if(length(newthresh[[1]])==0)
    {
      sendSweetAlert(session = session,title = "Warning...",text = "Please Wait until Computation Finish...",type = 'warning',html = T)
      return()
    }
    thresh<<-thresh[thresh$type!=type,]
    for(name in names(newthresh))
    {
      thresh<<-rbind(thresh,data.frame(type=type,task=name,direction=newthresh[[name]][['direction']],thresh=as.numeric(newthresh[[name]][['thresh']]),stringsAsFactors = F))
    }
    msg="Add Thresh Successfully"
    sendSweetAlert(session = session,title = "Success...",text = msg,type = 'success',html = T)
  })
  observeEvent(input$construct_network,{
    # isolate({
    #   msg=input$construct_network
    #   newthresh=msg$thresh
    #   type=msg$type
    # })
    if(empty(thresh))
    {
      sendSweetAlert(session = session,title = 'Error...',text = "No Condition Setting! Plsease Set Conditions First...",type = "error")
      return()
    }
    removeUI(selector = "#modalbody>",immediate = T)
    insertUI(selector = "#modalbody",where = 'beforeEnd',ui = create_progress("",id="network_construction_progress"),immediate = T)
    session$sendCustomMessage('network_construction',list(status='update',value="Initializing Network...",id="network_construction_progress"))
    
    
    # thresh<<-thresh[thresh$type!=type,]
    # for(name in names(newthresh))
    # {
    #   thresh<<-rbind(thresh,data.frame(type=type,task=name,direction=newthresh[[name]][['direction']],thresh=as.numeric(newthresh[[name]][['thresh']]),stringsAsFactors = F))
    # }
    network_construnction(after_slice_geneinfo)
    session$sendCustomMessage('network_construction',list(status='update',value="Network Summarizing...",id="network_construction"))
    removeUI(selector = "#network_summary>",multiple = T,immediate = T)
    insertUI(selector = "#network_summary",where = "beforeEnd",ui = valueBox(value = sum(igraph::degree(net_igraph)!=0),subtitle = "Connected Nodes",icon = icon("eye-open",lib = "glyphicon"),color = "green",width = 3),immediate = T)
    insertUI(selector = "#network_summary",where = "beforeEnd",ui = valueBox(value = sum(igraph::degree(net_igraph)==0),subtitle = "Isolated Nodes",icon = icon("eye-close",lib = "glyphicon"),color = "red",width = 3),immediate = T)
    insertUI(selector = "#network_summary",where = "beforeEnd",ui = valueBox(value = length(E(net_igraph)),subtitle = "Edges",icon = icon("link",lib = "font-awesome"),color = "orange",width = 3),immediate = T)
    insertUI(selector = "#network_summary",where = "beforeEnd",ui = valueBox(value = sum(igraph::components(net_igraph)$csize>1),subtitle = "Components",icon = icon("connectdevelop",lib = "font-awesome"),color = "maroon",width = 3),immediate = T)
    session$sendCustomMessage('network_construction',list(status='finish',value="",id="network_construction"))
    sendSweetAlert(session = session,title = "Success",text = "Apply Conditions Successfully!",type = 'success')
  })
  observeEvent(input$cancel_condition_thresh,{
    isolate({
      msg=input$cancel_condition_thresh
      type=msg$type
    })
    thresh<<-thresh[thresh$type!=type,]
    msg1="Remove Thresh Successfully"
    sendSweetAlert(session = session,title = "Success...",text = msg1,type = 'success',html = T)
  })
  output$export_condition_value=downloadHandler(
    filename="Condition_values.RData",
    content=function(file){
      types=condition$abbr[which(condition$used)]
      data=list()
      for(type in types)
      {
        tasks=unlist(strsplit(x = condition[type,'task'],split = ";"))
        tmp=readData(type,tasks)
        data=c(data,tmp)
      }
      saveRDS(object = data,file = file)
    }
  )
  output$export_condition_plot=downloadHandler(
    filename="Condition_Plots.zip",
    content=function(file){
      types=condition$abbr[which(condition$used)]
      files=c()
      for(type in types)
      {
        tasks=unlist(strsplit(x = condition[type,'task'],split = ";"))
        files=c(files,paste(basepath,'/Plot/density_plot_',paste(type,tasks,sep="_"),'.svg',sep=""))
      }
      zip(zipfile = file,files = files,flags = '-j')
    }
  )
  output$network_export <- downloadHandler(
    filename = function() {
      return("network.txt")
    },
    content = function(file) {
      if(nrow(edgeinfo)==0)
      {
        write(x = "No Network Exist",file = file)
        sendSweetAlert(session = session,title = "Error",text = "No network exists!",type = 'error')
      }
      else
      {
        write.table(x=edgeinfo,file = file, quote = F,sep = "\t",row.names = F,col.names = T)
      }
    }
  )
  ##########Visualization Page Action############
  observeEvent(input$network,{
    isolate({
      msg=input$network
      do_what =msg$do_what
    })

    if((dim(edgeinfo)[1]==0)){
      sendSweetAlert(session = session,title = "Error",text = "Please do this step after the step2 and step3",type = 'error')
    }else{
      if(do_what=="layout"){
       
        type=msg$type
        visual_layout<<-type
        nodes=unique(c(edgeinfo[,1],edgeinfo[,2]))
        num=which(colnames(after_slice_geneinfo)==".group")
        edge = edgeinfo[,1:2]
        colnames(edge)=c('source','target')
        # edge=as.data.frame(which(network==1,arr.ind = T))
        # edge[,1]=rownames(network)[edge[,1]]
        # edge[,2]=colnames(network)[edge[,2]]
        # nodes=unique(c(edge[,1],edge[,2]))
        # colnames(edge)=c('source','target')
        # num=which(colnames(after_slice_geneinfo)==".group")
        # new_after_geneinfo = after_slice_geneinfo
        # colnames(new_after_geneinfo)[num]="group"
        new_after_geneinfo = after_slice_geneinfo
        colnames(new_after_geneinfo)[num]="group"
        nodes=data.frame(id=nodes,new_after_geneinfo[nodes,],stringsAsFactors = F)
        node=tibble(group="nodes",data=apply(X = nodes,MARGIN = 1,as.list))
        edge=tibble(group="edges",data=apply(X = edge,MARGIN = 1,FUN = as.list))
        session$sendCustomMessage('network_construction',list(status='update',value="Initializing Network...",id="network_construction_progress"))
        session$sendCustomMessage('network',toJSON(list(nodes=node,edge=edge,type=type,do_what=do_what),auto_unbox = T))
      }
    }
  })
  observeEvent(input$Network_con_finish,{
    
    session$sendCustomMessage('network_construction',list(status='finish',value="",id="Construction_finish"))
    
  })
  observeEvent(input$change_network_name,{
    
    session$sendCustomMessage('Gene_info_name_change',colnames(after_slice_geneinfo))
  
  })
  observeEvent(input$net_color_shape,{
    isolate({
      msg=input$net_color_shape
      type =msg$type
      func = msg$func;
    })
    if(func=="color"){
      if(type=="group"){
          type='.group'
      }
      if(type == "All_node"){
        vec = "All_node"
        session$sendCustomMessage('Gene_network_color_change',data.frame(type=vec,stringsAsFactors = F))
        return()
      }
      vec = after_slice_geneinfo[,type]
      #vec = vec[[1]]
      vec = unique(vec)
     
      if(length(vec)>typeLimit){
          sendSweetAlert(session = session,title = "Error",text = "Too Many Candidates",type = 'error')
      }else{
          session$sendCustomMessage('Gene_network_color_change',data.frame(type=vec,stringsAsFactors = F))
      }
    }
    if(func=="shape"){
      if(type=="group"){
        type = ".group"
      }
      if(type == "All_node"){
        vec = "All_node"
        session$sendCustomMessage('Gene_network_shape_change',data.frame(type=vec,stringsAsFactors = F))
        return()
      }
      vec = after_slice_geneinfo[,type]
      vec = unique(vec)
      if(length(vec)>typeLimit){
        sendSweetAlert(session = session,title = "Error",text = "Too Many Candidates",type = 'error')
      }else{
        session$sendCustomMessage('Gene_network_shape_change',data.frame(type=vec,stringsAsFactors = F))
      }
    }
  })
  
  ##########Analysis Page Action###############
  observeEvent(input$nodeCentrality,{
    isolate({
      msg=input$nodeCentrality
      centrality=unlist(msg$value)
    })
   
    if(R.oo::equals(net_igraph,"")){
      sendSweetAlert(session = session,title = "Error",text = "Please complete step 3 first",type = 'error')
    }else{
      deleted=setdiff(node_property,centrality)
      deleted=sub(pattern = " ",replacement = "_",deleted)
      removeUI(selector = paste("#node_",deleted,sep=""),multiple = T,immediate = T)
      newadd=setdiff(centrality,node_property)
      node_property<<-centrality
      if(R.oo::equals(nodeNewInfo,""))
      {
        nodeNewInfo<<-data.frame(.id=rownames(after_slice_geneinfo),stringsAsFactors = F,row.names = rownames(after_slice_geneinfo))
      }
      
      for(id in newadd)
      {
       
        ui=create_property_box('node',id)
        insertUI(selector = "#network_property",where = 'beforeEnd',ui = ui,
                 immediate = T)
        
        if(id=="Degree")
        {
          degree=as.data.frame(igraph::degree(net_igraph))
          nodeNewInfo$Degree<<-""
          nodeNewInfo[rownames(degree),'Degree']<<-degree[,1]
          data=as.data.frame(table(degree[,1]),stringsAsFactors = F)
          data$Var1=as.numeric(data$Var1)
          data=data[which(data$Var1!=0),]
          p=ggplot(data = data,aes(x = Var1,ymax=Freq,ymin=0,y=Freq))+
            geom_linerange(linetype='dashed')+
            geom_point(size=3)+scale_x_log10()+scale_y_log10()+geom_smooth(method = lm)+
            labs(title = "Degree Distribution")+xlab(label = "Degree")+ylab("Node Count")+
            theme(axis.title = element_text(family = "serif"),axis.text = element_text(family = "serif",colour = "black", vjust = 0.25), 
                  axis.text.x = element_text(family = "serif",colour = "black"), 
                  axis.text.y = element_text(family = "serif",colour = "black"), 
                  plot.title = element_text(family = "serif", hjust = 0.5,size=14),
                  panel.background = element_rect(fill = NA),legend.position = 'none',
                  plot.subtitle = element_text(family = "serif",size = 12, colour = "black", hjust = 0.5,vjust = 1))
          pp=ggplot_build(p)
          axis_y<-get(x = "range",envir = pp$layout$panel_scales_y[[1]]$range)
          axis_x<-get(x = "range",envir = pp$layout$panel_scales_x[[1]]$range)
          x_pianyi=(axis_x[2]-axis_x[1])*0.2
          model=lm(formula = log(Freq)~log(Var1),data = data)
          R.square=round(summary(model)[["r.squared"]],digits = 3)
          text=data.frame(label=paste0("R-square=",R.square),x=10^axis_x[2]*0.7,y=10^axis_y[2]*0.8,stringsAsFactors = F)
          p=p+geom_text(mapping = aes(x = x,y = y,label=label),data = text,inherit.aes = F,size=6,family='serif',fontface='bold')
          svglite(paste(basepath,"Plot",'node_degree.svg',sep="/"))
          print(p)
          dev.off()
          output$node_Degree_plot=renderImage({
            list(src=normalizePath(paste(basepath,"Plot",'node_degree.svg',sep="/")),height="100%",width="100%")
          },deleteFile=F)
        }
        else if(id=="Betweenness")
        {
          betweenness=betweenness(net_igraph,directed = F)
          nodeNewInfo$Betweenness<<-""
          nodeNewInfo[names(betweenness),'Betweenness']<<-betweenness
          density=density(x = betweenness,from = min(betweenness,na.rm = T),to = max(betweenness,na.rm = T),na.rm = T)
          density=data.frame(x=density$x,y=density$y)
          p=ggplot(data = density)+geom_line(mapping = aes(x = x,y = y),size=1.5)+
            labs(title = "Betweenness Distribution")+xlab(label = "Betweenness")+ylab("Density")+
            theme(axis.title = element_text(family = "serif"),axis.text = element_text(family = "serif",colour = "black", vjust = 0.25), 
                  axis.text.x = element_text(family = "serif",colour = "black"), 
                  axis.text.y = element_text(family = "serif",colour = "black"), 
                  plot.title = element_text(family = "serif", hjust = 0.5,size=14),
                  panel.background = element_rect(fill = NA),legend.position = 'none',
                  plot.subtitle = element_text(family = "serif",size = 12, colour = "black", hjust = 0.5,vjust = 1))
          svglite(paste(basepath,"Plot",'node_betweenness.svg',sep="/"))
          print(p)
          dev.off()
          output$node_Betweenness_plot=renderImage({
            list(src=normalizePath(paste(basepath,"Plot",'node_betweenness.svg',sep="/")),height="100%",width="100%")
          },deleteFile=F)
        }
        else if(id=="Closeness")
        {
          closeness=closeness(net_igraph,mode = 'all')
          nodeNewInfo$Closeness<<-""
          nodeNewInfo[names(closeness),'Closeness']<<-closeness
          density=density(x = closeness,from = min(closeness,na.rm = T),to = max(closeness,na.rm = T),na.rm = T)
          density=data.frame(x=density$x,y=density$y)
          p=ggplot(data = density)+geom_line(mapping = aes(x = x,y = y),size=1.5)+
            labs(title = "Closeness Distribution")+xlab(label = "Closeness")+ylab("Density")+
            theme(axis.title = element_text(family = "serif"),axis.text = element_text(family = "serif",colour = "black", vjust = 0.25), 
                  axis.text.x = element_text(family = "serif",colour = "black"), 
                  axis.text.y = element_text(family = "serif",colour = "black"), 
                  plot.title = element_text(family = "serif", hjust = 0.5,size=14),
                  panel.background = element_rect(fill = NA),legend.position = 'none',
                  plot.subtitle = element_text(family = "serif",size = 12, colour = "black", hjust = 0.5,vjust = 1))
          svglite(paste(basepath,"Plot",'node_closeness.svg',sep="/"))
          print(p)
          dev.off()
          output$node_Closeness_plot=renderImage({
            list(src=normalizePath(paste(basepath,"Plot",'node_closeness.svg',sep="/")),height="100%",width="100%")
          },deleteFile=F)
        }
        else if(id=="Clustering Coefficient")
        {
          cc=transitivity(net_igraph,type='local',isolates = 'zero')
          nodeNewInfo$Clustering.Coefficient<<-""
          nodeNewInfo[V(net_igraph)$name,'Clustering.Coefficient']<<-cc
          density=density(x = cc,from = min(cc,na.rm = T),to = max(cc,na.rm = T),na.rm = T)
          density=data.frame(x=density$x,y=density$y)
          p=ggplot(data = density)+geom_line(mapping = aes(x = x,y = y),size=1.5)+
            labs(title = "Clustering Coefficient Distribution")+xlab(label = "Clustering Coefficient")+ylab("Density")+
            theme(axis.title = element_text(family = "serif"),axis.text = element_text(family = "serif",colour = "black", vjust = 0.25), 
                  axis.text.x = element_text(family = "serif",colour = "black"), 
                  axis.text.y = element_text(family = "serif",colour = "black"), 
                  plot.title = element_text(family = "serif", hjust = 0.5,size=14),
                  panel.background = element_rect(fill = NA),legend.position = 'none',
                  plot.subtitle = element_text(family = "serif",size = 12, colour = "black", hjust = 0.5,vjust = 1))
          svglite(paste(basepath,"Plot",'node_clustering_coefficient.svg',sep="/"))
          print(p)
          dev.off()
          output$node_Clustering_Coefficient_plot=renderImage({
            list(src=normalizePath(paste(basepath,"Plot",'node_clustering_coefficient.svg',sep="/")),height="100%",width="100%")
          },deleteFile=F)
        }
        
      }
    }
    
  })
  observeEvent(input$edgeCentrality,{
    isolate({
      msg=input$edgeCentrality
      centrality=msg$value
    })
  
    if(R.oo::equals(net_igraph,"")){
      sendSweetAlert(session = session,title = "Error",text = "Please complete step 3 first",type = 'error')
    }else{
      deleted=setdiff(edge_property,centrality)
      removeUI(selector = paste("#edge_",deleted,sep=""),multiple = T,immediate = T)
      newadd=setdiff(centrality,edge_property)
      edge_property<<-centrality
      for(id in newadd)
      {
        ui=create_property_box('edge',id)
        insertUI(selector = "#network_property",where = 'beforeEnd',ui = ui,
                 immediate = T)
        
        if(id=="Betweenness")
        {
          betweenness=edge_betweenness(net_igraph,directed = F)
          
          #edgelist=t(apply(X = as_edgelist(net_igraph),MARGIN = 1,FUN = sort))
          #edgename=rownames(edgeinfo)
          #rownames(edgeinfo)<<-paste(edgename[,1],edgename[,2],sep="|")
          edgelist=as_edgelist(net_igraph)
          badindex=which(edgelist[,1]>=edgelist[,2])
          tmpnode1=edgelist[badindex,1]
          edgelist[badindex,1]=edgelist[badindex,2]
          edgelist[badindex,2]=tmpnode1
          print(all(edgelist==edgeinfo[,c('N1','N2')]))
          edgeinfo[paste(edgelist[,1],edgelist[,2],sep="+"),'Betweenness']<<-betweenness
          #rownames(edgeinfo)<<-NULL
          
          density=density(x = betweenness,from = min(betweenness,na.rm = T),to = max(betweenness,na.rm = T),na.rm = T)
          density=data.frame(x=density$x,y=density$y)
          p=ggplot(data = density)+geom_line(mapping = aes(x = x,y = y),size=1.5)+
            labs(title = "Edge Betweenness Distribution")+xlab(label = "Betweenness")+ylab("Density")+
            theme(axis.title = element_text(family = "serif"),axis.text = element_text(family = "serif",colour = "black", vjust = 0.25), 
                  axis.text.x = element_text(family = "serif",colour = "black"), 
                  axis.text.y = element_text(family = "serif",colour = "black"), 
                  plot.title = element_text(family = "serif", hjust = 0.5,size=14),
                  panel.background = element_rect(fill = NA),legend.position = 'none',
                  plot.subtitle = element_text(family = "serif",size = 12, colour = "black", hjust = 0.5,vjust = 1))
          svglite(paste(basepath,"Plot",'edge_betweenness.svg',sep="/"))
          print(p)
          dev.off()
          output$edge_Betweenness_plot=renderImage({
            list(src=normalizePath(paste(basepath,"Plot",'edge_betweenness.svg',sep="/")),height="100%",width="100%")
          },deleteFile=F)
        }
        
      }
    }
  })
  observeEvent(input$nodeDetails,{
    removeUI(selector = "#modalbody>",immediate = T)
    insertUI(selector = "#modalbody",where = 'beforeEnd',ui = rHandsontableOutput(outputId = "nodeDetailsTable"),immediate = T)
    output$nodeDetailsTable=renderRHandsontable({
      if(nodeNewInfo!="")
      {
        showtable=cbind(after_slice_geneinfo,nodeNewInfo[rownames(after_slice_geneinfo),])
        index=which(colnames(showtable)==".id")
        showtable=showtable[,-1*index]
      }
      else
      {
        showtable=after_slice_geneinfo
      }
      doubleColumn=which(unlist(lapply(X = showtable,FUN = typeof))=='double')
      rhandsontable(showtable, width = "100%", height = "500",rowHeaders = NULL,search = T) %>%
        hot_table(highlightCol = TRUE, highlightRow = TRUE) %>%
        hot_cols(columnSorting = T,manualColumnMove = T,manualColumnResize = F) %>%
        hot_col(col = seq(1:dim(showtable)[2]),halign='htCenter',readOnly = T,copyable = T)%>%
        hot_col(col = doubleColumn,format = '0.000e-0')
      
    })
  })
  observeEvent(input$edgeDetails,{
    removeUI(selector = "#modalbody>",immediate = T)
    insertUI(selector = "#modalbody",where = 'beforeEnd',ui = rHandsontableOutput(outputId = "edgeDetailsTable"),immediate = T)
    output$edgeDetailsTable=renderRHandsontable({
      doubleColumn=which(unlist(lapply(X = edgeinfo,FUN = typeof))=='double')
      rhandsontable(edgeinfo, width = "100%", height = "500",rowHeaders = NULL,readOnly = F) %>%
        hot_table(highlightCol = TRUE, highlightRow = TRUE) %>%
        hot_cols(columnSorting = T,manualColumnMove = T,manualColumnResize = T) %>%
        hot_col(col = doubleColumn,format='0.000e+0')%>%
        hot_col(col = seq(1:dim(edgeinfo)[2]),halign='htCenter',readOnly = T,copyable = T)
    })
  })
  observeEvent(input$community_detection,{
    isolate({
      algorithm=input$community_algorithm
    })
    
    if(R.oo::equals(net_igraph,"")){
      sendSweetAlert(session = session,title = "Error",text = "Please complete step 3 first",type = 'error')
    }else{
      removeUI(selector = "#module_info_box>",multiple = T,immediate = T)
      removeUI(selector = "#module_visualization>",multiple = T,immediate = T)
      insertUI(selector = "#module_info_box",where = 'beforeEnd',ui = create_progress(paste0("Running ",algorithm,"...")),immediate = T)
      modules<<-list()
      moduleinfo<<-""
      module.configure<<-list()
      gc()
      
      if(algorithm=='cluster_edge_betweenness')
      {
        community=get(algorithm)(net_igraph)
        communitySize=sizes(community)
        singleNodeCommunity=as.numeric(names(communitySize[which(communitySize==1)]))
        membership=membership(community)
        membership[which(membership%in%singleNodeCommunity)]=0
        after_slice_geneinfo[names(membership),'module']<<-paste("Module",membership,sep="")
        
        community_list=list()
        for(id in unique(membership))
        {
          module_gene=names(membership)[which(membership==id)]
          community_list=c(community_list,list(module_gene))
        }
        names(community_list)=paste("Module",unique(membership),sep="")
        modules<<-community_list
      }
      else if(algorithm=='cluster_fast_greedy')
      {
        community=get(algorithm)(net_igraph)
        communitySize=sizes(community)
        singleNodeCommunity=as.numeric(names(communitySize[which(communitySize==1)]))
        membership=membership(community)
        membership[which(membership%in%singleNodeCommunity)]=0
        after_slice_geneinfo[names(membership),'module']<<-paste("Module",membership,sep="")
        
        community_list=list()
        for(id in unique(membership))
        {
          module_gene=names(membership)[which(membership==id)]
          community_list=c(community_list,list(module_gene))
        }
        names(community_list)=paste("Module",unique(membership),sep="")
        modules<<-community_list
        
      }
      else if(algorithm=='cluster_label_prop')
      {
        community=get(algorithm)(net_igraph)
        communitySize=sizes(community)
        singleNodeCommunity=as.numeric(names(communitySize[which(communitySize==1)]))
        membership=membership(community)
        membership[which(membership%in%singleNodeCommunity)]=0
        after_slice_geneinfo[names(membership),'module']<<-paste("Module",membership,sep="")
        
        community_list=list()
        for(id in unique(membership))
        {
          module_gene=names(membership)[which(membership==id)]
          community_list=c(community_list,list(module_gene))
        }
        names(community_list)=paste("Module",unique(membership),sep="")
        modules<<-community_list
      }
      else if(algorithm=='cluster_leading_eigen')
      {
        
      }
      else if(algorithm=='cluster_louvain')
      {
        community=get(algorithm)(net_igraph)
        communitySize=sizes(community)
        singleNodeCommunity=as.numeric(names(communitySize[which(communitySize==1)]))
        membership=membership(community)
        membership[which(membership%in%singleNodeCommunity)]=0
        after_slice_geneinfo[names(membership),'module']<<-paste("Module",membership,sep="")
        
        community_list=list()
        for(id in unique(membership))
        {
          module_gene=names(membership)[which(membership==id)]
          community_list=c(community_list,list(module_gene))
        }
        names(community_list)=paste("Module",unique(membership),sep="")
        modules<<-community_list
      }
      else if(algorithm=='cluster_optimal')
      {
        community=get(algorithm)(net_igraph)
        communitySize=sizes(community)
        singleNodeCommunity=as.numeric(names(communitySize[which(communitySize==1)]))
        membership=membership(community)
        membership[which(membership%in%singleNodeCommunity)]=0
        after_slice_geneinfo[names(membership),'module']<<-paste("Module",membership,sep="")
        
        community_list=list()
        for(id in unique(membership))
        {
          module_gene=names(membership)[which(membership==id)]
          community_list=c(community_list,list(module_gene))
        }
        names(community_list)=paste("Module",unique(membership),sep="")
        modules<<-community_list
      }
      else if(algorithm=='cluster_walktrap')
      {
        isolate({
          step=floor(input$walktrap_step)
        })
        community=get(algorithm)(net_igraph,step=step)
        communitySize=sizes(community)
        singleNodeCommunity=as.numeric(names(communitySize[which(communitySize==1)]))
        membership=membership(community)
        membership[which(membership%in%singleNodeCommunity)]=0
        after_slice_geneinfo[names(membership),'module']<<-paste("Module",membership,sep="")
        
        community_list=list()
        for(id in unique(membership))
        {
          module_gene=names(membership)[which(membership==id)]
          community_list=c(community_list,list(module_gene))
        }
        names(community_list)=paste("Module",unique(membership),sep="")
        modules<<-community_list
      }
      else if(algorithm=='cluster_infomap')
      {
        isolate({
          nb.trials=floor(input$infomap_nb_trails)
        })
        community=get(algorithm)(net_igraph,nb.trials=nb.trials)
        communitySize=sizes(community)
        singleNodeCommunity=as.numeric(names(communitySize[which(communitySize==1)]))
        membership=membership(community)
        membership[which(membership%in%singleNodeCommunity)]=0
        after_slice_geneinfo[names(membership),'module']<<-paste("Module",membership,sep="")
        
        community_list=list()
        for(id in unique(membership))
        {
          module_gene=names(membership)[which(membership==id)]
          community_list=c(community_list,list(module_gene))
        }
        names(community_list)=paste("Module",unique(membership),sep="")
        modules<<-community_list
      }
      else if(algorithm=='cluster_cograph')
      {
        netpath=paste(basepath,"/data/net_edge.txt",sep="")
        write.table(x = edgeinfo[,c("N1","N2")],file = netpath,quote = F,sep = "\t",row.names = F,col.names = F)
        outpath=paste(basepath,"/data/",sep="")
        cluster_cograph(netpath = netpath,outpath = outpath)
      }
      else if(algorithm=='cluster_mcl')
      {
        isolate({
          expansion=input$mcl_expansion
          inflation=input$mcl_inflation
          max.iter=floor(input$mcl_max_iter)
        })
        community=get(algorithm)(net_igraph,expansion=expansion,inflation=inflation,max.iter=max.iter)
        after_slice_geneinfo[names(community),'module']<<-community
        community_list=list()
        for(id in unique(community))
        {
          module_gene=names(community)[which(community==id)]
          community_list=c(community_list,list(module_gene))
        }
        names(community_list)=paste("Module",unique(community),sep="")
        modules<<-community_list
      }
      else if(algorithm=='cluster_linkcomm')
      {
        isolate({
          hcmethod=input$linkcomm_hcmethod
        })
        community=get(algorithm)(edgeinfo,hcmethod=hcmethod)
        after_slice_geneinfo[,'module']<<-''
        community_list=list()
        for(id in unique(community$cluster))
        {
          module_gene=community$node[which(community$cluster==id)]
          community_list=c(community_list,list(module_gene))
          after_slice_geneinfo[module_gene,'module']<<-paste(after_slice_geneinfo[module_gene,'module'],',Module',id,sep="")
        }
        after_slice_geneinfo$module[which(R.oo::equals(after_slice_geneinfo$module,""))]<<-"Module0"
        after_slice_geneinfo$module<<-sub(pattern = "^,",replacement = "",x = after_slice_geneinfo$module)
        names(community_list)=paste("Module",unique(community$cluster),sep="")
        modules<<-community_list
      }
      else if(algorithm=='cluster_mcode')
      {
        isolate({
          vwp=input$mcode_vwp
          haircut=input$mcode_haircut
          fluff=input$mcode_fluff
          fdt=input$mcode_fdt
        })
        community=get(algorithm)(net_igraph,vwp=vwp,haircut=haircut,fluff=fluff,fdt=fdt)
        
        after_slice_geneinfo[,'module']<<-''
        community_list=list()
        for(id in unique(community$cluster))
        {
          module_gene=community$node[which(community$cluster==id)]
          community_list=c(community_list,list(module_gene))
          after_slice_geneinfo[module_gene,'module']<<-paste(after_slice_geneinfo[module_gene,'module'],',Module',id,sep="")
        }
        after_slice_geneinfo$module[which(R.oo::equals(after_slice_geneinfo$module,""))]<<-"Module0"
        after_slice_geneinfo$module<<-sub(pattern = "^,",replacement = "",x = after_slice_geneinfo$module)
        names(community_list)=paste("Module",unique(community$cluster),sep="")
        modules<<-community_list
      }
      #Show Communities
      create_module_info()
      removeUI(selector = "#module_info_box>",immediate = T,multiple = T)
      insertUI(selector = "#module_info_box",where = 'beforeEnd',ui = create_alert_box(header="Tips",msg="The <i>Module0</i> is consisted of all isolated nodes",class="col-lg-4"),immediate = T)
      insertUI(selector = "#module_info_box",where = 'beforeEnd',ui = rHandsontableOutput(outputId = "moduleInfoTable"),immediate = T)
      output$moduleInfoTable=renderRHandsontable({
        rhandsontable(moduleinfo)%>%
          hot_cols(columnSorting = T)%>%
          hot_table(contextMenu = F)%>%
          hot_col(col = seq(1:dim(moduleinfo)[2]),halign='htCenter',readOnly = T,copyable=T)%>%
          hot_col(col = "Nodes",halign = 'htCenter',renderer=htmlwidgets::JS("safeHtmlRenderer"))%>%
          hot_col(col = "Edges",halign = 'htCenter',renderer=htmlwidgets::JS("safeHtmlRenderer"))%>%
          hot_col(col = "Visualization",halign = 'htCenter',renderer=htmlwidgets::JS("safeHtmlRenderer"))
      })
      updatePickerInput(session = session,inputId = "enrichment_Module_analysis1",
                        choices = moduleinfo$ModuleID)
      updatePickerInput(session = session,inputId = "clinical_module",choices = names(modules))
    }
    
  })
  observeEvent(input$communityDetals,{
    isolate({
      msg=input$communityDetals
      id=msg$moduleid
    })
    modulegene=modules[[id]]
    removeUI(selector = "#modalbody>",multiple = T,immediate = T)
    insertUI(selector = "#modalbody",where = "beforeEnd",ui = rHandsontableOutput(outputId = "nodesDetailsTable"),immediate = T)
    output$nodesDetailsTable=renderRHandsontable({
      if(nodeNewInfo!="")
      {
        showtable=cbind(after_slice_geneinfo,nodeNewInfo[rownames(after_slice_geneinfo),])#,stringsAsFactors = F,check.rows = T,check.names = T)
        index=which(colnames(showtable)==".id")
        showtable=showtable[,-1*index]
      }
      else
      {
        showtable=after_slice_geneinfo
      }
      doubleColumn=which(unlist(lapply(X = showtable,FUN = typeof))=='double')
      rhandsontable(showtable[modulegene,], width = "100%", height = "500",rowHeaders = NULL,search = T) %>%
        hot_table(highlightCol = TRUE, highlightRow = TRUE) %>%
        hot_cols(columnSorting = T,manualColumnMove = T,manualColumnResize = F) %>%
        hot_col(col = seq(1:dim(showtable)[2]),halign='htCenter',readOnly = T,copyable = T)%>%
        hot_col(col = doubleColumn,format = '0.000e-0')
    })
  })
  observeEvent(input$communityEdgeDetals,{
    isolate({
      msg=input$communityEdgeDetals
      id=msg$moduleid
    })
    modulegene=modules[[id]]
    index=which(edgeinfo$N1%in%modulegene&edgeinfo$N2%in%modulegene)
    edges=edgeinfo[index,]
    removeUI(selector = "#modalbody>",multiple = T,immediate = T)
    insertUI(selector = "#modalbody",where = "beforeEnd",ui = rHandsontableOutput(outputId = "nodesDetailsTable"),immediate = T)
    output$nodesDetailsTable=renderRHandsontable({
      doubleColumn=which(unlist(lapply(X = edges,FUN = typeof))=='double')
      rhandsontable(edges, width = "100%", height = "500",rowHeaders = NULL,readOnly = F) %>%
        hot_table(highlightCol = TRUE, highlightRow = TRUE) %>%
        hot_cols(columnSorting = T,manualColumnMove = T,manualColumnResize = T) %>%
        hot_col(col = doubleColumn,format='0.000e+0')%>%
        hot_col(col = seq(1:dim(edges)[2]),halign='htCenter',readOnly = T,copyable = T)
    })
  })
  observeEvent(input$displayCommunity,{
    isolate({
      msg=input$displayCommunity
      id=msg$moduleid
    })
    
    if(is.null(module.configure[[id]]))
    {
      tmp.configure=list(default.configure)
      names(tmp.configure)=id
      module.configure<<-c(module.configure,tmp.configure)
    }
    
    removeUI(selector = paste("#module_",id,sep=""),multiple = T,immediate = T)
    ui=create_module_visualization(id)
    insertUI(selector = "#module_visualization",where = 'beforeEnd',ui = ui,immediate = T)
    output[[paste(id,"_plot",sep="")]]=renderVisNetwork({
      module.gene=modules[[id]]
      node=data.frame(id=module.gene,label=module.gene,
                      group=after_slice_geneinfo[module.gene,'.group'],color='red')
      edgeindex=which(edgeinfo$N1%in%module.gene&edgeinfo$N2%in%module.gene)
      edge=edgeinfo[edgeindex,c("N1","N2")]
      colnames(edge)=c("from",'to')
      visNetwork(nodes = node,edges = edge,width = "100%",height = "100%")%>%
        visPhysics(stabilization = FALSE)%>%
        visEdges(smooth = FALSE)%>% 
        visInteraction(navigationButtons = TRUE)%>%
        visIgraphLayout()%>% 
        visOptions(highlightNearest = TRUE)
    })
  })
  observeEvent(input$module_setting,{
    isolate({
      msg=input$module_setting
      id=msg$id
    })
    removeUI(selector = "#modalbody>",multiple = T,immediate = T)
    ui=create_modal_setting(id)
    insertUI(selector = "#modalbody",where = "beforeEnd",ui = ui,multiple = F,immediate = T)
  })
  
  observeEvent(input$Update_community_style,{
    isolate({
      msg=input$Update_community_style
      id=msg$id
      layout=input$module_layout
      label=input$module_label
      color_map=input$module_color
      shape_map=input$module_shape
    })
    
    module.gene=modules[[id]]
    node=data.frame(id=module.gene,
                    label=after_slice_geneinfo[module.gene,label],
                    color='',
                    shpe='',stringsAsFactors = F
    )
    rownames(node)=node$id
    edgeindex=which(edgeinfo$N1%in%module.gene&edgeinfo$N2%in%module.gene)
    edge=edgeinfo[edgeindex,c("N1","N2")]
    colnames(edge)=c("from",'to')
    if(color_map=="All")
    {
      isolate({
        color=input[["All_color"]]
      })
      node$color=color
      module.configure[[id]]$color<<-color
    }
    else
    {
      module.configure[[id]]$color<<-list()
      items=as.character(unique(after_slice_geneinfo[module.gene,color_map]))
      for(item in items)
      {
        isolate({
          color=input[[paste0(item,"_color")]]
        })
        node[module.gene[which(after_slice_geneinfo[module.gene,color_map]==item)],'color']=color
        
        module.configure[[id]]$color<<-c(module.configure[[id]]$color,list(color))
      }
      names(module.configure[[id]]$color)<<-items
    }
    if(shape_map=="All")
    {
      isolate({
        shape=input[["All_shape"]]
      })
      node$shape=shape
      module.configure[[id]]$shape<<-shape
    }
    else
    {
      module.configure[[id]]$shape<<-list()
      items=as.character(unique(after_slice_geneinfo[module.gene,shape_map]))
      for(item in items)
      {
        isolate({
          shape=input[[paste0(item,"_shape")]]
        })
        node[module.gene[which(after_slice_geneinfo[module.gene,shape_map]==item)],'shape']=shape
        
        module.configure[[id]]$shape<<-c(module.configure[[id]]$shape,list(shape))
      }
      names(module.configure[[id]]$shape)<<-items
    }
    output[[paste(id,"_plot",sep="")]]=renderVisNetwork({
      visNetwork(nodes = node,edges = edge,width = "100%",height = "100%")%>%
        visPhysics(stabilization = FALSE)%>%
        visEdges(smooth = FALSE)%>% 
        visInteraction(navigationButtons = TRUE)%>%
        visIgraphLayout(layout = layout)%>%
        visOptions(highlightNearest = TRUE) 
    })
    
    module.configure[[id]]$layout<<-layout
    module.configure[[id]]$label<<-label
    module.configure[[id]]$color.attr<<-color_map
    module.configure[[id]]$shape.attr<<-shape_map
  })
  
  observeEvent(list(input$clinical_file,input$clinical_seperator,input$clinical_header,input$clinical_first_col,input$clinical_quote),{
    isolate({
      file=input$clinical_file
      seperator=input$clinical_seperator
      header=as.logical(input$clinical_header)
      first_column=as.logical(input$clinical_first_col)
      quote=input$clinical_quote
    })
    if(!is.null(file))
    {
      tryCatch(
      {
        removeUI(selector = "#clinical_data_preview>",multiple = T,immediate = T)
        insertUI(selector = "#clinical_data_preview",where = 'beforeEnd',ui = div(class="overlay",id="icon",tags$i(class="fa fa-spinner fa-spin",style="font-size:50px")))
        insertUI(selector = "#clinical_data_preview",where = 'beforeEnd',ui = dataTableOutput(outputId = "clinical_data_table"))
        clinical_data<<-read.table(file = file$datapath,header = header,sep = seperator,stringsAsFactors = F,check.names = F,quote = quote)
        if(first_column)
        {
          #clinical_data[,1]<<-gsub(pattern = "-",replacement = ".",x = clinical_data[,1])
          rownames(clinical_data)<<-clinical_data[,1]
          clinical_data<<-clinical_data[,-1]
        }
        output[['clinical_data_table']]=renderDataTable({
          head(clinical_data,n=20)
        })
        removeUI(selector = "#icon")
        column=colnames(clinical_data)
        names(column)=column
        updatePickerInput(session = session,inputId = 'clinical_survival_time',choices = column)
        updatePickerInput(session = session,inputId = 'clinical_survival_status',choices = column)
        updatePickerInput(session = session,inputId = 'survival_extern_factor_continous',choices = column)
        updatePickerInput(session = session,inputId = 'survival_extern_factor_categorical',choices = column)
        updatePickerInput(session = session,inputId = 'survival_stratified_factor',choices = column)
        
        output$clinical_patient_count=renderUI({
          div(class="external-event bg-light-blue",style="font-size:16px",
              list(tags$span("Patients in Clinical Data"),
                   tags$small(class="badge pull-right bg-red",style="font-size:16px",HTML(dim(clinical_data)[1])))
          )
        })
        
        if(survival_exp!="")
        {
          valid_patient<<-intersect(rownames(clinical_data),colnames(survival_exp))
          output$clinical_valid_patient_count=renderUI({
            div(class="external-event bg-light-blue",style="font-size:16px",
                list(tags$span("Valid Patients"),
                     tags$small(class="badge pull-right bg-red",style="font-size:16px",HTML(length(valid_patient))))
            )
          })
        }
      },
      error=function(e){
        sendSweetAlert(session = session,title = "Error...",text = e$message,type = 'error')
        removeUI(selector = "#clinical_patient_count>",multiple = T,immediate = T)
        removeUI(selector = "#clinical_valid_patient_count>",multiple = T,immediate = T)
      }
    )
      
    }
    
  })

  observeEvent(list(input$survival_exp_data,input$survival_exp_seperator,input$survival_exp_header,input$survival_exp_first_column),{
    isolate({
      file=input$survival_exp_data
      seperator=input$survival_exp_seperator
      header=as.logical(input$survival_exp_header)
      first_column=as.logical(input$survival_exp_first_column)
    })
    if(!is.null(file))
    {
      tryCatch(
      {
        removeUI(selector = "#survival_exp_preview>",multiple = T,immediate = T)
        insertUI(selector = "#survival_exp_preview",where = 'beforeEnd',ui = div(class="overlay",id="icon",tags$i(class="fa fa-spinner fa-spin",style="font-size:50px")))
        insertUI(selector = "#survival_exp_preview",where = 'beforeEnd',ui = dataTableOutput(outputId = "survival_exp_data_table"))
        survival_exp<<-read.table(file = file$datapath,header = header,sep = seperator,stringsAsFactors = F,check.names = F)
        if(first_column)
        {
          #srvival_exp[,1]<<-gsub(pattern = "-",replacement = ".",x = survival_exp[,1])
          rownames(survival_exp)<<-survival_exp[,1]
          survival_exp<<-survival_exp[,-1]
        }
        output[['survival_exp_data_table']]=renderDataTable({
          head(survival_exp,n=20)
        })
        removeUI(selector = "#icon")
        column=colnames(clinical_data)
        names(column)=column
        updatePickerInput(session = session,inputId = 'clinical_survival_time',choices = column)
        updatePickerInput(session = session,inputId = 'clinical_survival_status',choices = column)
        
        output$exp_patient_count=renderUI({
          div(class="external-event bg-light-blue",style="font-size:16px",
              list(tags$span("Patients in Expression Data"),
                   tags$small(class="badge pull-right bg-red",style="font-size:16px",HTML(dim(survival_exp)[2])))
          )
        })
        
        if(clinical_data!="")
        {
          valid_patient<<-intersect(rownames(clinical_data),colnames(survival_exp))
          output$clinical_valid_patient_count=renderUI({
            div(class="external-event bg-light-blue",style="font-size:16px",
                list(tags$span("Valid Patients"),
                     tags$small(class="badge pull-right bg-red",style="font-size:16px",HTML(length(valid_patient))))
            )
          })
        }
      },
      error=function(e){
        sendSweetAlert(session = session,title = "Error...",text = e$message,type = 'error')
        removeUI(selector = "#exp_patient_count>",multiple = T,immediate = T)
        removeUI(selector = "#clinical_valid_patient_count>",multiple = T,immediate = T)
      }
      )
    }
  })
  
  observeEvent(input$clinical_survival_status,{
    isolate({
      status_column=input$clinical_survival_status
    })
    if(status_column!="")
    {
      updatePickerInput(session = session,inputId = "clinical_survival_status_variable",choices = unique(clinical_data[,status_column]))
    }
  })
  observeEvent(input$survival_exp_con,{
    isolate({
      msg=as.logical(input$survival_exp_con)
    })
    if(msg)
    {
      survival_exp<<-after_slice_rna.exp
      output$exp_patient_count=renderUI({
        div(class="external-event bg-light-blue",style="font-size:16px",
            list(tags$span("Patients in Expression Data"),
                 tags$small(class="badge pull-right bg-red",style="font-size:16px",HTML(dim(survival_exp)[2])))
        )
      })
      
      if(!R.oo::equals(clinical_data,""))
      {
        valid_patient<<-intersect(rownames(clinical_data),colnames(survival_exp))
        output$clinical_valid_patient_count=renderUI({
          div(class="external-event bg-light-blue",style="font-size:16px",
              list(tags$span("Valid Patients"),
                   tags$small(class="badge pull-right bg-red",style="font-size:16px",HTML(length(valid_patient))))
          )
        })
      }
    }
    else
    {
      removeUI(selector = "#surv_exp_data_panel>",immediate = T,multiple = T)
      removeUI(selector = "#survival_exp_preview>",multiple = T,immediate = T)
      removeUI(selector = "#exp_patient_count>",multiple = T,immediate = T)
      removeUI(selector = "#clinical_valid_patient_count>",multiple = T,immediate = T)
      insertUI(selector = "#surv_exp_data_panel",where = 'beforeEnd',ui = fileInput(inputId="survival_exp_data",label = "Expression Data"),immediate = T)
      survival_exp<<-""
    }
  })
  observeEvent(input$execute_survival,{
    isolate({
      model=input$survival_model
      time=input$clinical_survival_time
      status=input$clinical_survival_status
      variable=input$clinical_survival_status_variable
    })
    if(R.oo::equals(clinical_data,""))
    {
      sendSweetAlert(session = session,title = "Error...",text = "Please Upload Clinical Data!",type = 'error')
      return()
    }
    if(R.oo::equals(time,""))
    {
      sendSweetAlert(session = session,title = "Error...",text = "Please Choose Column for Survival Time!",type = 'error')
      return()
    }
    if(R.oo::equals(status,""))
    {
      sendSweetAlert(session = session,title = "Error...",text = "Please Choose Column for Survival Status!",type = 'error')
      return()
    }
    if(R.oo::equals(variable,""))
    {
      sendSweetAlert(session = session,title = "Error...",text = "Please Choose Column for Censor Variable!",type = 'error')
      return()
    }
    
    isolate({
      genesource=input$clinical_gene_source
      singlelabel=input$clinical_single_gene
      quantile=input$single_quantile
      moduleset=input$clinical_module
      customgene=input$survival_custom_gene_input
      extern_factor_continous=input$survival_extern_factor_continous
      extern_factor_categorical=input$survival_extern_factor_categorical
      strata_factor=input$survival_stratified_factor
      if_module_group=input$survival_module_cluster_sample
      if_custom_group=input$survival_custom_cluster_sample
      if_single_group=input$survival_single_group_sample
    })
    
    if(genesource=="module")
    {
      if(is.null(moduleset))
      {
        sendSweetAlert(session = session,title = "Error...",text = "Please Select Modules for Analysis!",type = 'error')
        return()
      }
    }
    else if(genesource=="single.gene")
    {
      if(R.oo::equals(singlelabel,""))
      {
        sendSweetAlert(session = session,title = "Error...",text = "Please Input Gene Name!",type = 'error')
        return()
      } 
    }
    else if(genesource=="custom")
    {
      if(R.oo::equals(customgene,""))
      {
        sendSweetAlert(session = session,title = "Error...",text = "Please Input Gene Name!",type = 'error')
        return()
      }
    }
  
    clinical_data=clinical_data[valid_patient,]
    survival_exp=survival_exp[,valid_patient]
    index=which(clinical_data[,status]==variable)
    clinical_data[,status]=1
    clinical_data[index,status]=0
   
   removeUI(selector = "#survival_result_panel>",multiple = T,immediate = T)
    
   if(model=="km_analysis")
   {
     if(genesource=="module")
     {
       for(m in moduleset)
       {
         tryCatch({
                   modulegene=modules[[m]]
                   modulegene=modulegene[which(modulegene%in%rownames(survival_exp))]
                   patient.cluster=kmeans(t(survival_exp[modulegene,]),centers = 2)$cluster
                   
                   tmpclinical=clinical_data[,c(time,status)]
                   tmpclinical$group=""
                   
                   for(cl in unique(patient.cluster))
                   {
                     tmpclinical[names(patient.cluster)[which(patient.cluster==cl)],'group']=paste("Group",cl,sep="")
                   }
                   
                   tmpclinical=tmpclinical[which(tmpclinical$group!=""),]
                   p=km.analysis(data = tmpclinical,time = time,status = status,factor = "group")
                   create_survival_result_box(session,label=paste("Survival Result of ",m,sep=""),id=m,model=model)
                   
                   imagepath=paste(basepath,"/Plot/",m,"_",model,"_survival_curve.svg",sep="")
                   svglite(imagepath)
                   print(p$plot)
                   dev.off()
                   
                   imagepath_heat=paste(basepath,"/Plot/",m,"_",model,"_survival_cluster.png",sep="")
                   Heatmaps(survival_exp[modulegene,],tmpclinical,imagepath_heat)
                   #plot_survival_result(output,basepath,m,model,list(p$plot,"",p$data.survtable))
                   local({
                     id=m
                     table=p$data.survtable
                     imagepe_for_heat=imagepath_heat
                     output[[paste(id,model,"survival_curve",sep="_")]]=renderImage({
                       imagepath=paste(basepath,"/Plot/",id,"_",model,"_survival_curve.svg",sep="")
                       # svg(imagepath,family = "serif")
                       # print(plot$plot)
                       # dev.off()
                       list(src=imagepath,width="100%",height="100%")
                     },deleteFile = F)
                     output[[paste(id,model,"survival_cluster",sep="_")]]=renderImage({
                       list(src=imagepe_for_heat,width="100%",height="100%")
                     },deleteFile = F)
                     output[[paste(id,model,"survival_table",sep="_")]]=renderRHandsontable({
                       rhandsontable(table)
                     })
                   })
         },error=function(e)
         {
           insertUI(selector = "#survival_result_panel",where = "beforeEnd",immediate = T,session = session,
                    ui=div(class="col-lg-6 col-md-12",
                           div(class="box box-primary",id=paste(m,model,sep="_"),
                               div(class="box-header with-border",
                                   h4(paste("Survival Result of ",m,sep=""))
                               ),
                               div(class="box-body",
                                   h4(e$message)
                               )
                               
                           )
                    )
                   )
         })
      }
     }
     else if(genesource=="single.gene")
     {
       research_gene=unlist(strsplit(x = singlelabel,split = "\n|\r\n"))
       research_gene=research_gene[research_gene%in%rownames(survival_exp)]
       for(rg in research_gene)
       {
         tryCatch({
           thresh=quantile(survival_exp[rg,],probs = quantile)[1,1]
           tmpclinical=clinical_data[,c(time,status)]
           tmpclinical$group=""
           high_group=colnames(survival_exp)[which(as.numeric(survival_exp[rg,])>=thresh)]
           low_group=colnames(survival_exp)[which(as.numeric(survival_exp[rg,])<thresh)]
           tmpclinical[high_group,"group"]="High Expressed"
           tmpclinical[low_group,"group"]="Low Expressed"
           p=km.analysis(data = tmpclinical,time = time,status = status,factor = "group")
           create_survival_result_box(session,label=paste("Survival Result of ",rg,sep=""),id=rg,model=model)
           disp=SingleExpress(survival_exp[rg,],thresh,tmpclinical)
           
           imagepath=paste(basepath,"/Plot/",rg,"_",model,"_survival_curve.svg",sep="")
           svglite(imagepath)
           print(p$plot)
           dev.off()
           
           imagepath=paste(basepath,"/Plot/",rg,"_",model,"_survival_cluster.svg",sep="")
           svglite(imagepath)
           print(disp)
           dev.off()
           
           local({
             id=rg
             table=p$data.survtable
             output[[paste(id,model,"survival_curve",sep="_")]]=renderImage({
               imagepath=paste(basepath,"/Plot/",id,"_",model,"_survival_curve.svg",sep="")
               # svg(imagepath,family = "serif")
               # print(plot1$plot)
               # dev.off()
               list(src=imagepath,width="100%",height="100%")
             },deleteFile = F)
             output[[paste(id,model,"survival_cluster",sep="_")]]=renderImage({
               imagepath=paste(basepath,"/Plot/",id,"_",model,"_survival_cluster.svg",sep="")
               # svg(imagepath,family = "serif")
               # print(plot2)
               # dev.off()
               list(src=imagepath,width="100%",height="100%")
             },deleteFile = F)
             output[[paste(id,model,"survival_table",sep="_")]]=renderRHandsontable({
               rhandsontable(table)
             })
           })
         },error=function(e)
         {
           insertUI(selector = "#survival_result_panel",where = "beforeEnd",immediate = T,session = session,
                    ui=div(class="col-lg-6 col-md-12",
                           div(class="box box-primary",id=paste(rg,model,sep="_"),
                               div(class="box-header with-border",
                                   h4(paste("Survival Result of ",rg,sep=""))
                               ),
                               div(class="box-body",
                                   h4(e$message)
                               )
                               
                           )
                    )
           )
         })
       }
     }
     else if(genesource=="custom")
     {
       tryCatch({
         customgene=unlist(strsplit(x = customgene,split = "\r\n|\n"))
         customgene=customgene[which(customgene%in%rownames(survival_exp))]
         if(length(customgene)==1)
         {
           sendSweetAlert(session = session,title = "Warning...",text = "Please select Single Gene Model",type = "warning")
           return()
         }
         patient.cluster=kmeans(t(survival_exp[customgene,]),centers = 2)$cluster
         
         tmpclinical=clinical_data[,c(time,status)]
         tmpclinical$group=""
         
         for(cl in unique(patient.cluster))
         {
           tmpclinical[names(patient.cluster)[which(patient.cluster==cl)],'group']=paste("Group",cl,sep="")
         }
         
         tmpclinical=tmpclinical[which(tmpclinical$group!=""),]
         p=km.analysis(data = tmpclinical,time = time,status = status,factor = "group")
         create_survival_result_box(session,label=paste("Survival Result of Custom Gene Set",sep=""),id="custom",model=model)
         
         imagepath=paste(basepath,"/Plot/",'custom',"_",model,"_survival_curve.svg",sep="")
         svglite(imagepath)
         print(p$plot)
         dev.off()
         
         imagepath_heat=paste(basepath,"/Plot/","custom","_",model,"_survival_cluster.png",sep="")
         Heatmaps(survival_exp[customgene,],tmpclinical,imagepath_heat)
         #plot_survival_result(output,basepath,m,model,list(p$plot,"",p$data.survtable))
         local({
           id="custom"
           table=p$data.survtable
           imagepe_for_heat=imagepath_heat
           output[[paste(id,model,"survival_curve",sep="_")]]=renderImage({
             imagepath=paste(basepath,"/Plot/",id,"_",model,"_survival_curve.svg",sep="")
             # svg(imagepath,family = "serif")
             # print(plot$plot)
             # dev.off()
             list(src=imagepath,width="100%",height="100%")
           },deleteFile = F)
           output[[paste(id,model,"survival_cluster",sep="_")]]=renderImage({
             list(src=imagepe_for_heat,width="100%",height="100%")
           },deleteFile = F)
           output[[paste(id,model,"survival_table",sep="_")]]=renderRHandsontable({
             rhandsontable(table)
           })
         })
       },error=function(e)
       {
         insertUI(selector = "#survival_result_panel",where = "beforeEnd",immediate = T,session = session,
                  ui=div(class="col-lg-6 col-md-12",
                         div(class="box box-primary",id=paste("custom",model,sep="_"),
                             div(class="box-header with-border",
                                 h4(paste("Survival Result of ","custom",sep=""))
                             ),
                             div(class="box-body",
                                 h4(e$message)
                             )
                             
                         )
                  )
         )
       })
     }
   }
   else if(model=="cox_model")
   {
     if(!is.null(extern_factor_continous)|!is.null(extern_factor_categorical))
     {
       tmpfactor=intersect(extern_factor_continous,extern_factor_categorical)
       if(length(tmpfactor)>0)
       {
         sendSweetAlert(session = session,title = "Error...",text = paste("Confused Factors Type in (",paste(tmpfactor,collapse = ", "),")",sep=""),type = "error")
         return()
       }
     }
     if(genesource=="module")
     {
       for(m in moduleset)
       {
         modulegene=modules[[m]]
         modulegene=modulegene[which(modulegene%in%rownames(survival_exp))]
         
         fit=cox.analysis(session,clinical_data,survival_exp,time,status,if_module_group,modulegene,extern_factor_continous,extern_factor_categorical,strata_factor)
         create_cox_survival_result_box(session,label=paste("Survival Result of ",m,sep=""),id=m,model=model)
         # 
         # # imagepath_heat=paste(basepath,"/Plot/",m,"_",model,"_survival_cluster.png",sep="")
         # # Heatmaps(survival_exp[modulegene,],tmpclinical,imagepath_heat)
         # # #plot_survival_result(output,basepath,m,model,list(p$plot,"",p$data.survtable))
         local({
           id=m
           result=summary(fit)
           coefficients=result$coefficients
           conf.int=result$conf.int
           #imagepe_for_heat=imagepath_heat
           output[[paste(id,model,"survival_coefficient",sep="_")]]=renderTable({
             coefficients
           },striped = T,rownames = T,colnames = T,digits = -2,align='c',hover = T)
           output[[paste(id,model,"survival_hazard",sep="_")]]=renderTable({
             conf.int
           },striped = T,rownames = T,colnames = T,digits = -2,align='c',hover = T)
           # output[[paste(id,model,"survival_table",sep="_")]]=renderRHandsontable({
           #   rhandsontable(plot$data.survtable)
           #})
         })
       }
     }
     else if(genesource=="single.gene")
     {
       research_gene=unlist(strsplit(x = singlelabel,split = "\n|\r\n"))
       research_gene=research_gene[research_gene%in%rownames(survival_exp)]
       for(rg in research_gene)
       {
         tmpclinical=clinical_data
         if(if_single_group)
         {
           thresh=quantile(survival_exp[rg,],probs = quantile)[1,1]
           tmpclinical$group=""
           high_group=colnames(survival_exp)[which(as.numeric(survival_exp[rg,])>=thresh)]
           low_group=colnames(survival_exp)[which(as.numeric(survival_exp[rg,])<thresh)]
           tmpclinical[high_group,"group"]="High Expressed"
           tmpclinical[low_group,"group"]="Low Expressed"
           if(length(unique(tmpclinical$group))==1)
           {
             sendSweetAlert(session = session,title = "Error...",text = paste("Patients can't be grouped by Gene ",rg,sep=""),type = 'error')
             next
           }
           fit=cox.analysis(session = session,clinical = tmpclinical,exp = survival_exp,
                            time = time,status = status,ifgroup = F,gene = rg,
                            external_continous = extern_factor_continous,
                            external_categorical = extern_factor_categorical,strata_factor = strata_factor,
                            single_grouped=T)
         }
         else
         {
           fit=cox.analysis(session = session,clinical = tmpclinical,exp = survival_exp,
                            time = time,status = status,ifgroup = F,gene = rg,
                            external_continous = extern_factor_continous,
                            external_categorical = extern_factor_categorical,strata_factor = strata_factor,
                            single_grouped=F)
         }
         create_cox_survival_result_box(session,label=paste("Survival Result of ",rg,sep=""),id=rg,model=model)
         local({
           id=rg
           result=summary(fit)
           coefficients=result$coefficients
           conf.int=result$conf.int
           #imagepe_for_heat=imagepath_heat
           output[[paste(id,model,"survival_coefficient",sep="_")]]=renderTable({
             coefficients
           },striped = T,rownames = T,colnames = T,digits = -2,align='c',hover = T)
           output[[paste(id,model,"survival_hazard",sep="_")]]=renderTable({
             conf.int
           },striped = T,rownames = T,colnames = T,digits = -2,align='c',hover = T)
           # output[[paste(id,model,"survival_table",sep="_")]]=renderRHandsontable({
           #   rhandsontable(plot$data.survtable)
           #})
         })
       }
     }
     else if(genesource=="custom")
     {
       customgene=unlist(strsplit(x = customgene,split = "\r\n|\n"))
       customgene=customgene[which(customgene%in%rownames(survival_exp))]
       if(length(customgene)==1)
       {
         sendSweetAlert(session = session,title = "Warning...",text = "Please select Single Gene Model",type = "warning")
         return()
       }
       fit=cox.analysis(session = session,clinical = clinical_data,exp = survival_exp,time = time,
                        status = status,ifgroup = if_custom_group,gene = customgene,
                        external_continous = extern_factor_continous,
                        external_categorical = extern_factor_categorical,
                        strata_factor = strata_factor,single_grouped = F)
       create_cox_survival_result_box(session,label=paste("Survival Result of Custom Genes",sep=""),id="custom",model=model)
       # 
       # # imagepath_heat=paste(basepath,"/Plot/",m,"_",model,"_survival_cluster.png",sep="")
       # # Heatmaps(survival_exp[modulegene,],tmpclinical,imagepath_heat)
       # # #plot_survival_result(output,basepath,m,model,list(p$plot,"",p$data.survtable))
       local({
         id="custom"
         result=summary(fit)
         coefficients=result$coefficients
         conf.int=result$conf.int
         #imagepe_for_heat=imagepath_heat
         output[[paste(id,model,"survival_coefficient",sep="_")]]=renderTable({
           coefficients
         },striped = T,rownames = T,colnames = T,digits = -2,align='c',hover = T)
         output[[paste(id,model,"survival_hazard",sep="_")]]=renderTable({
           conf.int
         },striped = T,rownames = T,colnames = T,digits = -2,align='c',hover = T)
         # output[[paste(id,model,"survival_table",sep="_")]]=renderRHandsontable({
         #   rhandsontable(plot$data.survtable)
         #})
       })
     }
   }
  })
  observeEvent(input$export_survival_plot,{
    isolate({
      msg=input$export_survival_plot
    })
    id=msg$id
    model=msg$model
    output[[paste(id,'_survival_export',sep="")]]=downloadHandler(
      filename=paste(id,"_survival_plot.zip",sep=""),
      content = function(file)
      {
        files=c()
        file1=paste(basepath,"/Plot/",id,"_",model,"_survival_cluster.png",sep="")
        file3=paste(basepath,"/Plot/",id,"_",model,"_survival_cluster.svg",sep="")
        file2=paste(basepath,"/Plot/",id,"_",model,"_survival_curve.svg",sep="")
        if(file.exists(file1))
        {
          files=c(files,file1)
        }
        if(file.exists(file3))
        {
          files=c(files,file3)
        }
        if(file.exists(file2))
        {
          files=c(files,file2)
        }
        zip(zipfile = file,files = files,flags = '-j')
      }
    )
  })
  observeEvent(input$initialization_enrichment,{
    updatePickerInput(session = session,inputId = "Organism_enrichment",
                      choices = sub(pattern ="_gene_ensembl$",replacement = "",x = specials$dataset),selected = "hsapiens")
    updatePickerInput(session = session,inputId = "enrichment_Numeric_IDs_treated_as",choices = colnames(after_slice_geneinfo))
  })
  observeEvent(input$demo_clinic,{
    tryCatch(
    {
      removeUI(selector = "#clinical_data_preview>",multiple = T,immediate = T)
      insertUI(selector = "#clinical_data_preview",where = 'beforeEnd',ui = div(class="overlay",id="icon",tags$i(class="fa fa-spinner fa-spin",style="font-size:50px")))
      insertUI(selector = "#clinical_data_preview",where = 'beforeEnd',ui = dataTableOutput(outputId = "clinical_data_table"))
      clinical_data<<-read.table(file = paste(getwd(),'/demo/brca_subtype.csv',sep=""),header = T,sep = ",",stringsAsFactors = F,check.names = F)
      rownames(clinical_data)<<-clinical_data[,1]
      output[['clinical_data_table']]=renderDataTable({
        head(clinical_data,n=20)
      })
      removeUI(selector = "#icon")
      column=colnames(clinical_data)
      names(column)=column
      updatePickerInput(session = session,inputId = 'clinical_survival_time',choices = column)
      updatePickerInput(session = session,inputId = 'clinical_survival_status',choices = column)
      updatePickerInput(session = session,inputId = 'survival_extern_factor_continous',choices = column)
      updatePickerInput(session = session,inputId = 'survival_extern_factor_categorical',choices = column)
      updatePickerInput(session = session,inputId = 'survival_stratified_factor',choices = column)
      
      output$clinical_patient_count=renderUI({
        div(class="external-event bg-light-blue",style="font-size:16px",
            list(tags$span("Patients in Clinical Data"),
                 tags$small(class="badge pull-right bg-red",style="font-size:16px",HTML(dim(clinical_data)[1])))
        )
      })
      
      survival_exp<<-after_slice_rna.exp
      output$exp_patient_count=renderUI({
        div(class="external-event bg-light-blue",style="font-size:16px",
            list(tags$span("Patients in Expression Data"),
                 tags$small(class="badge pull-right bg-red",style="font-size:16px",HTML(dim(survival_exp)[2])))
        )
      })
      valid_patient<<-intersect(rownames(clinical_data),colnames(survival_exp))
      output$clinical_valid_patient_count=renderUI({
        div(class="external-event bg-light-blue",style="font-size:16px",
            list(tags$span("Valid Patients"),
                 tags$small(class="badge pull-right bg-red",style="font-size:16px",HTML(length(valid_patient))))
        )
      })
    },
    error=function(e){
      sendSweetAlert(session = session,title = "Error...",text = e$message,type = 'error')
      removeUI(selector = "#exp_patient_count>",multiple = T,immediate = T)
      removeUI(selector = "#clinical_valid_patient_count>",multiple = T,immediate = T)
    }
  )
  })
  

  observeEvent(input$enrichment_finish,{
    isolate({
      Organism=input$Organism_enrichment
      # Organism='hsapiens'
      choose_analysis_tool=input$gProfileOnline_Or_custom_analysis
      Module_analysis=input$enrichment_Module_analysis1
      choose_analysis_gene=input$choose_which_gene_to_analysis
      Custom_input_gene=input$custom_input_gene
      Significance_threshold=input$enrichment_Significance_threshold
      User_threshold=input$enrichment_User_threshold
      Numeric_IDs_treated_as=input$enrichment_Numeric_IDs_treated_as
      Data_Sources=input$enrichment_Data_Sources
      choose_show=input$enrichment_choose_show
      filepath=input$enrichment_Custom_input_function_gene$datapath
      custom_significance_threshold_type=input$enrichment_Significance_threshold_custom
    })
    
    removeUI(selector = '#all_enrichment_show>',immediate = T,multiple = T)
    # removeUI(selector = "#module_info_box>",multiple = T,immediate = T)
    # removeUI(selector = "#module_visualization>",multiple = T,immediate = T)
    insertUI(selector = "#all_enrichment_show",where = 'beforeEnd',ui = create_progress(paste0("Running ",choose_analysis_tool,"..."),id="enrichment_progress"),immediate = T)
    
    if(choose_analysis_gene=="Custom_Gene"){
      gene_set=strsplit(x=Custom_input_gene,split = '\n')
      names(gene_set)="custom_set"
    }
    else{
      gene_set=list()
      for(i in Module_analysis){
        gene_set=c(gene_set,list(modules[[i]]) )
      }
      names(gene_set)=Module_analysis
    }
    
    enrichment=data.frame()
    if(choose_analysis_tool=='gProfile'){
      for(i in names(gene_set)){
        session$sendCustomMessage('update_progress_state',list(status='update',value=paste("Analyzing ",i,"...",sep=""),id="enrichment_progress"))
        enrichment_result=gost(modules[[i]], organism = Organism,sources = Data_Sources,
                               custom_bg=rownames(after_slice_geneinfo),user_threshold =User_threshold,
                               correction_method = Significance_threshold)$result
        if(!is.null(enrichment_result)){
          enrichment=rbind(enrichment,data.frame(enrichment_result,set_id=i,stringsAsFactors = F) )
        }
        
      }
      enrichment$source=gsub(pattern = ":",replacement = "_",x =enrichment$source )
    }
    else{
      for(set_id in names(gene_set)){
        session$sendCustomMessage('update_progress_state',list(status='update',value=paste("Analyzing ",set_id,"...",sep=""),id="enrichment_progress"))
        for(func_id in names(custom_gene_set)){
          background_set=as.character(unique(after_slice_geneinfo[,Numeric_IDs_treated_as]))
          singl_func_gene=interaction(custom_gene_set[[func_id]],background_set)
          modules_gene<-as.character(unique(after_slice_geneinfo[gene_set[[set_id]],Numeric_IDs_treated_as]))
          overlap_gene<-intersect(singl_func_gene,modules_gene)
          x=length(overlap_gene)
          func_gene_num=length(singl_func_gene)
          n=length(setdiff(background_set,singl_func_gene))
          k=length(modules_gene)
          temp_pvalue=1-phyper(x-1,func_gene_num,n,k)
          temp_recall=x/func_gene_num
          enrichment=rbind(enrichment,data.frame(set_id=set_id,term_id=func_id,
                                                 p_value=temp_pvalue,intersection_size=x,recall=temp_recall,source="custom",stringsAsFactors = F))
          
        }
      }
      if(custom_significance_threshold_type!="")
      {
        enrichment$p_value=p.adjust(enrichment$p_value,method = custom_significance_threshold_type)
      }
    }
    removeUI(selector = "#all_enrichment_show>",immediate = T,multiple = T)
    # insertUI(selector = "#module_info_box",where = 'beforeEnd',ui = create_alert_box(header="Tips",msg="The <i>Module0</i> is consisted of all isolated nodes",class="col-lg-4"),immediate = T)
    # insertUI(selector = "#module_info_box",where = 'beforeEnd',ui = rHandsontableOutput(outputId = "moduleInfoTable"),immediate = T)
    
    for(set_id in names(gene_set)){
      insertUI(
        selector ='#all_enrichment_show',
        where='beforeEnd',
        ui=div(class='box box-solid box-primary',id=paste('enrichment_show_',set_id,sep = ""),
               div(class='box-header',
                   h3(class="box-title",HTML(paste('enrichment_show_',set_id,sep = ""))),
                   div(class="box-tools pull-right",
                       tags$button(class='btn btn-box-tool',"data-widget"="collapse",
                                   tags$i(class='fa fa-minus')
                       )
                   )
               ),
               div(class="box-body",
                   div(class="box-group",id=paste(set_id,"group",sep="_"),
                       div(class="panel box box-info",
                           div(class="box-header with-border",
                               h4(class="box-title",
                                  tags$a(class="","data-toggle"="collapse",href=paste("#",set_id,"_","enrichment_cluster_panel",sep=""),"aria-expanded"="true","data-parent"=paste("#",set_id,'_group',sep=""),
                                         HTML("Enrichment plot")
                                  )
                               )
                           ),
                           div(class="panel-collapse collapse in","aria-expanded"="true",id=paste(set_id,"_","enrichment_cluster_panel",sep=""),
                               div(class="box-body",
                                   div(class='row')
                                   # imageOutput(outputId = paste(set_id,"enrichment_cluster",sep="_"),width = "100%",height = "100%")
                               )
                           )
                       ),
                       div(class="panel box box-warning",
                           div(class="box-header with-border",
                               h4(class="box-title",
                                  tags$a(class="collapsed","data-toggle"="collapse",href=paste("#",set_id,"_","enrichment_table_panel",sep=""),"aria-expanded"="false","data-parent"=paste("#",set_id,'_group',sep=""),
                                         HTML("Enrichment Table")
                                  )
                               )
                           ),
                           div(class="panel-collapse collapse","aria-expanded"="false",id=paste(set_id,"_","enrichment_table_panel",sep=""),
                               div(class="box-body",
                                   rHandsontableOutput(outputId = paste(set_id,"enrichment_table",sep="_"),width = "100%",height = "100%")
                               )
                           )
                       )
                   )
               ),
               
               div(class='box-footer',downloadButton(outputId=paste('export_enrichment_',set_id,sep=""),
                                                     onclick='export_enrichment_plot(this)',label = "Export"))
        ),
        immediate = T
      )
      temp_enrichment=enrichment[which(enrichment$set_id==set_id&enrichment$p_value<User_threshold),]
      if(is.character(temp_enrichment)||empty(temp_enrichment))
      {
        removeUI(selector = paste('#enrichment_show_',set_id,' .box-body',sep = ""),immediate = T,multiple = T)
        removeUI(selector = paste('#enrichment_show_',set_id,' .box-footer',sep = ""),immediate = T,multiple = T)
        insertUI(
          selector = paste('#enrichment_show_',set_id,sep = ""),
          where='beforeEnd',
          ui=div(class="box-body",
                 div(class="col-lg-12",
                     h3("There is no significant terms!")
                 )
          ),
          immediate = T
        )
      }
      else
      {
        for(ss in unique(temp_enrichment$source) ){
          insertUI(
            selector =paste(paste("#",set_id,"_","enrichment_cluster_panel",sep=""),' .row',sep = ""),
            where='beforeEnd',
            ui=div(class='col-lg-6',
                   imageOutput(outputId = paste(set_id,'enrichment_out_pic',ss,sep = "_"),height = "100%")),
            immediate = T
          )
          plotdata=temp_enrichment[which(temp_enrichment$source==ss),]
          plotdata$p_value=-log(plotdata$p_value)
          plotdata=plotdata[order(plotdata$p_value,decreasing = T),]
          
          svglite(paste(basepath,"Plot",paste(set_id,"_enrichment_plot_",ss,".svg",sep = ""),sep = "/"))
          if(choose_show=="bar_plot"){
            
            print(
              ggplot(plotdata,aes(x=factor(term_id,levels = plotdata$term_id),y=p_value,fill=recall))+
                geom_bar(stat = "identity")+labs(y="-log(P)",x="Term Id",title = paste(set_id,"enriched in",ss),fill="Recall")+
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
                      legend.key.width=unit(1.5,'cm'),
                      panel.background = element_rect(fill = NA)) +coord_flip()
            )
          }
          else{
            
            print(
              ggplot(plotdata,aes(y= factor(term_id,levels=plotdata$term_id),x=recall,colour=p_value,size=intersection_size))+
                geom_point()+labs(x="Recall",y="Term Id",title = paste(set_id,"enriched in",ss))+
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
                      legend.box = "vertical",
                      legend.key.width=unit(1.5,'cm'),
                      panel.background = element_rect(fill = NA)) +labs(colour = "-log(P)")
            )
          }
          dev.off()
          
          local({
            temp_setid=set_id
            temp_ss=ss
            output[[paste(temp_setid,"enrichment_out_pic",temp_ss,sep="_")]]=renderImage({
              list(src=paste(basepath,"Plot",paste(temp_setid,"_enrichment_plot_",temp_ss,".svg",sep = ""),sep = "/"),width="100%",height="100%")
            },deleteFile = F)
            
          })
          
        }
        
        local({
          temp_setid=set_id
          table=temp_enrichment
          output[[paste(temp_setid,"enrichment_table",sep="_")]]=renderRHandsontable({
            rhandsontable(table)
          })
        })
        
      }
    }
  })
  
  observeEvent(input$show_custom_input_file,{
    session$sendCustomMessage('reading',list(div='custom_preview_panel',status='ongoing'))
    isolate({
      filepath=input$enrichment_Custom_input_function_gene$datapath
    })
    
    if(is.null(filepath))
    {
      lines<-'No Data'
    }else
    {
      lines<-readLines(con =filepath )
    }
    Sys.sleep(2)
    session$sendCustomMessage('reading',list(div='custom_preview_panel',status='finish'))
    custom_gene_set<<-list()
    df=data.frame()
    for(i in lines){
      tmp=unlist(strsplit(x=i,split = '\t'))
      tmp_list=list(tmp[-1])
      names(tmp_list)=tmp[1]
      custom_gene_set<<-c(custom_gene_set,tmp_list)
      df=rbind(df,data.frame(Name=tmp[1],Size=length(tmp)-1,Action="Details",stringsAsFactors = F))
    }
    sign_formatter=formatter("span",onclick="showCustomGeneDetails(this)",style=function(x) {
      style(display = "inline-block",direction = "rtl", `border-radius` = "4px",`background-color` = csscolor('#3498db'), width = '150px')} )
    
    df$Action=sign_formatter(df$Action)
    
    my_color_bar <- function (color = "lightgray", fixedWidth=150,...) 
    {
      formatter("span", style = function(x) style(display = "inline-block", 
                                                  direction = "rtl", `border-radius` = "4px", `padding-right` = "2px", 
                                                  `background-color` = csscolor(color), width = paste(fixedWidth*proportion(x),"px",sep=""), 
                                                  ...))
    }
    
    output$custom_preview_panel=renderFormattable({
      formattable(df,align=c("c","r","c"),list(Size=my_color_bar("#2ecc71",250)))
    })
  })
 
  observeEvent(input$showCustomDetails,{
    isolate({
      msg=input$showCustomDetails
      id=msg$id
    })
    id=sub(pattern = '^ +',replacement = '',x = id)
    id=sub(pattern = ' +$',replacement = '',x = id)
    # aaa=tagList()
    # for(i in custom_gene_set[[id]]){
    #   aaa=tagList(aaa,tags$tr(tags$td(i)))
    # }
    aaa=paste('<table style="font-family:Times New Roman" align="center">',paste(paste('<tr><td>',custom_gene_set[[id]],'</td></tr>'),collapse = "") ,'</table>')
    aaa=HTML(aaa)
    
    confirmSweetAlert(session = session,inputId = "temp",title = id,
                      text =aaa ,html =T  )
    
  })
  
  observeEvent(input$export_enrichment_plot,{
    isolate({
      msg=input$export_enrichment_plot
    })
    picid=unlist(msg$picid)
    id=msg$id
    if(!is.null(picid))
    {
      path=sub(pattern ="enrichment_out_pic",replacement = "enrichment_plot",x = picid)
      files=paste(basepath,'/Plot/',path,'.svg',sep="")
      output[[id]]=downloadHandler(
        filename =function()
        {
          module=sub(pattern = "^export_enrichment_",replacement = "",x = id)
          paste(id,'_enrichment','.zip',sep="")
        },
        content = function(file)
        {
          zip(file,files = files,flags = '-j')
        }
      )
    }
  })
  
  output$export_network_node_property=downloadHandler(
     filename = 'Node_Property.txt',
     content = function(file)
     {
       if(!R.oo::equals(nodeNewInfo,""))
       {
         showtable=cbind(after_slice_geneinfo,nodeNewInfo[rownames(after_slice_geneinfo),])
         index=which(colnames(showtable)==".id")
         showtable=showtable[,-1*index]
       }
       else
       {
         showtable=after_slice_geneinfo
       }
       write.table(x = showtable,file = file,quote = F,sep="\t",row.names = F,col.names = T)
     }
   )
  output$export_network_edge_property=downloadHandler(
     filename = 'Edge_Property.txt',
     content = function(file)
     {
       write.table(x = edgeinfo,file = file,quote = F,sep="\t",row.names = F,col.names = T)
     }
   )
  output$export_network_property_plot=downloadHandler(
     filename = 'Network_Property_Plot.zip',
     content=function(file)
     {
       files=c()
       if(length(node_property)>0)
       {
         files=c(files,paste(basepath,'/Plot/node_',sub(pattern = ' ',replacement = '_',x = tolower(node_property)),'.svg',sep=""))
       }
       if(length(edge_property)>0)
       {
         files=c(files,paste(basepath,'/Plot/edge_',tolower(edge_property),'.svg',sep=""))
       }
       if(length(files)==0)
       {
         file.create('empty')
         zip(zipfile = file,files = 'empty',flags = '-j')
         file.remove('emtpy')
       }
       else
       {
         zip(zipfile = file,files = files,flags = '-j') 
       }
       
     }
  )
  output$export_module_info=downloadHandler(
    filename='Module_Information.txt',
    content=function(file)
    {
      data=""
      if(!R.oo::equals(moduleinfo,""))
      {
        data=moduleinfo[,seq(1,7)]
        data=data.frame(data,Nodes="",stringsAsFactors = F)
        for(i in seq(1,nrow(data)))
        {
          data[i,'Nodes']=paste(modules[[data[i,'ModuleID']]],collapse = ",")
        }
      }
      write.table(x = data,file = file,quote = F,row.names = F,col.names = T,sep = "\t")
    }
  )
})


