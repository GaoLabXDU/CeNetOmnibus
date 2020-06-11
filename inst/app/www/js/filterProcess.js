var rna_log_transform = ""
var rna_norm_transform = ""
var micro_log_transform = ""
var micro_norm_transform = ""

$(document).ready(function(){
  //slice button
  $("#gene_slice_all").on('click',function(e){
    var obj = {}
    obj['stamp'] = Math.random();
    Shiny.setInputValue('Gene_Slice_Signal',obj);
  })
  creat_logtrans_button("log2","Log2","Log2 conversion of gene expression data");
  creat_logtrans_button("log","Loge","Log conversion of gene expression data");
  creat_logtrans_button("log10","Log10","Log10 conversion of gene expression data");
  creat_logtrans_button_micro("log2","Log2","Log2 conversion of gene expression data");
  creat_logtrans_button_micro("log","Loge","Log conversion of gene expression data");
  creat_logtrans_button_micro("log10","Log10","Log10 conversion of gene expression data");
  creat_normtrans_button("Min_Max_scaling","Min_Max_scaling","Do Min-max normalization By x* = (x - x_mean)/(x_max - x_min)");
  creat_normtrans_button("Zero_Mean_normalization","Zero_Mean","The processed data conforms to the standard normal distribution By x*=(x - mean)/Standard deviation");
  creat_normtrans_button_custom("Custom_input","Custom","custom input a function");
  creat_normtrans_button_micro("Min_Max_scaling","Min_Max_scaling","Do Min-max normalization By x* = (x - x_mean)/(x_max - x_min)");
  creat_normtrans_button_micro("Zero_Mean_normalization","Zero_Mean","The processed data conforms to the standard normal distribution By x*=(x - mean)/Standard deviation");
  creat_normtrans_button_micro_custom("Custom_input","Custom","custom input a function");
  var $button_ce_action =$('<a class="btn btn-app btn-info" style="margin:5px;color:#00a65a"><i class="fa fa-play"></i>Action</a>')
  var $button_ce_cancel =$('<a class="btn btn-app btn-info" style="margin:5px;color:#dd4b39"><i class="fa fa-stop"></i>Cancel</a>')
  $("#ceRNA_choose_transfunction").children(":nth-child(4)").append($button_ce_action).append($button_ce_cancel);
  $button_ce_action.on('click',function(e){
    var obj={}
    obj['stamp']=Math.random();
    obj['log_trans']=rna_log_transform;
    obj['norm_trans']=rna_norm_transform;
    Shiny.setInputValue('ceRNA_Transform_Signal',obj)
  })
  $button_ce_cancel.on('click',function(e){
    rna_log_transform = ""
    rna_norm_transform = ""
    if($("#ceRNA_choose_transfunction").find("span.badge").length>0){
      $("#ceRNA_choose_transfunction").find("span.badge").remove();
      var obj={}
      obj['stamp']=Math.random();
      Shiny.setInputValue('Cancel_ceRNA_data_show',obj)
    }else{
      sweetAlert("warning","Warning","No Action Executed!")
    }
    
  })
  var $button_micro_action =$('<a class="btn btn-app btn-info" style="margin:5px;color:#00a65a"><i class="fa fa-play"></i>Action</a>')
  var $button_micro_cancel =$('<a class="btn btn-app btn-info" style="margin:5px;color:#dd4b39"><i class="fa fa-stop"></i>Cancel</a>')
  $("#microRNA_choose_transfunction").children(":nth-child(4)").append($button_micro_action).append($button_micro_cancel);
  $button_micro_action.on('click',function(e){
    var obj={}
    obj['stamp']=Math.random();
    obj['log_trans']=micro_log_transform;
    obj['norm_trans']=micro_norm_transform;
    Shiny.setInputValue('microRNA_Transform_Signal',obj)
  })
  $button_micro_cancel.on('click',function(e){
    micro_log_transform = ""
    micro_norm_transform = ""
    if($("#microRNA_choose_transfunction").find("span.badge").length>0){
      $("#microRNA_choose_transfunction").find("span.badge").remove();
      var obj={}
      obj['stamp']=Math.random();
      Shiny.setInputValue('Cancel_microRNA_data_show',obj)
    }else{
      sweetAlert("warning","Warning","No Action Executed!")
    }
  })
})
Shiny.addCustomMessageHandler("ceRNA_Norm_signal_custom_insert",function(msg){
   if(!$('#infolist').hasClass('in'))
        {
          $('#infolist').modal({backdrop: 'static', keyboard: false});
        }
        else
        {
          $('#infolist').modal('hide');
          $('#infolist').modal({backdrop: 'static', keyboard: false});
  }
  $('#modalSubmit').off('click').on('click',function(e){
      var obj={}
      obj['stamp']=Math.random();
      Shiny.setInputValue('ceRNA_Norm_signal_custom_insert_ok',obj)
  })
})
Shiny.addCustomMessageHandler("microRNA_Norm_signal_custom_insert",function(msg){
   if(!$('#infolist').hasClass('in'))
        {
          $('#infolist').modal({backdrop: 'static', keyboard: false});
        }
        else
        {
          $('#infolist').modal('hide');
          $('#infolist').modal({backdrop: 'static', keyboard: false});
  }
  $('#modalSubmit').off('click').on('click',function(e){
      var obj={}
      obj['stamp']=Math.random();
      Shiny.setInputValue('microRNA_Norm_signal_custom_insert_ok',obj)
  })
})
Shiny.addCustomMessageHandler("ceRNA_Norm_signal_custom_sig",function(msg){
  if(msg == "success"){
    rna_norm_transform = "Custom_input"
    $('#infolist').modal('hide');
    $("#ceRNA_choose_transfunction").children(":nth-child(3)").find("span.badge").remove();
    if(rna_log_transform===""){
      $span =$('<span class="badge bg-green">step1</span>')
      $('#ce_custom_norm_button').append($span)
    }else{
      $span =$('<span class="badge bg-green">step2</span>')
      $('#ce_custom_norm_button').append($span)
    }
    sweetAlert("success","Success...","Self-defind Function Saved...")
  }else{
    sweetAlert("error","Error...","Empty Input Function...")
  }
})
Shiny.addCustomMessageHandler("microRNA_Norm_signal_custom_sig",function(msg){
  if(msg == "success"){
    micro_norm_transform = "Custom_input"
    $('#infolist').modal('hide');
    $("#microRNA_choose_transfunction").children(":nth-child(3)").find("span.badge").remove();
    if(micro_log_transform===""){
      $span =$('<span class="badge bg-green">step1</span>')
      $('#micro_custom_norm_button').append($span)
    }else{
      $span =$('<span class="badge bg-green">step2</span>')
      $('#micro_custom_norm_button').append($span)
    }
    sweetAlert("success","Success...","Self-defind Function Saved...")
  }else{
    sweetAlert("error","Error...","Empty Input Function...")
  }
})
//creat filter modal
creat_geneFilter = function(title,inputId,type)
{ 
  var $modal = $('<div class="gene_filter construct col-lg-4" style="border:1px solid #ccc" id="gene_Group_'+inputId+'_panel"></div>');
  var $title = $('<h4>'+title+'</h4><hr style="margin-top:0px;margin-bottom:0px">');
  var $body = $('<div class="form-group col-lg-6" style="padding:0px"></div>')
  var $label = $('<label class="control-label">Minimal expression value</label> ')
  var $inputModal = $('<div class="input-group "></div>');
  var $inPut = $('<input type="text" style="text-align:center" value=0  class="form-control bfh-number" data-min="5" data-max="25" exist="F" GeneType='+type+' id=gene_slice_value_'+inputId+'>');
  var $span1 = $('<span class="input-group-btn"></span>');
  var $buttonPlus = $('<button class="btn btn-default btn-flat" type="button"><i class="fa fa-plus-square"></i></button>');
  var $button1 = $('<button class="btn btn-default btn-flat" type="button">Preview</button>');
  var $buttonMinus = $('<span class="input-group-btn"></span>').append($('<button class="btn btn-default btn-flat" type="button"><i class="fa fa-minus-square"></i></button>'));
  $modal.append($title);
  $modal.append($body);
  $body.append($label).append($inputModal);
  $inputModal.append($buttonMinus).append($inPut).append($span1);
  $span1.append($buttonPlus).append($button1);
 
    $('#Gene_Filter_all').append($modal);
  
  $inPut.on("change",function(e){
    var reg=/^-?[0-9]+(\.[0-9]+)?$/;
    if(!$(e.currentTarget).val().match(reg)){
      $(e.currentTarget).val(0);
      sweetAlert("warning","warning..","Invalid Input!");
    }
  })
  $buttonPlus.on("click",function(e){
    var value=parseFloat($(e.currentTarget).parent().prev().val());
    $(e.currentTarget).parent().prev().val(value+0.5);
  })
  $buttonMinus.children("button").on("click",function(e){
    var value=parseFloat($(e.currentTarget).parent().next().val());
    //$(e.currentTarget).parent().next().val(value-0.5<0?0:value-0.5);
    $(e.currentTarget).parent().next().val(value-0.5);
  })
   //choose a percent filter value modal
  var $labelRight = $('<label class="control-label">Minimal Sample Ratio</label>')
  var $bodyGroup = $('<div class="input-group "></div>');
  var $bodyRight = $('<div class="form-group col-lg-6" style=""></div>');
  var $spanInner = $('<span class="input-group-btn" style="padding-left:10px"></span>');
  $modal.append($bodyRight);
  var $Slider = $('<input type="text" value=""/>');
  $bodyRight.append($labelRight).append($bodyGroup);
  $bodyGroup.append($Slider).append($spanInner);
  var value=0.5;
  $Slider.ionRangeSlider({
        grid: true,
        min: 0,
        max: 1,
        from: 0.5,
        hide_min_max:true,
        step:0.01,
        onFinish: function (data) {
          value=data.from;
          $button1.trigger("click");
        }
  });
 
 
  //picture
  $button1.on("click",function(e){
    var number=$(e.currentTarget).parent().prev().val();
    var obj={}
    obj['stamp']=Math.random();
    obj['type']=$(e.currentTarget).parent().prev().attr("GeneType");
    obj['number']=number;
    obj['group']=$(e.currentTarget).parent().prev().attr("id");
    obj['exist']=$(e.currentTarget).parent().prev().attr("exist");
    obj['line']=value;
    Shiny.setInputValue('Gene_Filter_Signal',obj);
    $(e.currentTarget).parent().prev().attr("exist","T");
  })
}
creat_logtrans_button = function(opera,input,tip){
  var $button =$('<a class="btn btn-app btn-info" style="margin:5px"><i class="fa fa-exchange"></i>'+input+'</a>')
  var $span =$('<span class="badge bg-green">step1</span>')
  var $spantip =$('<span style="visibility: hidden;background-color: black;color: #fff;text-align: center;border-radius: 6px;padding: 5px 0;position: absolute;left:10px;top:130px;z-index:1;">'+tip+'</span>')
  $("#ceRNA_choose_transfunction").children(":nth-child(2)").append($button).append($spantip);
  $button.on("click",function(e){
    rna_log_transform = opera
    $("#ceRNA_choose_transfunction").find("span.badge").remove();
    rna_norm_transform = ""
    $button.append($span)
   /* var obj={}
    obj['stamp']=Math.random();
    obj['opera']=opera;
    $button.append($span);
    Shiny.setInputValue('Value_Transform_Signal',obj);*/
  })
  $button.hover(function(){
      $spantip.css("visibility","visible")},
    function(){
      $spantip.css("visibility","hidden")
  })
}
creat_logtrans_button_micro = function(opera,input,tip){
  var $button =$('<a class="btn btn-app btn-info" style="margin:5px"><i class="fa fa-exchange"></i>'+input+'</a>')
  var $span =$('<span class="badge bg-green">step1</span>')
  var $spantip =$('<span style="visibility: hidden;background-color: black;color: #fff;text-align: center;border-radius: 6px;padding: 5px 0;position: absolute;left:10px;top:130px;z-index:1;">'+tip+'</span>')
  $("#microRNA_choose_transfunction").children(":nth-child(2)").append($button).append($spantip);
  $button.on("click",function(e){
    micro_log_transform = opera
    $("#microRNA_choose_transfunction").find("span.badge").remove();
    micro_norm_transform = ""
    $button.append($span)
   /* var obj={}
    obj['stamp']=Math.random();
    obj['opera']=opera;
    $button.append($span);
    Shiny.setInputValue('Value_Transform_Signal',obj);*/
  })
  $button.hover(function(){
      $spantip.css("visibility","visible")},
    function(){
      $spantip.css("visibility","hidden")
  })
}
creat_normtrans_button = function(opera,input,tip){
  var $button =$('<a class="btn btn-app " style="margin:5px;"><i class="fa fa-random"></i>'+input+'</a>')
  var $spantip =$('<span style="visibility: hidden;background-color: black;color: #fff;text-align: center;border-radius: 6px;padding: 5px 0;position: absolute;left:10px;top:130px;z-index:1;">'+tip+'</span>')
  $("#ceRNA_choose_transfunction").children(":nth-child(3)").append($button).append($spantip);
  var $span=""
  $button.on("click",function(e){
    rna_norm_transform = opera
    $("#ceRNA_choose_transfunction").children(":nth-child(3)").find("span.badge").remove();
    if(rna_log_transform===""){
      $span =$('<span class="badge bg-green">step1</span>')
      $button.append($span)
    }else{
      $span =$('<span class="badge bg-green">step2</span>')
      $button.append($span)
    }
   /* var obj={}
    obj['stamp']=Math.random();
    obj['opera']=opera;
    $button.append($span);
    Shiny.setInputValue('Normalized_Signal',obj);*/
  })
  $button.hover(function(){
      $spantip.css("visibility","visible")},
    function(){
      $spantip.css("visibility","hidden")
  })
}
creat_normtrans_button_custom = function(opera,input,tip){
  var $button =$('<a id="ce_custom_norm_button" class="btn btn-app " style="margin:5px;"><i class="fa fa-edit"></i>'+input+'</a>')
  var $spantip =$('<span style="visibility: hidden;background-color: black;color: #fff;text-align: center;border-radius: 6px;padding: 5px 0;position: absolute;left:10px;top:130px;z-index:1;">'+tip+'</span>')
  $("#ceRNA_choose_transfunction").children(":nth-child(3)").append($button).append($spantip);
  $button.on("click",function(e){
    var obj={}
    obj['stamp']=Math.random();
    Shiny.setInputValue('ceRNA_Norm_signal_custom',obj)
   /* var obj={}
    obj['stamp']=Math.random();
    obj['opera']=opera;
    $button.append($span);
    Shiny.setInputValue('Normalized_Signal',obj);*/
  })
  $button.hover(function(){
      $spantip.css("visibility","visible")},
    function(){
      $spantip.css("visibility","hidden")
  })
}
creat_normtrans_button_micro = function(opera,input,tip){
  var $button =$('<a class="btn btn-app " style="margin:5px;"><i class="fa fa-random"></i>'+input+'</a>')
  var $spantip =$('<span style="visibility: hidden;background-color: black;color: #fff;text-align: center;border-radius: 6px;padding: 5px 0;position: absolute;left:10px;top:130px;z-index:1;">'+tip+'</span>')
  $("#microRNA_choose_transfunction").children(":nth-child(3)").append($button).append($spantip);
  var $span=""
  $button.on("click",function(e){
    micro_norm_transform = opera
    $("#microRNA_choose_transfunction").children(":nth-child(3)").find("span.badge").remove();
    if(micro_log_transform===""){
      $span =$('<span class="badge bg-green">step1</span>')
      $button.append($span)
    }else{
      $span =$('<span class="badge bg-green">step2</span>')
      $button.append($span)
    }
   /* var obj={}
    obj['stamp']=Math.random();
    obj['opera']=opera;
    $button.append($span);
    Shiny.setInputValue('Normalized_Signal',obj);*/
  })
  $button.hover(function(){
      $spantip.css("visibility","visible")},
    function(){
      $spantip.css("visibility","hidden")
  })
}
creat_normtrans_button_micro_custom = function(opera,input,tip){
  var $button =$('<a id="micro_custom_norm_button" class="btn btn-app " style="margin:5px;"><i class="fa fa-edit"></i>'+input+'</a>')
  var $spantip =$('<span style="visibility: hidden;background-color: black;color: #fff;text-align: center;border-radius: 6px;padding: 5px 0;position: absolute;left:10px;top:130px;z-index:1;">'+tip+'</span>')
  $("#microRNA_choose_transfunction").children(":nth-child(3)").append($button).append($spantip);
  var $span=""
  $button.on("click",function(e){
    var obj={}
    obj['stamp']=Math.random();
    Shiny.setInputValue('microRNA_Norm_signal_custom',obj)
   /* var obj={}
    obj['stamp']=Math.random();
    obj['opera']=opera;
    $button.append($span);
    Shiny.setInputValue('Normalized_Signal',obj);*/
  })
  $button.hover(function(){
      $spantip.css("visibility","visible")},
    function(){
      $spantip.css("visibility","hidden")
  })
}
//qiefen
/*
slice_gene=function(e){
    var number=$(e).children("div").children("div").find(".form-control").val();
    var obj={}
    var slider=$(e+">:nth-child(4)").children("div").children("input").data("from")
    obj['stamp']=Math.random();
    obj['type']=$(e).children("div").children("div").find(".form-control").attr("GeneType");
    obj['number']=number;
    obj['group']=$(e).attr("id");
    obj['line']=slider;
    Shiny.setInputValue('Gene_Slice_Signal',obj);
  }
  */
Shiny.addCustomMessageHandler('gene_type_infomation',function(msg){
  var len=msg.group.length;
  //$('#gene_Group_microFilterPlot_panel').nextAll().remove();
  for(var i=0;i<len;i++){
     creat_geneFilter("RNA Filter For Group:"+msg.group[i],msg.group[i],"Rna");
  }
});