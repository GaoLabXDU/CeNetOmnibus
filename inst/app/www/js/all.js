var select_gene=new Array();
$(document).ready(function(){
  $('a[href="#shiny-tab-input"]').on('click',function(e){
    //initial(0)
  })
 
  create_modal();
  $.fn.select2.defaults.set('width','100%');
  $('#database').attr('readonly','readonly');
  $('#archieve').attr('readonly','readonly');
  $('#filter').attr('readonly','readonly');
  $('#select\\.gene').attr('readonly','readonly');
  $('#attribution').select2();
  $("div[data-value=CeRNA]").parent().css({'overflow':'auto','height':'510'});
  $("#target_preview_panel").parent().css({'overflow':'auto','height':'300'});
  $("#geneinfo_preview_panel").parent().css({'overflow':'auto','height':'400'});
  $('button.action-button[id*=preview]').attr('count',0);
  $('#Cenet_demo').on('click',function(e){
    var obj={}
    obj['stamp']=Math.random()
    Shiny.setInputValue('Cenet_demo',obj);
  })
  $('button.action-button[id*=preview]').on('click',function(e){
    if(e.currentTarget.id=='geneinfo_preview')
    {
       if($('#geneinfo_source').val()=='biomart')
       {
         var attr=$('#attribution').select2('val');
         var filter=$('#filter').val()
         if(filter=="")
         {
           sweetAlert('warning','Warning...','Select Input Gene Type!')
           return
         }
         if(attr=="")
         {
           sweetAlert('warning','Warning...','Select Attribution!')
           return
         }
         if($('#select_gene_source').val()=='custom')
         {
           var gene=$('#custom_select_gene').val()
           if(gene=='')
           {
             sweetAlert('warning','Warning...','Input Customer Genes!')
             return
           }
           gene=gene.stplit(" |\t|\n|\r\n|,|;")
         }
         else
         {
           var gene=select_gene
           if(gene=='')
           {
             sweetAlert('warning','Warning...','Select Genes!')
             return
           }
         }
         var obj={}
         obj['filter']=filter
         obj['attr']=attr
         obj['gene']=gene
         obj['stamp']=Math.random()
         Shiny.setInputValue('ensembl_gene_info',obj)
       }
       else
       {
         var count=parseInt($('#'+e.currentTarget.id).attr('count'));
         $('#'+e.currentTarget.id).attr('count',count+1);
         Shiny.setInputValue('onclick', '{"id":"'+e.currentTarget.id+'","count":'+$('#'+e.currentTarget.id).attr('count')+'}');

       }
    }
    else
    {
      var count=parseInt($('#'+e.currentTarget.id).attr('count'));
      $('#'+e.currentTarget.id).attr('count',count+1);
      Shiny.setInputValue('onclick', '{"id":"'+e.currentTarget.id+'","count":'+$('#'+e.currentTarget.id).attr('count')+'}');
    }
  });
  $('button.action-button[id*=choose]').on('click',function(e){
    Shiny.setInputValue('ensembl_info', '{"id":"'+e.currentTarget.id+'","count":'+Math.random()+'}');
  }); 
})
/*$(document).on('shiny:connected',function(){
  Shiny.setInputValue('attribution_update','{"count":'+Math.random()+'}');  
})
*/
create_modal=function()
{
  $modal=$('<div class="modal fade" id="infolist" role="dialog" aria-hidden="true"></div>');
  $diag=$('<div class="modal-dialog modal-lg"></div>');
  $content=$('<div class="modal-content"></div>');
  $header=$('<div class="modal-header"></div>');
  $title=$('<h4 class="modal-title" id="modaltitle"></h4>');
  $body=$('<div class="modal-body" id="modalbody"></div>');
  $table=$('<table id="modaltable"></table>');
  $foot=$('<div class="modal-footer"></div>');
  $close=$('<button type="button" class="btn btn-default" data-dismiss="modal">Close</button>');
  $submit=$('<button type="button" class="btn btn-primary" id="modalSubmit">OK</button>');
  $modal.append($diag);
  $diag.append($content);
  $content.append($header).append($body).append($foot);
  $header.append($title);
  $body.append($table);
  $foot.append($close).append($submit);
  /*$submit.on('click',function(e){
    if($('#infolist').attr('currenttarget')=='gene')
    {
      $('#'+$('#infolist').attr('currentTarget').toLowerCase()).val('Current Selected Gene#: '+select_gene.length)
      var obj={}
      obj['select_gene']=select_gene
      obj['stamp']=Math.random()
      Shiny.setInputValue('Update_Select_Gene',obj)
      return
    }
    if($('#infolist').attr('currenttarget')=='archieve')
      var value=$('#modaltable tr.selected>td:nth-child(4)').text();
    else
     var value=$('#modaltable tr.selected>td:nth-child(2)').text();
    if(value!="")
    {
     $('#'+$('#infolist').attr('currentTarget').toLowerCase()).val(value);
     $('#'+$('#infolist').attr('currentTarget').toLowerCase()).trigger('change');
    }
    if($('#infolist').attr('currenttarget')=='archieve'||$('#infolist').attr('currenttarget')=='database')
     Shiny.setInputValue('Update_Ensembl',Math.random())
  });*/
  $('body').append($modal);

}
Shiny.addCustomMessageHandler('reading',function(msg){
  if(msg.status=='ongoing')
  {
    $loading=$("<div class='overlay'></div>");
    $icon=$('<i></i>');
    $icon.attr('class','fa fa-refresh fa-spin');
    $loading.append($icon);
    $('#'+msg.div).append($loading);
  }
  else if(msg.status=='finish')
  {
    $('#'+msg.div+'>.overlay').remove();
  }
});
Shiny.addCustomMessageHandler('ensembl_database_info',function(msg){
  $('#infolist').attr('currenttarget','database');
  $('#modaltitle').text(msg.title);
  //var obj=JSON.parse(msg.body);
  $('#modalbody').empty();
  $('#modalbody').append($('<table id="modaltable"></table>'));
  $('#modaltable').bootstrapTable({
    columns:[{
      radio:true,
      clickToSelect:true
    },{
      field:'dataset',
      title:'Dataset',
      clickToSelect:true,
      align:'center',
      sortable:true,
    },{
      field:'description',
      title:'Description',
      clickToSelect:true,
      align:'center',
      sortable:true
    },{
      field:'version',
      title:'Version',
      clickToSelect:true,
      align:'center',
      sortable:true
    }],
    data:msg.body,
    striped:true,
    search:true,
    showPaginationSwitch:false,
    pagination:true,
    paginationLoop:true,
    clickToSelect:true
    //height: 500
  });
  $('#modalSubmit').off('click').on('click',function(e){
    var value=$('#modaltable tr.selected>td:nth-child(2)').text();
    if(value!="")
    {
     $('#'+$('#infolist').attr('currentTarget').toLowerCase()).val(value);
     $('#'+$('#infolist').attr('currentTarget').toLowerCase()).trigger('change');
    }
    hiddenModal()
    if($('#infolist').attr('currenttarget')=='archieve'||$('#infolist').attr('currenttarget')=='database')
      Shiny.setInputValue('Update_Ensembl',Math.random())
    
  })
  if(!$('#infolist').hasClass('in'))
  {
    $('#infolist').modal({backdrop: 'static', keyboard: false});
  }
   else
  {
    $('#infolist').modal('hide');
    $('#infolist').modal({backdrop: 'static', keyboard: false});
  }
})
Shiny.addCustomMessageHandler('ensembl_archieve_info',function(msg){
  $('#infolist').attr('currenttarget','archieve');
  $('#modaltitle').text(msg.title);
  $('#modalbody').empty();
  $('#modalbody').append($('<table id="modaltable"></table>'));
  $('#modaltable').bootstrapTable({
    columns:[{
      radio:true,
      clickToSelect:true
    },{
      field:'name',
      title:'Name',
      clickToSelect:true,
      align:'center',
      sortable:true
    },{
      field:'date',
      title:'Date',
      clickToSelect:true,
      align:'center',
      sortable:true
    },{
      field:'url',
      title:'URL',
      clickToSelect:true,
      align:'center',
      sortable:true
    },{
      field:'version',
      title:'Version',
      clickToSelect:true,
      align:'center',
      sortable:true
    }],
    data:msg.body,
    striped:true,
    search:true,
    showPaginationSwitch:false,
    pagination:true,
    paginationLoop:true,
    clickToSelect:true
    //height: 500
  });
  $('#modalSubmit').off('click').on('click',function(e){
    var value=$('#modaltable tr.selected>td:nth-child(4)').text();
    if(value!=="")
    {
     $('#'+$('#infolist').attr('currentTarget').toLowerCase()).val(value);
     $('#'+$('#infolist').attr('currentTarget').toLowerCase()).trigger('change');
    }
    $('#'+$('#infolist').attr('currentTarget').toLowerCase())
    hiddenModal()
    if($('#infolist').attr('currenttarget')=='archieve'||$('#infolist').attr('currenttarget')=='database')
     Shiny.setInputValue('Update_Ensembl',Math.random())
  })
  if(!$('#infolist').hasClass('in'))
  {
    $('#infolist').modal({backdrop: 'static', keyboard: false});
  }
   else
  {
    $('#infolist').modal('hide');
    $('#infolist').modal({backdrop: 'static', keyboard: false});
  }
})
Shiny.addCustomMessageHandler('ensembl_filter_info',function(msg){
  $('#infolist').attr('currenttarget','filter');
  $('#modaltitle').text(msg.title);
  $('#modalbody').empty();
  $('#modalbody').append($('<table id="modaltable"></table>'));
  $('#modaltable').bootstrapTable({
    columns:[{
      radio:true,
      clickToSelect:true
    },{
      field:'name',
      title:'Name',
      clickToSelect:true,
      align:'center',
      sortable:true
    },{
      field:'description',
      title:'Description',
      clickToSelect:true,
      align:'center',
      sortable:true
    }],
    data:msg.body,
    striped:true,
    search:true,
    showPaginationSwitch:false,
    pagination:true,
    paginationLoop:true,
    clickToSelect:true
    //height: 500
  });
  $('#modalSubmit').off('click').on('click',function(e){
    var value=$('#modaltable tr.selected>td:nth-child(2)').text();
    if(value!=="")
    {
     $('#'+$('#infolist').attr('currentTarget').toLowerCase()).val(value);
     $('#'+$('#infolist').attr('currentTarget').toLowerCase()).trigger('change');
    }
    hiddenModal()
  })
  if(!$('#infolist').hasClass('in'))
  {
    $('#infolist').modal({backdrop: 'static', keyboard: false});
  }
  else
  {
    !$('#infolist').modal('hide');
    $('#infolist').modal({backdrop: 'static', keyboard: false});
  }
})
Shiny.addCustomMessageHandler('filter_loading',function(msg){
  if(msg.status=='ongoing')
  {
    $('#'+msg.div).empty();
    $('#modaltitle').html("");
    $('#infolist button').css({ "display": "none" });
    $process=$("<div class='progress active'></div>");
    $icon=$('<div class="progress-bar progress-bar-primary progress-bar-striped" role="progressbar" aria-valuenow="40" aria-valuemin="0" aria-valuemax="100" style="width:100%">Connecting to Server...</div>');
    $process.append($icon);
    $('#'+msg.div).append($process);
    if(!$('#infolist').hasClass('in'))
    {
      $('#infolist').modal({backdrop: 'static', keyboard: false});
    }
    else
    {
      $('#infolist').modal('hide');
      $('#infolist').modal({backdrop: 'static', keyboard: false});
    }
  }
  else if(msg.status=='finish')
  {
    $('#'+msg.div+'>.progress').remove();
    $('#infolist').modal('hide')
    $('#infolist button').css({ "display": "inline" });
  }
});
Shiny.addCustomMessageHandler('attribution_list',function(msg){
  $('#attribution').select2({
    data:msg.results,
    multiple:true,
    //width:'500px',
    theme:'bootstrap',
    selectOnClose:true,
    allowClear:false,
    closeOnSelect:false,
    placeholder:"Select Input Gene Type..."
  })
})
Shiny.addCustomMessageHandler('select_gene',function(msg){
  while(select_gene.length>0)
  {
    select_gene.splice(0,1)
  }
  $('#infolist').attr('currenttarget','gene');
  $('#modaltitle').text(msg.title);
  $('#modalbody').empty();
  if(msg.body.all.length===0)
  {
    var obj={}
    obj['stamp']=Math.random()
    obj['type']='error'
    obj['title']='Error...'
    obj['text']='Please Upload Expression File!'
    Shiny.setInputValue('sweetAlert',obj)
  }
  else
  {
    $('#modalbody').append($('<div><table id="modaltable"></table></div>'));
    $('#modaltable').bootstrapTable({
      columns:[
        {
          checkbox:true,
          clickToSelect:true
        },
        {
          field:'gene',
          title:' Candidate Gene',
          clickToSelect:true,
          align:'center',
          sortable:true,
      }],
      data:msg.body.all,
      striped:true,
      search:true,
      pagination:false,
      clickToSelect:true,
      overflow: 'auto',
      height:550,
      onCheck:function(e,row){
        select_gene.push(e.gene)
        select_gene=$.unique(select_gene)
      },
      onUncheck:function(e,row)
      {
        select_gene.splice(select_gene.indexOf(e.gene),1)
      },
      onCheckAll:function(rowsAfter,rowsBefore){
        while(select_gene.length>0)
        {
          select_gene.splice(0,1)
        }
        $.each(rowsAfter,function(index,element){
          select_gene.push(element.gene)
        })
      },
      onUncheckAll:function(rowsAfter,rowsBefore){
        while(select_gene.length>0)
        {
          select_gene.splice(0,1)
        }
      }
    })
    $("#modalbody .fixed-height").css('padding-bottom','36px')
    $('#modalSubmit').on('click',function(e){
      $('#'+$('#infolist').attr('currentTarget').toLowerCase()).val('Current Selected Gene#: '+select_gene.length)
      var obj={}
      obj['select_gene']=select_gene
      obj['stamp']=Math.random()
      Shiny.setInputValue('Update_Select_Gene',obj)
    })
    if(!$('#infolist').hasClass('in'))
    {
      $('#infolist').modal({backdrop: 'static', keyboard: false});
    }
    else
    {
      $('#infolist').modal({backdrop: 'static', keyboard: false});
    }
  }
})
Shiny.addCustomMessageHandler('geneinfo',function(msg){
  alert(msg)
})
Shiny.addCustomMessageHandler('connect_biomart',function(msg){
  if(msg=="connection")
  {
    showModal()
    $(".modal-footer").css("visibility","hidden")
  }
  else if (msg=="finish")
  {
    hiddenModal()
    $(".modal-footer").removeAttr("style","")
  }
})
sweetAlert=function(type,title,text)
{
  var obj={}
  obj['stamp']=Math.random()
  obj['type']=type
  obj['title']=title
  obj['text']=text
  Shiny.setInputValue('sweetAlert',obj)
}
showModal=function()
{
  if(!$('#infolist').hasClass('in'))
  {
    $('#infolist').modal({backdrop: 'static', keyboard: false});
  }
   else
  {
    $('#infolist').modal('hide');
    $('#infolist').modal({backdrop: 'static', keyboard: false});
  }
}
hiddenModal=function()
{
  $('#infolist').modal('hide')
  $('#infolist button').css({ "display": "inline" });
}
next_tab=function(id)
{
  $('a[href="'+id+'"').trigger('click')
}