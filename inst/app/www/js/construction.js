var conditons
var condition_status={}
$(document).ready(function(){
  $("#add_new_condition").on('click',function(e){
    var obj={}
    obj['stamp']=Math.random()
    Shiny.setInputValue('add_new_condition',obj)
    $('#modalSubmit').off('click').on('click',function(e){
      var description=$('#custom_condition_description').val()
      var abbr=$('#custom_condition_abbr').val()
      var code=$('#custom_condition_code').val()
      var core=$('#use_core').val()
      var tasks=$('#group_pairs').val()
      var type=$('#condition_type').val()
      if(tasks==null)
      {
        sweetAlert('warning','Warning..','Select Group Pairs!')
        return
      }
      check=function(id,candidate)
      {
        $('#'+id).parent().children('i').remove()
        if($('#'+id).val()=="")
        {
          var $error=$('<i class= "fa fa-close text-red">Empty!</i>')
          $('#'+id).parent().append($error)
        }
        else if(candidate!=null&&candidate.indexOf($('#'+id).val())>=0)
        {
          var $error=$('<i class= "fa fa-close text-red">Existed!</i>')
          $('#'+id).parent().append($error)
        }
        else
        {
          var ok=$('<i class= "fa fa-check text-green">OK</i>')
          $('#'+id).parent().append(ok)
        }
      }
      check('custom_condition_abbr',conditions.abbr)
      check('custom_condition_description',conditions.description)
      check('custom_condition_code',null)
      //自定义检???
      if($('#condition_type').val()=='custom')
      {
        if($('#modalbody .text-red').length>0)
        {
          sweetAlert('warning','Warning..','Invalid Input')
          return
        }
        else
        {
          var obj={}
          obj['stamp']=Math.random()          
          obj['type']='custom'
          obj['description']=description
          obj['abbr']=abbr
          code=abbr+"="+code.substring(code.indexOf("function("))
          obj['code']=code
        }
      }
      else
      {
        var obj={}
        obj['stamp']=Math.random()          
        obj['type']=$('#condition_type').val()
      }
      
      if(tasks.indexOf('all')>=0)
      {
        tasks='all'
      }
      if($('#body_'+type).length>0)
      {
        $('#core_'+type).text(" Cores:"+core)
        if(tasks instanceof Array)
        {
          $('#task_'+type).text(" Tasks:0/"+tasks.length)
          $('#body_'+type).attr("tasks",tasks.join(";"))
        }
        else
        {
          $('#task_'+type).text(" Tasks:0/1")
          $('#body_'+type).attr("tasks",tasks)
        }
        //$("#density_plot_"+type).parent().remove()
        //var $box2=create_condition_plot($('#condition_type').val(),tasks)
        //$("#condition_preview").append($("<div class='col-lg-12'></div>").append($box2))

      }
      else
      {
        if($('#condition_type').val()=='custom')
        {
          var $box=create_condition($('#custom_condition_abbr').val(),tasks,core)
          //var $box2=create_condition_plot($('#custom_condition_abbr').val(),tasks)
        }
        else
        {
          var $box=create_condition($('#condition_type').val(),tasks,core)
          //var $box2=create_condition_plot($('#condition_type').val(),tasks)
        }
        $('#condition_panel').append($("<div class='col-lg-4'></div>").append($box))
        //$("#condition_preview").append($("<div class='col-lg-12'></div>").append($box2))
      }
      
      obj['core']=core
      obj['tasks']=tasks
      
      $('#infolist').modal('hide');
      Shiny.setInputValue('choose_new_condition',obj)
      var obj2={}
      obj2['stamp']=Math.random()
      if(type=='custom')
      {
        obj2['type']=abbr
      }
      else
      {
        obj2['type']=type
      }
      obj2['tasks']=tasks
      Shiny.setInputValue("condition_filter_response",obj2)
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
  $("#network_construction").on('click',function(e){
    var obj={}
    obj['stamp']=Math.random()
    Shiny.setInputValue('construct_network',obj)
  })
  $("a[href='#shiny-tab-construction']").on('click',function(e){
    Shiny.setInputValue("construction_data_confirm",Math.random())
  })
})
create_condition=function(name,tasks,core)
{
  var $box=$('<div class="info-box bg-red" id="body_'+name+'"></div>')
  if(tasks instanceof Array)
  {
    $box.attr('tasks',tasks.join(";"))
  }
  else
  {
     $box.attr('tasks',tasks)
  }
  var $left=$('<span class="info-box-icon" id="icon_'+name+'"><a href="#"><i class="fa fa-play" style="color:#fff"></i></a></span>')
  var $right=$('<div class="info-box-content"></div>')
  var $title=$('<span class="info-box-number">'+name+'</span>')
  var $remove=$('<div style="float:right"><a href="#"><i class="fa fa-times" style="color:#fff"></i></a></div>')
  var $taskpanel=$('<span class="info-box-text" style="text-transform:none;"></span>')
  var $task=$('<a href="#" style="color:#fff;padding-right:5px"><i class="fa fa-tasks" id="task_'+name+'" style="text-decoration:underline;"> Tasks:0\/'+ $box.attr('tasks').split(';').length+'</i></a>')
  var $core=$('<a href="#" style="color:#fff;padding-left:5px"><i class="fas fa-microchip" id="core_'+name+'" style="text-decoration:underline;"> Cores:'+core+"</a>")
  $taskpanel.append($task).append($core)
  var $progress=$('<div class="progress"><div class="progress-bar" id="progress_'+name+'" style="width:0%"></div></div>')
  var $eta=$('<span class="progress-description" id="eta_'+name+'"></span>')
  $task.on('click',function(e){
    var $current=$(e.currentTarget)
    var type=$current.parent().prev().text()
    var tasks=$current.parent().parent().parent().attr("tasks").split(";")
    var core=$current.next().children().text()
    var obj={}
    obj['stamp']=Math.random()
    obj['type']=type
    obj['tasks']=tasks
    obj['core']=core
    Shiny.setInputValue('add_new_condition',obj)
    
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
  $core.on('click',function(e){
    var $current=$(e.currentTarget)
    var type=$current.parent().prev().text()
    var tasks=$current.parent().parent().parent().attr("tasks").split(";")
    var core=$current.next().children().text()
    var obj={}
    obj['stamp']=Math.random()
    obj['type']=type
    obj['tasks']=tasks
    obj['core']=core
    Shiny.setInputValue('add_new_condition',obj)
    
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
  $left.children('a').on('click',function(e){
    if($("#"+$(e.currentTarget).parent().attr("id").replace(/icon/,"task")).text()==" Tasks:0/0")
    {
      sweetAlert('error','Error..','Non Tasks!')
      return
    }
    if($("#"+$(e.currentTarget).parent().attr("id").replace(/icon/,"core")).text()==" Cores:0")
    {
      sweetAlert('error','Error..','Non Cores!')
      return
    }
    $(e.currentTarget).parent().parent().attr('class','info-box bg-yellow')
    $(e.currentTarget).children("i").attr("class","fa fa-spinner fa-pulse")
    var obj={}
    obj['stamp']=Math.random()
    obj['type']=$(e.currentTarget).parent().attr("id").replace(/icon_/,"")
    Shiny.setInputValue("compute_condition",obj)
    condition_status[obj['type']]='run'
    updateState(obj['type'])
  })
  $remove.children('a').on('click',function(e){
    var id=$(e.currentTarget).parent().parent().parent().parent().attr('id')
    var type=id.substr(id.indexOf('_')+1)
    var obj={}
    obj['stamp']=Math.random()
    obj['type']=type
    condition_status[type]='stop'
    Shiny.setInputValue('remove_condition',obj)
    $(e.currentTarget).parent().parent().parent().parent().parent().remove()
    //$("#density_plot_"+type).parent().remove()
  })
  $box.append($left).append($right)//.append($go)
  $right.append($title).append($taskpanel).append($progress).append($eta)
  $title.append($remove)
  return($box)
}
create_condition_plot=function(name,tasks)
{
  var $box=$("<div></div>")
  $box.attr("class",'box box-primary')
  $box.attr("id","density_plot_"+name)
  var $head=$("<div></div>")
  $head.attr("class","box-header with-border")
  var $title=$("<h4>"+name+"</h4>")
  var $tool=$("<div></div>")
  $tool.attr("class","box-tools pull-right")
  var $icon=$("<button class='btn btn-box-tool' type='button' data-widget='collapse'><i class='fa fa-minus'></i></button>")
  var $body=$("<div></div>")
  $body.attr("class","box-body")
  
  $tool.append($icon)
  $head.append($title).append($tool)
  $box.append($head).append($body)
  
  if(tasks instanceof Array)
  {
    for(var i=0;i<tasks.length;++i)
    {
      var task=tasks[i]
      var $task_plot=$("<div class='col-lg-4'></div>")
      $task_plot.attr("id","density_plot_"+name+"_"+task)
      $body.append($task_plot)
    }
  }
  else
  {
    var $task_plot=$("<div class='col-lg-4'></div>")
    $task_plot.attr("id","density_plot_"+name+"_"+tasks)
    $body.append($task_plot)
  }
  return($box)
}

step_change=function(e)
{
  if($(e).children('i').attr("class")=="fa fa-plus")
  {
    var currentvalue=parseFloat($(e).parent().prev().val())
    var step=parseFloat($(e).parent().parent().parent().prev().children("input").val())
    var newvalue=currentvalue+step
    $(e).parent().prev().val(newvalue)
    $(e).parent().prev().trigger("onchange")
  }
  else
  {
    var currentvalue=parseFloat($(e).parent().next().val())
    var step=parseFloat($(e).parent().parent().parent().prev().children("input").val())
    var newvalue=currentvalue-step
    $(e).parent().next().val(newvalue)
    $(e).parent().next().trigger("onchange")
  }
  
}

thresh_change=function(e)
{
  var obj={}
  obj['stamp']=Math.random()
  obj['value']=parseFloat($(e).val())
  obj['type']=$(e).parent().parent().parent().parent().attr('type')
  obj['task']=$(e).parent().parent().parent().parent().attr('task')
  Shiny.setInputValue("update_condition_thresh",obj)
}

Shiny.addCustomMessageHandler("clear_construction_task",function(msg){
  var $select_conditions=$('#condition_panel').children()
  /*for(var i=0;i<$select_conditions.length;++i)
  {
    var $cur=$($select_conditions.get(i)).children("div")
    $cur.attr('tasks',"")
    $("#"+$cur.attr("id").replace(/^body/,"task")).text(' Tasks:0/0')
    $cur.children('span').children('a').children('i').attr('class','fa fa-play')
    $cur.attr('class','info-box bg-red')
  }*/
  $select_conditions.each(function(index,ele){
    $(ele).find("i.fa-times").parent().trigger('click')
  })
  
})

Shiny.addCustomMessageHandler('conditions',function(msg){
  conditions=msg
})

Shiny.addCustomMessageHandler('calculation_eta',function(msg){
  $("#eta_"+msg.type).html(msg.msg)
  condition_status[msg.type]=msg.status
  $("#progress_"+msg.type).css("width",msg.progress)
  $("#task_"+msg.type).text(" Tasks:"+msg.complete)
  if(msg.status=='stop')
  {
    $('#body_'+msg.type).attr('class','info-box bg-green')
    $("#progress_"+msg.type).css("width",msg.progress)
    $('#icon_'+msg.type).find('i').attr('class','fa fa-check')
    var obj={}
    obj['stamp']=Math.random()
    obj['type']=msg.type
    Shiny.setInputValue('condition_finish',obj)
  }
})
Shiny.addCustomMessageHandler('distribution_plot',function(msg){
  if(msg.status=='finish')
  {
    $('#'+msg.id).css("visibility",'hidden');
  }
  else if(msg.status=='update')
  {
    $('#'+msg.id).css("visibility",'visible');
    $('#'+msg.id).find('span').html(msg.value)
  }
})

Shiny.addCustomMessageHandler('network_construction',function(msg){
  if(msg.status=='update')
  {
    if(!$('#infolist').hasClass('in'))
    {
      showModal()
      $('.modal-footer').css('visibility','hidden')
    }
    $('#'+msg.id).find('span').html(msg.value)
  }
  else if(msg.status=='finish')
  {
    hiddenModal()
    $('.modal-footer').css('visibility','visible')
  }
})

comfirm_thresh=function(e)
{
  var $thresh_panel=$(e).parent().prev()
  
  var threshs={}
  var type=""
  var flag=true
  $thresh_panel.children().each(function(i,ele){
    type=$(ele).attr("type")
    var task=$(ele).attr('task')
    var t={}
    var thresh=$("#thresh_"+type+"_"+task).children('input').val()
    var direction=$(ele).find('select').val()
    t['direction']=direction
    t['thresh']=thresh
    if(typeof(direction)=="undefined"||typeof(thresh)=="undefined")
    {
      flag=false
    }
    threshs[task]=t
  })
  var obj={}
  obj['stamp']=Math.random()
  obj['type']=type
  obj['thresh']=threshs
  if(flag)
  {
    Shiny.setInputValue("add_condition_thresh",obj)
    if($(e).parent().parent().children(":first").find('h4>small').length==0)
    {
      $(e).parent().parent().children(":first").find('h4').append($("<small class='badge bg-green'>Added</small>"))
    }
  }
  else
  {
    sweetAlert('warning','Warning..','Please Wait for Computation!')
  }
}
cancel_thresh=function(e)
{
  var $thresh_panel=$(e).parent().prev()
  $(e).parent().parent().children(":first").find('h4>small').remove()
  var type=$thresh_panel.children(":first").attr('type')
  var obj={}
  obj['stamp']=Math.random()
  obj['type']=type
  Shiny.setInputValue("cancel_condition_thresh",obj)
}
async function updateState(type)
{
  var obj={}
  obj['type']=type
  while(condition_status[type]!='stop')
  {
    console.log("check"+type)
    obj['stamp']=Math.random()
    Shiny.setInputValue('compute_status',obj)
    await sleep(5000)
  }
}
