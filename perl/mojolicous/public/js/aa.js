//ѡ�����ݣ�
var questions=['�����˺�','�����ӿڱ��','�ʽ��������'];
//��ǰ��ѡ�е�ֵ��
var currentValue=new Array();
 
var selectobj=['q1','q2','q3'];
 
function $(id){
    return document.getElementById(id);
    }
function init(){
    
     for(var j=0;j<selectobj.length;j++){
          //���ԭ��ѡ�
          $(selectobj[j]).options.length=0;
          //���ѡ�
           var oOption = document.createElement("option"); 
           var text="--��ѡ��--";
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
          //���ԭ��ѡ�
          $(selectobj[j]).options.length=0;
         //���ѡ�
           var oOption = document.createElement("option"); 
           var text="--��ѡ��--"
           var value="";
           oOption.text=text; 
           oOption.value=value; 
           $(selectobj[j]).add(oOption);
            
          for(var i=0;i<questions.length;i++){
                  
                    var available=true;//ѡ���Ƿ�ռ��
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
            //ѡ���
            //$(selectobj[j]).value=currentValue[j];
            setSelect(selectobj[j],currentValue[j]);
       }
    }
//ʹselectѡ���ض�ֵ��
function setSelect(id,value){
       for(var i=0;i<$(id).options.length;i++){
             if($(id).options[i].value==value){
                   $(id).selectedIndex=i;
                   break;
                 }
           }
    }    

