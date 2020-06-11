var textButtonInput=new Shiny.InputBinding();
$.extend(textButtonInput,{
  find:function(scope){
    $(scope).find('.textButtonInput');
  },
  getId:function(el)
  {
    return el.id;
  },
  getValue:function(el)
  {
    return el.value;
  },
  setValue:function(el,value){
    el.value=value;
  },
  
})
Shiny.inputBindings.register(textButtonInput, 'shiny.urlInput');
//
var value_BoxInput=new Shiny.InputBinding();
$.extend(value_BoxInput,{
  find:function(scope){
    $(scope).find('.value_BoxInput');
  },
  getValue:function(el)
  {
   
    return $(el).child("h3").text();
  },
  getId:function(el)
  {
    
    return $(el).attr("id");
  },
  setValue:function(el,value){

    $(el).child("h3").text(value);
  },
  subscribe: function(el, callback) {

    // only when the switchChange event is detected on instances of class bootstrapSwitch
    // trigger the getValue method and send the value to shiny
    

      // callback which will tell Shiny to retrieve the value via getValue
      callback();
  
  }
})
Shiny.inputBindings.register(value_BoxInput);