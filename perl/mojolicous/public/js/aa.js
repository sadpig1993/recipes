//选项内容：
var questions=['银行账号','技术接口编号','资金对账日期'];
//当前被选中的值：
var currentValue=new Array();
 
var selectobj=['q1','q2','q3'];
 
function $(id){
    return document.getElementById(id);
    }
function init(){
    
     for(var j=0;j<selectobj.length;j++){
          //清除原先选项：
          $(selectobj[j]).options.length=0;
          //添加选项：
           var oOption = document.createElement("option"); 
           var text="--请选择--";
           var value="";
           oOption.text=text; 
           oOption.value=value;    
           $(selectobj[j]).add(oOption);
           
          for(var i=0;i<questions.length;i++){
               var oOption = document.createElement("option"); 
               oOption.text=questions[i]; 
               oOption.value=questions[i]; 
               
               $(selectobj[j]).add(oOption);
                
              }
     }
    }
function collectVlue(){
      var currentobj=null;
      for(var j=0;j<selectobj.length;j++){
          currentobj=$(selectobj[j]);
          currentValue[j]=currentobj.value;
       }
    }    
function change(i){
      if(i!=10000){
          collectVlue();
      }
      
      //document.write(currentValue[0]);
      //document.write(currentValue[1]);
      //document.write(currentValue[2]);
      //return;
      
      for(var j=0;j<selectobj.length;j++){
          //清除原先选项：
          $(selectobj[j]).options.length=0;
         //添加选项：
           var oOption = document.createElement("option"); 
           var text="--请选择--"
           var value="";
           oOption.text=text; 
           oOption.value=value; 
           $(selectobj[j]).add(oOption);
            
          for(var i=0;i<questions.length;i++){
                  
                    var available=true;//选项是否被占用
                    for(var k=0;k<currentValue.length;k++)
                    {
                       if(questions[i]==currentValue[k]&&j!=k){
                            available=false;
                            break;   
                        }    
                    }
                    if(available){
                        
                       var oOption = document.createElement("option");      
                       oOption.text=questions[i]; 
                       oOption.value=questions[i]; 
                       $(selectobj[j]).add(oOption);
                   }
                
              }
            //选中项：
            //$(selectobj[j]).value=currentValue[j];
            setSelect(selectobj[j],currentValue[j]);
       }
    }
//使select选中特定值：
function setSelect(id,value){
       for(var i=0;i<$(id).options.length;i++){
             if($(id).options[i].value==value){
                   $(id).selectedIndex=i;
                   break;
                 }
           }
    }    

