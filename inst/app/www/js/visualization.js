var cy
var network_group = ""
var network_group_shape= ""
var network_select_group=""

$(document).ready(function(){
   $("#dropdown_action").on('click',function(e){
     if($(e.currentTarget).next().hasClass("dropdown-menu")){
       $(e.currentTarget).next().removeClass();
     }else{
       $(e.currentTarget).next().addClass("dropdown-menu");
     }
   })
   $("#dropdown_action").mouseover(function(){
        $("#dropdown_action").prev().css("visibility","");
   })
   $("#dropdown_action").mouseout(function(){
         $("#dropdown_action").prev().css("visibility","hidden");
   })
   $("#reset_network").on('click',function(){
     cy.reset();
   })
   $("a[href='#shiny-tab-visualization']").on("click",function(e){
     var obj=Math.random()
     Shiny.setInputValue("change_network_name",obj)
     $("#cy").children("div").css("height","1000px")
   })
   $('#cy').attr("style","width:100%;height:100%;position:relative;z-index:0;left: 0;top: 0;")
   cy=cytoscape({
     container:$("#cy"),
     elements:[],
     style: [ // the stylesheet for the graph
              {
                selector: 'node',
                style: {
                  'background-color': '#ad1a66',
                  'label': 'data(id)'
                }
              },
              {
                selector: 'edge',
                style: {
                  'width': 0.5,
                  /*'line-color': '#ad1a66'*/
                  'curve-style': 'haystack'
                }
              },
              {
                selector: 'node:selected',
                style:{
                   "background-color": "#FC4C4C",
                   "color": "#FC4C4C"
                }
              }
            
    ],

    layout: {
        name: 'circle',
        animate: false
    }
  })
/*  $("#cy").children("div").css("height","1000px")*/
  
  var $button_change_layout=$('<div class="input-group-btn"><button type="button" class="btn btn-success dropdown-toggle" data-toggle="dropdown" aria-expanded="false">Select Layout<span class="fa fa-caret-down"></span></button><ul class="dropdown-menu"></ul></div>')
  var $button_nameChoose=$('<div class="input-group-btn"><button type="button" class="btn btn-danger dropdown-toggle" data-toggle="dropdown" aria-expanded="false">Displayed Symbols<span class="fa fa-caret-down"></span></button></div>')
  var $ul_nameChoose=$('<ul class="dropdown-menu"></ul></div>')
  var $button_change_color=$('<div class="input-group-btn"><button type="button" class="btn btn-success dropdown-toggle" data-toggle="dropdown" aria-expanded="false">Mapping Colors<span class="fa fa-caret-down"></span></button><ul class="dropdown-menu"></ul></div>')
  var $button_change_shape=$('<div class="input-group-btn">Mapping Shapes<button type="button" class="btn btn-success dropdown-toggle" data-toggle="dropdown" aria-expanded="false">Mapping Shapes<span class="fa fa-caret-down"></span></button><ul class="dropdown-menu"></ul></div>')
  var $network_p = $('<div class="form-group"><h4 style="font-family:Georgia;font-weight:bold">Choose Node Color </h4></div>')
  var $network_color_p =$('<div class="form-group"><h4 style="font-family:Georgia;font-weight:bold">Choose Node Shape</h4></div>')
  var $network_select_button=$('<div class="input-group-btn open"><button type="button" class="btn btn-success dropdown-toggle" data-toggle="dropdown" aria-expanded="false">Choose label<span class="fa fa-caret-down"></span></button><ul class="dropdown-menu"></ul></div>')
  var $network_select_input = $('<input type="text" class="form-control">')
  var $network_select_span = $('<span class="input-group-btn"><button type="button" class="btn btn-info btn-flat">Go!</button></span>')
  $('#select_network_node').children('div').append($network_select_button).append($network_select_input).append($network_select_span)
  $network_select_span.on('click',function(e){
    var value = $network_select_input.val()+''
    if(cy.elements('node['+network_select_group+'="'+value+'"]').length===0){
       sweetAlert("error","Error...","The node can't be found!!!")
    }else{
       cy.elements('node['+network_select_group+'="'+value+'"]').select()
    }
  })
  var $network_node_size_input= $('<input type="text" class="form-control">')
  var $network_node_size_span = $('<span class="input-group-btn"><button type="button" class="btn btn-info btn-flat">Go!</button></span>')
  $('#change_node_size').children('div').append($network_node_size_input).append($network_node_size_span)
  $network_node_size_span.on('click',function(e){
    
    if(/^[0-9]+$/.test($network_node_size_input.val())){
       var value = $network_node_size_input.val()+''
       cy.style().selector('node').style('width',value).update()
       cy.style().selector('node').style('height',value).update()
    }else{
      sweetAlert("error","Error...","Please input a integer!")
    }

  })
  $("#choose_differ_layout").append($button_change_layout)
  var layout_name=new Array("Circle","Random","Grid","Concentric","Breadthfirst","Cose")
  for(var i=0;i<layout_name.length;i++){
    create_net_layout(layout_name[i])
  }
  $("#change_network_color").append($network_p)
  $("#choose_differ_name").append($button_nameChoose)
  $button_nameChoose.append($ul_nameChoose)
  $("#change_network_shape").append($network_color_p)
  $network_p.append($button_change_color)
  $network_color_p.append($button_change_shape)
  var $table_color = $('<div class="col-lg-6" style="padding:0px"><div class="table" style="margin-top:5px"></div></div>')
  var $table_shape = $('<div class="col-lg-6" style="padding:0px"><div class="table" style="margin-top:5px"></div></div>')
  $("#change_network_color").children('div.form-group').append($table_color)
  $("#change_network_shape").children('div.form-group').append($table_shape)
  //network export as png
  var $network_png = $('<span class="input-group-btn"><button type="button" class="btn btn-info btn-flat">Export</button></span>')
  
  $("#export_network_png").append($network_png)
  $network_png.on('click',function(e){
    var b64key = 'base64';
    var b64 =  cy.png().substring( 22 );
    var imgBlob = base64ToBlob( b64, 'image/png' );
    saveAs( imgBlob, 'graph.png' );
  })
  create_color_all_node_module("All_node")
  create_shape_all_node_module("All_node")
})
function base64ToBlob(urlData, type) {

    var mime = 'image/png';

    var bytes = window.atob(urlData);
    
    var ab = new ArrayBuffer(bytes.length);

    var ia = new Uint8Array(ab);
    for (var i = 0; i < bytes.length; i++) {
    ia[i] = bytes.charCodeAt(i);
    }
    return new Blob([ab], {
          type: mime
    });
}
create_net_layout = function(name){
    var $li =$('<li></li>')
    var $a =$('<a>'+name+'</a>')
    $('#choose_differ_layout').children('div').children('ul').append($li)
    $li.append($a)
    $li.on("click",function(){
      $('#choose_differ_layout').children('div').children('button').html(name)
      var obj={}
      obj['stamp']=Math.random()
      obj['type']=name
      obj['do_what']="layout"
      Shiny.setInputValue("network",obj)
    })
}
creat_changeName = function(name){
  var $li =$('<li></li>')
  var $a =$('<a>'+name+'</a>')
  $('#choose_differ_name').find('ul').append($li)
  $li.append($a)
  $li.on("click",function(e){
    if(name=="No Label"){
      $('#choose_differ_name').children('button').html(name)
       cy.style().selector('node').style('label', '').update()
    }
    else{
       $('#choose_differ_name').children('button').html(name)
       cy.style().selector('node').style('label', 'data('+name+')').update()
    }
  })
}
create_net_change_module_pre = function(name){
  var $li =$('<li></li>')
  var $a =$('<a>'+name+'</a>')
  $('#change_network_color').children('div.form-group').children('div').children('ul').append($li)
  $li.append($a)
  $li.on("click",function(e){
     $('#change_network_color').children('div.form-group').children('div').children('button').html(name)
     network_group = name
     var obj={}
     obj['func'] = "color"
     obj['stamp']=Math.random()
     obj['type']=name
     Shiny.setInputValue("net_color_shape",obj)
  })
}
create_net_change_shape_pre =function(name){
  var $li =$('<li></li>')
  var $a =$('<a>'+name+'</a>')
  $('#change_network_shape').children('div.form-group').children('div').children('ul').append($li)
  $li.append($a)
  $li.on("click",function(e){
     $('#change_network_shape').children('div.form-group').children('div').children('button').html(name)
     network_group_shape = name
     var obj={}
     obj['func'] = "shape"
     obj['stamp']=Math.random()
     obj['type']=name
     Shiny.setInputValue("net_color_shape",obj)
  })
}
create_network_select_module = function(name){
  var $li =$('<li></li>')
  var $a =$('<a>'+name+'</a>')
  $('#select_network_node').children('div').children('div').children('ul').append($li)
  $li.append($a)
  $li.on("click",function(e){
     $('#select_network_node').children('div').children('div').children('button').html(name)
     network_select_group = name
  })
}
create_net_change_shape_module = function(type){
  $table_tr = $('<div class="table-tr"></div>')
  $table_tdname = $('<div class="table-tdr"><small class="bg-green" style="border-radius:10px;padding:3px 7px">'+type+'</small></div>')
  $table_tdshape = $('<div class="table-tdl"> <select class="form-control" style="width:100px;height:30px; text-align: center;"></select></div>')
  $option1 = $('<option>ellipse</option>')
  $option2 = $('<option>barrel</option>')
  $option3 = $('<option>round-triangle</option>')
  $option4 = $('<option>rectangle</option>')
  $option5 = $('<option>pentagon</option>')
  $option6 = $('<option>star</option>')
  $option7 = $('<option>hexagon</option>')
  $option8 = $('<option>octagon</option>')
  $("#change_network_shape").children('div.form-group').children('div.col-lg-6').children('div.table').append($table_tr)
  $table_tr.append($table_tdname).append($table_tdshape)
  $table_tdshape.children('select').append($option1).append($option2).append($option3).append($option4).append($option5).append($option6).append($option7).append($option8)
  $table_tdshape.children('select').on('change',function(e){
    if(type=="All_node"){
      cy.style().selector('node').style('shape',e.currentTarget.value).update()
    }else{
      cy.style().selector('node['+network_group_shape+'="'+type+'"]').style('shape',e.currentTarget.value).update()
    }
  })
}
create_net_change_module = function(type){
  $table_tr = $('<div class="table-tr"></div>')
  $table_tdname = $('<div class="table-tdr"><small class="bg-green" style="border-radius:10px;padding:3px 7px">'+type+'</small></div>')
  $table_tdcolor = $('<div class="table-tdl"> <input class="jscolor" style="border-radius:15px;text-align:center" value="ab2567"></div>')
  $("#change_network_color").children('div.form-group').children('div.col-lg-6').children('div.table').append($table_tr)
  $table_tr.append($table_tdname).append($table_tdcolor)

  $table_tdcolor.on("change",function(e){
    var color = (e.currentTarget).children[0].jscolor.rgb
    if(type=="All_node"){
      cy.style().selector('node').style('background-color',color).update()
    }else{
      cy.style().selector('node['+network_group+'="'+type+'"]').style('background-color',color).update()
    }
    
  })
}
create_color_all_node_module = function(type){
  $("#change_network_color").children('div.form-group').children('div.col-lg-6').children('div.table').empty();
  $table_head=$('<div class="table-tr"><div class="table-th">Item</div><div class="table-th">Color</div></div>')
  $("#change_network_color").children('div.form-group').children('div.col-lg-6').children('div.table').append($table_head)
  create_net_change_module("All_node")
  window.jscolor();

}
create_shape_all_node_module = function(type){
  $("#change_network_shape").children('div.form-group').children('div.col-lg-6').children('div.table').empty();
  $table_head=$('<div class="table-tr"><div class="table-th">Item</div><div class="table-th">Shape</div></div>')
  $("#change_network_shape").children('div.form-group').children('div.col-lg-6').children('div.table').append($table_head)
  create_net_change_shape_module("All_node")
}
Shiny.addCustomMessageHandler("network",function(msg){
  if(msg.do_what=="layout"){
     var collection = cy.elements('node');
     cy.remove( collection );
     collection = cy.elements('edge');
     cy.remove( collection );
     cy.add(msg.nodes)
     cy.add(msg.edge)
     
  /*var width=$("#cy").children("div").css("width")
  var height=$("#cy").children("div").css("height")
  width=parseInt(width.replace(/px/,""))
  height=parseInt(height.replace(/px/,""))*/
     cy.center()
     cy.fit()
     type = msg.type.toLowerCase()
     var layout=cy.layout({
       name:type,
       fit: true, // whether to fit the viewport to the graph
       padding: 30,
       animate: false,
       animationDuration: 2000// padding used on fit
     })
     layout.run()
     var obj={}
     obj['stamp'] = Math.random();
     Shiny.setInputValue("Network_con_finish",obj)
  }
})
Shiny.addCustomMessageHandler("Gene_info_name_change",function(msg){
  $("#choose_differ_name").find('ul').empty();
  $("#change_network_color").find('ul').empty();
  $("#change_network_shape").find('ul').empty();
  $("#select_network_node").find('ul').empty();
  creat_changeName("No Label")
  create_net_change_module_pre("All_node")
  create_net_change_shape_pre("All_node")
  create_network_select_module("All_node")
  for(var i=0;i<msg.length;i++){
    if(msg[i]==".group"){
      msg[i]="group"
    }
    creat_changeName(msg[i])
    create_net_change_module_pre(msg[i])
    create_net_change_shape_pre(msg[i])
    create_network_select_module(msg[i])
  }
})
Shiny.addCustomMessageHandler("Gene_network_color_change",function(msg){
  cy.style().selector('node').style('background-color',[171,37,103]).update()
  $("#change_network_color").children('div.form-group').children('div.col-lg-6').children('div.table').empty();
  $table_head=$('<div class="table-tr"><div class="table-th">Item</div><div class="table-th">Color</div></div>')
  $("#change_network_color").children('div.form-group').children('div.col-lg-6').children('div.table').append($table_head)
  for(var i=0;i<msg.type.length;i++){
    create_net_change_module(msg.type[i])
  }
  window.jscolor();
})
Shiny.addCustomMessageHandler("Gene_network_shape_change",function(msg){
  cy.style().selector('node').style('shape','ellipse').update()
  $("#change_network_shape").children('div.form-group').children('div.col-lg-6').children('div.table').empty();
  $table_head=$('<div class="table-tr"><div class="table-th">Item</div><div class="table-th">Shape</div></div>')
  $("#change_network_shape").children('div.form-group').children('div.col-lg-6').children('div.table').append($table_head)
  for(var i=0;i<msg.type.length;i++){
    create_net_change_shape_module(msg.type[i])
  }
})