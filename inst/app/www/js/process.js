var biotype_group=new Map();
var remain=[];
$(document).ready(function(){
  creat_geneFilter("MicroRNA filter","microFilterPlot","micro");
  $("a[href='#shiny-tab-process']").on("click",function(e){
    Shiny.setInputValue("interclick",Math.random());
    Shiny.addCustomMessageHandler('Valid-Num', function(Num1) {
        $("#Rnaoutput").find("h3").text(Num1["rnaNum"]);
        $("#MicroRnaoutput").find("h3").text(Num1["microNum"]);
        $("#Sampleoutput").find("h3").text(Num1["sampleNum"]);
      });
    Shiny.setInputValue('Update_Biotype_Map',Math.random());
  });
  Shiny.addCustomMessageHandler('Valid_valuebox_micro', function(Num1) {
        $("#MicroRnaoutput").find("h3").text(Num1["microNum"]);
      });
  Shiny.addCustomMessageHandler('Valid_valuebox_rna', function(Num1) {
        $("#Rnaoutput").find("h3").text(Num1["rnaNum"]);
      });
  Shiny.addCustomMessageHandler('Valid_valuebox_sample', function(Num1) {
        $("#Sampleoutput").find("h3").text(Num1["sampleNum"]);
      });
  $('.value_BoxInput a').on("click",function(e){
    var obj={}
    obj['stamp']=Math.random()
    obj['id']=e.currentTarget.parentNode.parentNode.id
    Shiny.setInputValue("process_showdetails",obj)
    Shiny.addCustomMessageHandler('outdetails', function(msg) {
      $('#modaltitle').text(msg.title);
      $('#modalbody').empty();
      $('#modalSubmit').off('click').on('click',function(e){
         $('#infolist').modal('hide');
      })
      if(msg.details.length==0)
      {
        var obj={}
        obj['stamp']=Math.random()
        obj['type']='error'
        obj['title']='Error...'
        obj['text']='Data Not Exist!'
        Shiny.setInputValue('sweetAlert',obj)
      }
      else
      {
        $('#modalbody').append($('<div><table id="modaltable"></table></div>'));
        $('#modaltable').bootstrapTable({
          columns:[
            {
              field:'detail',
              title:msg.title,
              align:'center',
              sortable:true,
          }],
          data:msg.details,
          striped:true,
          search:true,
          pagination:true,
          clickToSelect:true,
          overflow: 'auto'
        })
        $("#modalbody .fixed-height").css('padding-bottom','36px')
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
      
    });
  });
  $("#add_group").on('click',function(e){
    var value=$("#new_group_name").val();
    if(value==="")
    {
      sweetAlert('warning','Warning','Please Input New Group Name!');
      return;
    }
    if(value.indexOf(" ")>=0)
    {
      sweetAlert('info','Note','All Blank will be replaced by "_"');
    }
    value=value.replace(/ /,"_")
    var $group=addGroup(value,false);
    $("#new_group_name").val("");
    $group.trigger('click')
  });
  $('#biotype_group_statics').on('click',function(e){
    function strMapToObj(strMap){
      let obj = Object.create(null);
      for (let [k,v] of strMap) {
        obj[k] = v;
      }
      return obj;
    }
    var obj={};
    obj['stamp']=Math.random();
    var t=strMapToObj(biotype_group);
    var total=0
    for(var key in t)
      total=total+t[key].length
    if(total==0)
    {
      $('#candidate_biotype li>label').trigger('click')
      t=strMapToObj(biotype_group);
    }
    obj['data']=t
    if($('input:radio[name="biotype_map"]:checked').length>0)
    {
      obj['biotype']=$('input:radio[name="biotype_map"]:checked').val()
    }
    else
    {
      obj['biotype']=null
    }
    Shiny.setInputValue('show_biotype_group',obj)
    Shiny.setInputValue('creatFilter_request',Math.random())
  })
  
  $('#Sample_Filter_all').append(creat_sampleFilter("MicroRNA Sample Filter","micro_invalid_name"));
  $('#Sample_Filter_all').append(creat_sampleFilter("CeRNA Sample Filter","ce_invalid_name"));
})
create_editor=function(value)
{
  $span=$('<span class="editable-container editable-inline"></span>')
  $div=$('<div></div>')
  $form=$('<form class="form-inline editableform"></form>')
  $control=$('<div class="form-inline editableform"><div></div></div>')
  $form.append($control)
  $control=$control.children('div')
  $input=$('<div class="editable-input" style="position: relative;"><input class="form-control input-sm" type="text" style="padding-right: 24px;" value="'+value+'"></div>')
  $buttons=$('<div class="editable-buttons"></div>')
  $submit=$('<button class="btn btn-success btn-sm editable-submit" type="submit"><i class="glyphicon glyphicon-ok"></i></button>')
  $submit.on('click',function(e){
    var value=$(e.currentTarget).parent().parent().parent().parent().parent().parent().prev().children('b').html()
    var currentvalue=$(e.currentTarget).parent().prev().children('input').val()
    currentvalue=currentvalue.replace(/ /,"_")
    if(currentvalue=="")
    {
      sweetAlert('error','Error..','Group Name Can\' be Empty!');
      return
    }
    if(currentvalue==value)
    {
      sweetAlert('warning','Warning','Group Name Not Changed');
      return
    }
    if(biotype_group.has(currentvalue))
    {
      sweetAlert('warning','Warning','Group Name Has existed');
      return
    }
    if(currentvalue.indexOf(" ")>=0)
    {
      sweetAlert('info','Note','All Blank will be replaced by "_"');
    }
    var v=biotype_group.get(value)
    biotype_group.delete(value)
    biotype_group.set(currentvalue,v)
    $(e.currentTarget).parent().parent().parent().parent().parent().parent().prev().children('b').html(currentvalue)
    $(e.currentTarget).next().trigger('click')
  })
  $close=$('<button class="btn btn-default btn-sm editable-cancel" type="submit"><i class="glyphicon glyphicon-remove"></i></button>')
  $close.on('click',function(e){
    $(e.currentTarget).parent().parent().parent().parent().parent().parent().prev().removeClass('editable-open')
    $(e.currentTarget).parent().parent().parent().parent().parent().parent().prev().css('display','')
    $(e.currentTarget).parent().parent().parent().parent().parent().parent().remove()
  })
  $buttons.append($submit).append($close)
  $control.append($input).append($buttons)
  $div.append($form)
  $span.append($div)
  return $span
  
}
addGroup=function(name,selected)
{
  if(biotype_group.has(name))
  {
    sweetAlert('warning','Warning','This Group Has Existed');
    return;
  }
  if(selected)
  {
    $group=$('<a class="item"><b>'+name+'</b></a>');
    $group.css('color','#000000');
  }
  else
  {
    $group=$('<a class="item editable editable-click" style="color:#847979"><b>'+name+'</b></a>');
  }
  $group.on('click',function(e){
    $('#group_biotype a').css('color','#847979');
    $(e.currentTarget).css('color','#000000');
    $('#group_biotype li').attr('class','')
    $(e.currentTarget).parent().addClass('selected')
  })
  
  $tools=$('<div class="tools"></div>')
  $editor=$('<i class="fa fa-edit" style="color:#00a65a"></i>')
  $editor.on('click',function(e){
    $(e.currentTarget).parent().parent().addClass('editable-open')
    $(e.currentTarget).parent().parent().css('display','none')
    var value=$(e.currentTarget).parent().prev().html()
    $editor=create_editor(value)
    $(e.currentTarget).parent().parent().after($editor)
  })
  $delete=$('<i class="fa fa-trash-o" style="color:#00a65a"></i>')
  $delete.on('click',function(e){
    var value=$(e.currentTarget).parent().prev().html()
    if(biotype_group.size==1)
    {
      sweetAlert('warning','Warning','Remain At least One Group!');
      return
    }
    var biotype=biotype_group.get(value)
    for(var i=0;i<biotype.length;++i)
    {
      $('#'+biotype[i]).css('display','')
      $('#'+biotype[i]).iCheck('uncheck')
    }
    biotype_group.delete(value)
    if($(e.currentTarget).parent().parent().parent().prev().length==0)
    {
      $(e.currentTarget).parent().parent().parent().next().children('a').trigger('click')
    }
    else
    {
      $(e.currentTarget).parent().parent().parent().prev().children('a').trigger('click')
    }
    $(e.currentTarget).parent().parent().parent().remove()
  })
  $group.append($tools.append($editor).append($delete))
  if(selected)
  {
    $('#group_biotype ul').append($('<li class="selected" style="padding:2px"></li>').append($group));
  }
  else
  {
    $('#group_biotype ul').append($('<li style="padding:2px"></li>').append($group));
  }
  biotype_group.set(name,[]);
  return($group)
}

Shiny.addCustomMessageHandler('update_candidate_biotype',function(msg){
  $('#group_biotype').empty();
  $('#group_biotype').append($('<div class="header">Groups</div>'))
  biotype_group.clear()
  remain=msg.item;
  $('#group_biotype').append($('<ul class="todo-list"></ul>'))
  addGroup('Default',true);
  
  $('#candidate_biotype').empty();
  $('#candidate_biotype').append($('<div class="header">Candidate Items</div>'))
  $("#candidate_biotype").append($('<ul style="list-style:none;padding:0px"></ul>'));
  if(msg.signal=='invalid')
  {
    sweetAlert("error",'Error...','No Valid Mapping Columns!')
    return
  }
  for(var biotype in remain)
  {
    $checkbox=$('<label><input type="checkbox"></label>');
    $checkbox.attr('id',msg.item[biotype]);
    $checkbox.iCheck({
      checkboxClass:'icheckbox_line-red',
      insert:'<div class="icheck_line-icon"></div>'+msg.item[biotype]
    });
    $checkbox.on('ifChecked',function(e){
       var key=$('#group_biotype li.selected b').html()
       if(typeof key=='undefined')
       {
          sweetAlert('warning','Warning','Please Select a Group!');
          return;
       }
       //$(e.currentTarget).find('.icheckbox_line-red').attr('class','icheckbox_line-green');
       biotype_group.get(key).push($(e.currentTarget).attr('id'));
       var $new = $(e.currentTarget).clone();
       $(e.currentTarget).css('display','none')
       $new.children().attr('class','icheckbox_line-green checked')
       $new.attr('id',"grouped_"+$new.attr("id"))
       $new.attr('for',key)
       $new.on('click',function(e){
         $(e.currentTarget).parent().children('a').trigger('click')
         var id=$(e.currentTarget).attr('id')
         var type=id.substring(id.indexOf('_')+1)
         $('#'+type).css('display','')
         $('#'+type).iCheck('uncheck')
         $(e.currentTarget).remove()
         var key=$(e.currentTarget).attr('for')
         biotype_group.get(key).splice(biotype_group.get(key).indexOf(type),1)
       })
       $('#group_biotype li.selected').append($new)
    })
   /* $checkbox.on('ifUnchecked',function(e){
        $(e.currentTarget).find('.icheckbox_line-green').attr('class','icheckbox_line-red');
        var key=$('#group_biotype a[style="color: rgb(0, 0, 0);"] b').html();
        biotype_group.get(key).splice(biotype_group.get(key).indexOf($(e.currentTarget).attr('id')),1);
    });*/
    $('#candidate_biotype ul').append($('<li></li>').append($checkbox));
  }
  
})
Shiny.addCustomMessageHandler('invalidColumn',function(msg){
  var choice=msg.choice
  async function demoSleep(ms) 
  {
    console.log('Taking a break...');
    await sleep(ms);
    console.log('Two seconds later, showing sleep in a loop...');
    for(var i=0;i<choice.length;++i)
    {
    $('#biotype_map input[value="'+choice[i]+'"]').attr('disabled',true)
    }
    if(choice.indexOf($('input:radio[name="biotype_map"]:checked').val())>=0)
    {
      $('input:radio[name="biotype_map"]:checked').prop('checked', false);
    }
  }
  demoSleep(100)
})

function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}


