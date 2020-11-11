$(document).ready(function(){
  $("a[href='#shiny-tab-analysis']").on("click",function(e){
    Shiny.setInputValue("initialization_enrichment",Math.random());

  });
   $("#custom_preview_panel").parent().css({'overflow':'auto','height':'370px'});
})

function showNodeCentrality(box)
{
  var values=[]
  $("input[name='"+$(box).attr("name")+"']:checked").each(function(i,ele){
    values.push($(ele).val())
  })
  var obj={}
  obj['stamp']=Math.random()
  obj['value']=values
  Shiny.setInputValue("nodeCentrality",obj)
}

function showEdgeCentrality(box)
{
  var values=[]
  $("input[name='"+$(box).attr("name")+"']:checked").each(function(i,ele){
    values.push($(ele).val())
  })
  var obj={}
  obj['stamp']=Math.random()
  obj['value']=values
  Shiny.setInputValue("edgeCentrality",obj)
}

function nodeDetails(btn)
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
   $("#modalSubmit").off("click").on('click',function(e){
      $('#infolist').modal('hide');
   })
  Shiny.setInputValue("nodeDetails",Math.random())
  Shiny.addCustomMessageHandler("nodeDetails",function(e){

  })
}
function edgeDetails(btn)
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
   $("#modalSubmit").off("click").on('click',function(e){
      $('#infolist').modal('hide');
   })
  Shiny.setInputValue("edgeDetails",Math.random())
}

function run_community_detection(obj)
{
  Shiny.setInputValue("community_detection",Math.random())
}

function communityDetail(id)
{
  var obj={};
  obj['stamp']=Math.random();
  obj['moduleid']=id
  Shiny.setInputValue("communityDetals",obj)
   if(!$('#infolist').hasClass('in'))
   {
      $('#infolist').modal({backdrop: 'static', keyboard: false});
   }
   else
   {
    $('#infolist').modal('hide');
    $('#infolist').modal({backdrop: 'static', keyboard: false});
   }
   $("#modalSubmit").off("click").on('click',function(e){
      $('#infolist').modal('hide');
   })
}
function communityEdgeDetail(id)
{
  var obj={};
  obj['stamp']=Math.random();
  obj['moduleid']=id
  Shiny.setInputValue("communityEdgeDetals",obj)
   if(!$('#infolist').hasClass('in'))
   {
      $('#infolist').modal({backdrop: 'static', keyboard: false});
   }
   else
   {
    $('#infolist').modal('hide');
    $('#infolist').modal({backdrop: 'static', keyboard: false});
   }
   $("#modalSubmit").off("click").on('click',function(e){
      $('#infolist').modal('hide');
   })
}

function displayCommunity(id)
{
  var obj={};
  obj['stamp']=Math.random();
  obj['moduleid']=id
  Shiny.setInputValue("displayCommunity",obj)
}

function export_enrichment_plot(e)
{
  var obj={}
  obj['stamp']=Math.random()
  var picid=[]
  var $pic=$(e).parent().prev().find('.col-lg-6').children('div')
  for(var i=0;i<$pic.length;++i)
  {
    picid.push($pic.get(i).getAttribute('id'))
  }
  obj['picid']=picid
  obj['id']=$(e).attr('id')
  Shiny.setInputValue("export_enrichment_plot",obj)
}
function export_survival_plot(id,model)
{
  var obj={}
  obj['stamp']=Math.random()
  obj['id']=id
  obj['model']=model
  Shiny.setInputValue("export_survival_plot",obj)
}
function module_setting(btn)
{
  var id=$(btn).attr("id")
  id=id.replace(/_setting$/,"")
  var obj={}
  obj['stamp']=Math.random()
  obj['id']=id
  Shiny.setInputValue("module_setting",obj)
  if(!$('#infolist').hasClass('in'))
  {
    $('#infolist').modal({backdrop: 'static', keyboard: false});
  }
  else
  {
    $('#infolist').modal('hide');
    $('#infolist').modal({backdrop: 'static', keyboard: false});
  }
  $("#modalSubmit").off('click').on("click",function(e){
    var obj={}
    obj['stamp']=Math.random()
    obj['id']=id
    Shiny.setInputValue("Update_community_style",obj)
    $("#infolist").modal("hide")
  })
}

function survival(obj)
{
  Shiny.setInputValue("execute_survival",Math.random())
}

function showCustomGeneDetails(obj){

  var name=$(obj).parent().parent().children(":first-child").html()
  var temp={}
  temp['stamp']=Math.random()
  temp['id']=name
  Shiny.setInputValue("showCustomDetails",temp)
}

Shiny.addCustomMessageHandler("update_progress_state",function(msg){
  $('#'+msg.id).find('span').html(msg.value)
})

function demo_clinical()
{
  var obj={}
  obj['stamp']=Math.random()
  Shiny.setInputValue("demo_clinic",obj)
}
function run_parameter_choose(obj)
{
  Shiny.setInputValue("community_parameter_test",Math.random())
}
function run_parameter_test(para)
{
  var obj={}
  obj['stamp']=Math.random()
  obj['algorithm']=para
  Shiny.setInputValue("run_parameter_test",obj)
}

Shiny.addCustomMessageHandler("show_community_parameter_test_modal",function(msg){
  showModal()
  $(".modal-footer").css("visibility","visible")
})

Shiny.addCustomMessageHandler("test_parameter_status",function(msg){
  if(msg.status=='run')
  {
    $("#modalSubmit").attr('disabled','true')
    $("#modalSubmit").next().attr('disabled','true')
    if($("#modalbody>div.row").length!=2)
    {
      var $row=$("<div class='row'>")
      var $col=$("<div class='col-lg-12'>")
      var $progress=$("<div class='progress active'>")
      var $style=$("<div class='progress-bar progress-bar-success progress-bar-striped'>")
      $style.css('width',msg.progress+"%")
      var $label=$("<span>")
      $label.html(msg.info)
      $style.append($label)
      $progress.append($style)
      $col.append($progress)
      $row.append($col)
      $("#modalbody").append($row)
    }
    else
    {
      $("#modalbody").find("div.progress-bar>span").html(msg.info)
      $("#modalbody").find("div.progress-bar").css('width',msg.progress+"%")
    }
  }
  else
  {
    $("#modalSubmit").attr('disabled','false')
    $("#modalSubmit").next().attr('disabled','false')
    $("#modalbody").find("div.progress-bar>span").html(msg.info)
    $("#modalbody").find("div.progress-bar").css('width',msg.progress+"%")
    $("#modalbody").find("div.progress").removeClass('active')
    $("#modalSubmit").attr('disabled',false)
    $("#modalSubmit").next().attr('disabled',false)
  }

})

