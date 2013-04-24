//判断核算项先后*****************************
function vlidate_one(){
//	if($("#q1").val()==""){
//		$("#q3").val("");
//		$("#q4").val("");
//		$("#q2").val("");				
//	}
	
}
function vlidate_two(){
	if($("#q1").val()==""){
		alert("第一核算项还没选");
	}
	
	
//	if($("#q2").val()==""){
//		$("#q3").val("");
//		$("#q4").val("");
//	}
}
function vlidate_three(){
	if($("#q1").val()==""){
//		$("#q2").val("");
//		$("#q3").val("");
//		$("#q4").val("");
		alert("第一核算项还没选");
	}
	if($("#q2").val()==""&& $("#q1").val()!=""){
		alert("第二核算项还没选");
	}
//	if($("#q3").val()==""){
//		$("#q4").val("");
//	}

}
function vlidate_four(){
	if($("#q1").val()==""){
		alert("第一核算项还没选");
	}
	if($("#q2").val()==""&& $("#q1").val()!=""){
		alert("第二核算项还没选");
	}
	if($("#q3").val()==""&& $("#q1").val()!=""&& $("#q2").val()!=""){
		alert("第三核算项还没选");
	}

}

//三级下拉菜单互斥控制*********************
function s(id){
	  return document.getElementById(id);
	  }
function init(){
 
	   for(var j=0;j<selectobj.length;j++){
	        //清除原先选项：
	        s(selectobj[j]).options.length=0;
	        //添加选项：
	         var oOption = document.createElement("option"); 
	        // var text="--请选择--";
	         var value="";
	         oOption.text=text; 
	         oOption.value=value;            
	         s(selectobj[j]).add(oOption);
	         
	        for(var i=0;i<questions.length;i++){
	             var oOption = document.createElement("option"); 
	             oOption.text=questions[i]; 
	             oOption.value=transValue[i]; 
	             
	             s(selectobj[j]).add(oOption);
	              
	            }              
	   }
    
	  }
	function collectVlue(){
	    var currentobj=null;
	    for(var j=0;j<selectobj.length;j++){    	 
	        currentobj=s(selectobj[j]);
	        currentValue[j]=currentobj.value;
	  	  
	     }
	  }   
	function change(i){
      
	    if(i!=10000){
	        collectVlue();
	    }
	  	if(i!=1){
	  		
	  	}
	  	 //alert($("#q1v").val());
	    for(var j=0;j<selectobj.length;j++){
	        //清除原先选项：
	        s(selectobj[j]).options.length=0;
	       //添加选项：
	         var oOption = document.createElement("option"); 
	        // var text="--请选择--";
	         var value="";
	         oOption.text=text; 
	         oOption.value=value; 
	         s(selectobj[j]).add(oOption);            
	        for(var h=0;h<questions.length;h++){                  
	                  var available=true;//选项是否被占用	                  
	                  
	                  for(var k=0;k<currentValue.length;k++)
	                  {	                	  
	                	// if(selectobj[k]!=""){
	                		 if(transValue[h]==currentValue[k]&&j!=k){
	                			 available=false;
	                			 break;   
	                	//	 }   
	                	 }
	                	 }
	                  
	                  if(available){                        
	                     var oOption = document.createElement("option");      
	                     oOption.text=questions[h]; 
	                     oOption.value=transValue[h]; 
	                     s(selectobj[j]).add(oOption);
	                 }                            
	          //选中项：
	          //$(selectobj[j]).value=currentValue[j];
	          setSelect(selectobj[j],currentValue[j]);
	          
	        }
	     }    
	  }

	//使select选中特定值：
	function setSelect(id,value){
		//alert(id+":"+value);
	     for(var i=0;i<s(id).options.length;i++){
	           if(s(id).options[i].value==value){
	                 s(id).selectedIndex=i;
	                 break;
	               }
	         }
	  } 
