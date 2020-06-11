
//creat filter modal
creat_sampleFilter = function(inputId,inputName)
{ 
  
  var $modal = $('<div class="gene_filter construct col-lg-6" exist="F" style="border:1px solid #ccc" id="sample_Group_'+inputName+'_panel"></div>');
  var $dabiaoti=$('<h4>'+inputId+'</h4><hr style="margin-top:0px;margin-bottom:0px">')

  var $invalid_value=$('<div class="form-group col-lg-12"</div>')

  var $div1=$('<div class="row"</div>')

  var $col_lg_3_1=$('<div class="col-lg-3"></div>')
  var $col_lg_6=$('<div class="col-lg-3"></div>')
  var $col_lg_3_margin=$('<div class="col-lg-3" style="padding:0;margin-top:25px"></div>')
  
  var $direction_label=$('<label class="control-label">Direction</label>')
  var $direction_select=$('<select name="example1_length" class="form-control input-sm shiny-bound-input"></select>')
 
  var $direction_select1=$('<option value="<"><</option>')
  var $direction_select3=$('<option value=">">></option>')
  
  var $thresh_label=$('<label class="control-label">Thresh</label>')
  var $thresh_div=$('<div class="input-group" id="thresh_sample"></div>')
  var $thresh_text=$('<input class="form-control" type="text" value="0" style="text-align:center">')
  
  var $button_out=$('<div class="input-group-btn"></div>')
  var $sample_button=$('<button type="button" class="btn btn-danger btn-flat">preview</button>')
  
  $modal.append($dabiaoti).append($invalid_value).append($div1);

  $div1.append($col_lg_3_1).append($col_lg_6).append($col_lg_3_margin);

  $col_lg_3_margin.append($button_out).append($sample_button)
  

  $col_lg_3_1.append($direction_label).append($direction_select)
  $direction_select.append($direction_select1).append($direction_select3)
  $direction_select.select2({
    tags:false,
    multiple:false,
    minimumResultsForSearch: -1
  })
  $col_lg_6.append($thresh_label).append($thresh_div)
  $thresh_div.append($thresh_text)
  

  
  
  $('#Sample_Filter_all').append($modal);
  
  //choose a percent filter value modal
  var $labelRight = $('<label class="control-label">Percentile</label>')
  var $bodyGroup = $('<div class="input-group "></div>');
  var $bodyRight = $('<div class="form-group col-lg-12" style=""></div>');
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
      $sample_button.trigger("click");
    }
  });
  
  //jquery获取复选框???    
  $sample_button.on("click",function(e){
    chk_value =[];
    $('input[name="'+inputName+'"]:checked').each(function(){//遍历每一个名字为xx的复选框，其中选中的执行函???    
      chk_value.push($(this).val());//将选中的值添加到数组chk_value???    
    })
    var obj={}
    obj['group']=inputName;
    obj['stamp']=Math.random();
    //obj['sep']=chk_value;
    obj['direction']=$direction_select.select2('val')
    obj['thresh']=$thresh_text.val()
    obj['exist']=$modal.attr('exist');
    obj['value']=value;
    Shiny.setInputValue('Sample_Filter',obj);
    $modal.attr('exist','T');
  })
  
  //picture
  $("#sample_slice_all").on('click',function(e){
    var obj = {}
    obj['stamp'] = Math.random();
    Shiny.setInputValue('Sample_Slice_Signal',obj);
  })
  
}

/*slice=function(e){
    var obj={}
    var slider=$(e+">:nth-child(5)").children("div").children("input").data("from")
    obj['stamp']=Math.random();
    obj['group']=$(e).attr("id");
    obj['line']=slider;
    obj['direction']=$(e+">:nth-child(4)").find('select').select2('val')
    obj['thresh']=$(e+">:nth-child(4)").children('div:nth-child(2)').find('input').val()
    Shiny.setInputValue('Sample_Slice_Signal',obj);
  }
  */

  
  
$(document).ready(function(){
  $("#sample_slice_all").on('click',function(e){
    var obj = {}
    obj['stamp'] = Math.random();
    Shiny.setInputValue('Sample_Slice_Signal',obj);
  })
  
  
})  
  

  
  