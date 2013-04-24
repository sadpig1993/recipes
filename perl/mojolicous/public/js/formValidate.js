/*
 -------------- 函数检索 --------------
 $函数
 trim函数:                         trim() lTrim() rTrim() trimAll()
 校验字符串是否为空:                 checkIsNotEmpty(str)
 校验字符串是否为整型:               checkIsInteger(str)
 校验整型最小值:                    checkIntegerMinValue(str,val)
 校验整型最大值:                    checkIntegerMaxValue(str,val)
 校验整型是否为非负数:               isNotNegativeInteger(str)
 校验字符串是否为浮点型:             checkIsDouble(str)
 校验浮点型最小值:                  checkDoubleMinValue(str,val)
 校验浮点型最大值:                  checkDoubleMaxValue(str,val)
 校验浮点型是否为非负数:             isNotNegativeDouble(str)
 校验字符串是否为日期型:             checkIsValidDate(str)
 校验两个日期的先后:                checkDateEarlier(strStart,strEnd)
 校验字符串是否为email型:           checkEmail(str)

 校验字符串是否为中文:               checkIsChinese(str)
 计算字符串的长度，一个汉字两个字符:   realLength()
 校验字符串是否符合自定义正则表达式:   checkMask(str,pat)
 得到文件的后缀名:                   getFilePostfix(oFile)
 -------------- 函数检索 --------------
*/
// 说明：用 Javascript 操作 Cookie
function getCookie( name ) {
var start = document.cookie.indexOf( name + "=" );
var len = start + name.length + 1;
if ( ( !start ) && ( name != document.cookie.substring( 0, name.length ) ) ) {
return null;
}
if ( start == -1 ) return null;
var end = document.cookie.indexOf( ';', len );
if ( end == -1 ) end = document.cookie.length;
return unescape( document.cookie.substring( len, end ) );
}
 
function setCookie( name, value, expires, path, domain, secure ) {
var today = new Date();
today.setTime( today.getTime() );
if ( expires ) {
expires = expires * 1000 * 60 * 60 * 24;
}
var expires_date = new Date( today.getTime() + (expires) );
document.cookie = name+'='+escape( value ) +
( ( expires ) ? ';expires='+expires_date.toGMTString() : '' ) + //expires.toGMTString()
( ';path=' + ( path ) ?  path : '/' ) +
( ';domain=' + ( domain ) ?  domain : document.domain ) +
( ( secure ) ? ';secure' : '' );
}
 
function deleteCookie( name, path, domain ) {
if ( getCookie( name ) ) document.cookie = name + '=' +
( ( path ) ? ';path=' + path : '/') +
( ( domain ) ? ';domain=' + domain : document.domain ) +
';expires=Thu, 01-Jan-1970 00:00:01 GMT';
} 
var $;
if (!$) {
  $ = function() {
    var elements = new Array();
    for (var i = 0; i < arguments.length; i++) {
      var element;
 
      if (typeof arguments[i] == 'string') {
        element=document.getElementById(arguments[i]);
		if(element==null)//没有声明id，根据name找(提高兼容性，ie中id name相同)
			element=document.all[arguments[i]];
      }
      if (arguments.length == 1) {
        return element;
      }
      elements.push(element);
    }
    return elements;
  }
}

/**
 * auther:yinxy
 * 去除多余空格函数
 * trim:去除两边空格 lTrim:去除左空格 rTrim: 去除右空格
 * 用法：
 *     var str = "  hello ";
 *     str = str.trim();
 */
String.prototype.trim = function()
{
    return this.replace(/(^[\s]*)|([\s]*$)/g, "");
}
String.prototype.lTrim = function()
{
    return this.replace(/(^[\s]*)/g, "");
}
String.prototype.rTrim = function()
{
    return this.replace(/([\s]*$)/g, "");
}
/********************************** Empty **************************************/
/**auther:yinxy
 * 
 *校验字符串是否为空
 *返回值：
 *如果不为空，定义校验通过，返回true
 *如果为空，校验不通过，返回false               参考提示信息：输入域不能为空！
 */
function checkIsNotEmpty(str)
{
    if (str.trim() == "")
        return false;
    else
        return true;
}


/********************************** Integer *************************************/
/**
 * auther:yinxy
 * 
 *校验字符串是否为整型
 *返回值：
 *如果为空，定义校验通过，      返回true
 *如果字串全部为数字，校验通过，返回true
 *如果校验不通过，              返回false     参考提示信息：输入域必须为数字！
 */
function checkIsInteger(str, name)
{
    //如果为空，则通过校验
    if (str == "")
        return true;
    if (/^(\-?)(\d+)$/.test(str))
        return true;
    else {
        alert("输入的" + name + "必须为数字！前后不能有空格!");
        return false;
    }
}
//~~~
/**
 * auther:yinxy
 * 
 *校验整型最小值
 *str：要校验的串。  val：比较的值
 *
 *返回值：
 *如果为空，定义校验通过，                返回true
 *如果满足条件，大于等于给定值，校验通过，返回true
 *如果小于给定值，                        返回false              参考提示信息：输入域不能小于给定值！
 */
function checkIntegerMinValue(str, val)
{
    //如果为空，则通过校验
    if (str == "")
        return true;
    if (typeof(val) != "string")
        val = val + "";
    if (checkIsInteger(str) == true)
    {
        if (parseInt(str, 10) >= parseInt(val, 10))
            return true;
        else
            return false;
    }
    else
        return false;
}
//~~~
/**
 * auther:yinxy
 * 
 *校验整型最大值
 *str：要校验的串。  val：比较的值
 *
 *返回值：
 *如果为空，定义校验通过，                返回true
 *如果满足条件，小于等于给定值，校验通过，返回true
 *如果大于给定值，                        返回false       参考提示信息：输入值不能大于给定值！
 */
function checkIntegerMaxValue(str, val)
{
    //如果为空，则通过校验
    if (str == "")
        return true;
    if (typeof(val) != "string")
        val = val + "";
    if (checkIsInteger(str) == true)
    {
        if (parseInt(str, 10) <= parseInt(val, 10))
            return true;
        else
            return false;
    }
    else
        return false;
}
//~~~
/**
 * auther:yinxy
 * 
 *校验整型是否为非负数
 *str：要校验的串。
 *
 *返回值：
 *如果为空，定义校验通过，返回true
 *如果非负数，            返回true
 *如果是负数，            返回false               参考提示信息：输入值不能是负数！
 */
function isNotNegativeInteger(str, name)
{
    //如果为空，则通过校验
    // if (str == "")
    //     return true;
    if (checkIsInteger(str, name) == true)
    {
        if (parseInt(str, 10) < 0) {
            alert("“" + name + "”不能为负数");
            return false;
        }
        else
            return true;
    }
    else {
        //  alert("“" + name + "”前后不能有空格，输入的必须为数字！");
        return false;
    }

}

/**
 * auther:yinxy
 * 
 *校验整型是否为正整数()
 *str：要校验的串。
 *
 *返回值：
 *如果正整数，            返回true
 *如果是整数（包括0），            返回false               参考提示信息：输入值不能是负数！
 */
function isPositiceInteger(str, name)
{
    if (/^[0-9]*[1-9][0-9]*$/.test(str)) {
        return true;
    } else {
      alert("“" + name + "”前后不能有空格，输入的必须为数字！");
      return false;
    }

}
//~~~
/*--------------------------------- Integer --------------------------------------*/
/********************************** Double ****************************************/
/**
 * auther:yinxy
 * 
 *校验字符串是否为浮点型
 *返回值：
 *如果为空，定义校验通过，      返回true
 *如果字串为浮点型，校验通过，  返回true
 *如果校验不通过，              返回false     参考提示信息：输入域不是合法的浮点数！
 */
function checkIsDouble(str, name)
{
    //如果为空，则通过校验
    if (str == "")
        return true;
    //如果是整数，则校验整数的有效性
    if (str.indexOf(".") == -1)
    {
        if (checkIsInteger(str, name) == true)
            return true;
        else
            return false;
    }
    else
    {
        if (/^(\-?)(\d+)(.{1})(\d+)$/g.test(str))
            return true;
        else {
            alert("输入的" + name + "必须是整数或是小数型")
            return false;
        }
    }
}

/********************* yinxy     验证浮点型为数 ************************/
function checkDoubleLength(str, start, end, name)
{
    //如果为空，则通过校验
    if (str == "")
        return true;

    if (checkIsDouble(str, name) == true) {
        var s = str.split(".");
        if (s[1] != null) {
            if (s[0].length > start) {
                alert("输入的" + name + "小数点前最多" + start + "位");
                return false;
            }
            else if (s[1].length > end) {
                alert("输入的" + name + "小数点后最多" + end + "位");
                return false;
            }
            return true;
        }
        else {
            if (str.length > start) {
                alert("输入的" + name + "最多" + start + "位");
                return false;
            }
            return true;
        }
        return true;
    }
    else
        return false;
}


//~~~
/**
 * auther:yinxy
 * 
 *校验浮点型最小值
 *str：要校验的串。  val：比较的值
 *
 *返回值：
 *如果为空，定义校验通过，                返回true
 *如果满足条件，大于等于给定值，校验通过，返回true
 *如果小于给定值，                        返回false              参考提示信息：输入域不能小于给定值！
 */
function checkDoubleMinValue(str, val, name)
{
    //如果为空，则通过校验
    if (str == "")
        return true;
    if (typeof(val) != "string")
        val = val + "";
    if (checkIsDouble(str) == true) {

        if (parseFloat(str) >= parseFloat(val))
            return true;
        else
            return false;

    }
    else
        return false;
}
//~~~
/**
 * auther:yinxy
 * 
 *校验浮点型最大值
 *str：要校验的串。  val：比较的值
 *
 *返回值：
 *如果为空，定义校验通过，                返回true
 *如果满足条件，小于等于给定值，校验通过，返回true
 *如果大于给定值，                        返回false       参考提示信息：输入值不能大于给定值！
 */
function checkDoubleMaxValue(str, val, name)
{
    //如果为空，则通过校验
    if (str == "")
        return true;
    if (typeof(val) != "string")
        val = val + "";
    if (checkIsDouble(str, name) == true)
    {
        if (parseFloat(str) <= parseFloat(val))
            return true;
        else {
            alter("输入的" + name + "超长，不能超过" + val);
            return false;
        }
    }
    else
        return false;
}
//~~~
/**
 * auther:yinxy
 * 
 *校验浮点型是否为非负数
 *str：要校验的串。
 *
 *返回值：
 *如果为空，定义校验通过，返回true
 *如果非负数，            返回true
 *如果是负数，            返回false               参考提示信息：输入值不能是负数！
 */
function isNotNegativeDouble(str, name)
{
    //如果为空，则通过校验
    if (str == "")
        return true;
    if (checkIsDouble(str, name) == true)
    {
        if (parseFloat(str) < 0){
        	alert("“"+name+"”不能为负数");
            return false;
        }else
            return true;
    }
    else
        return false;
}
//~~~
/*--------------------------------- Double ---------------------------------------*/


//~~~
/*--------------------------------- date -----------------------------------------*/
/********************************** email *****************************************/
/**
 * auther:yinxy
 * 
 *校验字符串是否为email型
 *返回值：
 *如果为空，定义校验通过，           返回true
 *如果字串为email型，校验通过，      返回true
 *如果email不合法，                  返回false    参考提示信息：Email的格式不正確！
 */
function checkEmail(str, name)
{
    //如果为空，则通过校验
    if (str == "")
        return true;
    if (str.charAt(0) == "." || str.charAt(0) == "@" || str.indexOf('@', 0) == -1
            || str.indexOf('.', 0) == -1 || str.lastIndexOf("@") == str.length - 1 || str.lastIndexOf(".") == str.length - 1) {
        alert("输入的“" + name + "”格式错误");
        return false;
    }
    else {
        return true;
    }
}
//~~~
/*--------------------------------- email ----------------------------------------*/
/********************************** chinese ***************************************/
/**
 * auther:yinxy
 * 
 *校验字符串是否为中文
 *返回值：
 *如果为空，定义校验通过，           返回true
 *如果字串为中文，校验通过，         返回true
 *如果字串为非中文，             返回false    参考提示信息：必须为中文！
 */
function checkIsChinese(str)
{
    //如果值为空，通过校验
    if (str == "")
        return true;
    var pattern = /^([\u4E00-\u9FA5]|[\uFE30-\uFFA0])*$/gi;
    if (pattern.test(str))
        return true;
    else
        return false;
}
//~~~
/**
 * 计算字符串的长度，一个汉字两个字符
 */
String.prototype.realLength = function()
{
    return this.replace(/[^\x00-\xff]/g, "**").length;
}
/*--------------------------------- chinese --------------------------------------*/
/********************************** mask ***************************************/
/**auther:yinxy
 * 
 *校验字符串是否符合自定义正则表达式
 *str 要校验的字串  pat 自定义的正则表达式
 *返回值：
 *如果为空，定义校验通过，           返回true
 *如果字串符合，校验通过，           返回true
 *如果字串不符合，                   返回false    参考提示信息：必须满足***模式
 */
function checkMask(str, pat)
{
    //如果值为空，通过校验
    if (str == "")
        return true;
    var pattern = new RegExp(pat, "gi")
    if (pattern.test(str))
        return true;
    else
        return false;
}
//~~~
/*--------------------------------- mask --------------------------------------*/
/********************************** file ***************************************/
/**
 * auther:yinxy
 * 
 * added by LxcJie 2004.6.25
 * 得到文件的后缀名
 * oFile为file控件对象
 */
function getFilePostfix(oFile)
{
    if (oFile == null)
        return null;
    var pattern = /(.*)\.(.*)$/gi;
    if (typeof(oFile) == "object")
    {
        if (oFile.value == null || oFile.value == "")
            return null;
        var arr = pattern.exec(oFile.value);
        return RegExp.$2;
    }
    else if (typeof(oFile) == "string")
    {
        var arr = pattern.exec(oFile);
        return RegExp.$2;
    }
    else
        return null;
}


// 
function checkRequired(value, name) {
    if (value == "") {
        alert("“" + name + "”必填");
        return false;
    }
    return true;
}

function checkSelected(value, name) {
    if (value == -1) {
        alert("“" + name + "”没有选择");
        return false;
    }
    return true;
}

function chectNumber(value, name) {
    var Letters = "1234567890";
    var i;
    var c;

    for (i = 0; i < value.length; i++)
    {
        c = value.charAt(i);
        if (Letters.indexOf(c) == -1)
        {
            alert(name);
            return false;
        }
    }
    return true;
}

function checkSign(value, name) {
    if (value.substring(0, 1) == "`") {
        alert("输入的“" + name + "”不要以“｀”开头");
        return false;
    }
    return true;
}


/*
 * auther:yinxy
 */
function clearAllTextField() {
    for (var i = 0; i < document.forms[0].elements.length; i++) {
        if (document.forms[0].elements[i].type == 'text' || document.forms[0].elements[i].type == 'textarea') {
            document.forms[0].elements[i].value = "";
        }
    }
}
//清空下拉选
function clearAllSelectField() {
    for (var i = 0; i < document.forms[0].elements.length; i++) {
        if (document.forms[0].elements[i].type == 'select-one') {
            document.forms[0].elements[i].options.selectedIndex = 0;
        }
    }
}

//重置页面表单域
//参数formIndex为需要重置的form的序号，默认为第一个form
function resetQuery(formIndex) {
    if (formIndex == undefined)
        formIndex = 0;
    var inputfields = document.forms[formIndex].getElementsByTagName("input");
    for (i = 0; i < inputfields.length; i++) {
        if (inputfields[i].type == "checkbox")
            inputfields[i].checked = false;
        else if (inputfields[i].type == "text")
            inputfields[i].value = "";
        else if (inputfields[i].type == "radio")
            inputfields[i].checked = false;
    }
    var textareafields = document.forms[formIndex].getElementsByTagName("textarea");
    for (i = 0; i < textareafields.length; i++) {
        textareafields[i].value = "";
    }
    var selectfields = document.forms[formIndex].getElementsByTagName("select");
    for (i = 0; i < selectfields.length; i++) {
        selectfields[i].options[0].selected = true;
    }
}

//
function disableAllBts() {
    for (var f = 0; f < document.forms.length; f++) {
        for (var i = 0; i < document.forms[f].elements.length; i++) {
            if (document.forms[f].elements[i].type == 'button' || document.forms[f].elements[i].type == 'submit' ||
                document.forms[f].elements[i].type == 'reset') {
                document.forms[f].elements[i].disabled = true;
            }
        }
    }
}

//  验证IP地址合法性
function checkIp(value)
{
    if (value == "") {
        return true;
    }
    var pattern = /^(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9])\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9]|0)\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[1-9]|0)\.(25[0-5]|2[0-4][0-9]|[0-1]{1}[0-9]{2}|[1-9]{1}[0-9]{1}|[0-9])$/;
    flag_ip = pattern.test(value);
    if (!flag_ip) {
        alert("IP地址输入非法!");
        return false;
    }
    return true;
}

// 去除左右空格并将去除空格的值赋回表单
function trimAll(formIndex) {
    if (formIndex == undefined)
        formIndex = 0;
    var fields = document.forms[formIndex].getElementsByTagName("input");
    for (i = 0; i < fields.length; i++) {
        var field = fields[i];
        if (field.type == "text")
            field.value = field.value.trim();
    }
    return true;
}

//验证输入的字段中不能含有空格  
function checkAllNullSign(value, name, length) {
    for (var i = 0; i < length; i++) {
        if (value.substring(i, i + 1) == " ") {
            alert("输入的" + name + "中不能含有空格");
            return false;
        }
    }
    return true;
}
//验证输入的字段首尾不能含有空格  
function checkNullSign(value, name, length) {
    if (value.substring(0, 1) == " ") {
        alert("输入的" + name + "中开始不能含有空格");
        return false;
    }
    if (value.substring(length - 1, length) == " ") {
        alert("输入的" + name + "中末尾不能含有空格");
        return false;
    }
    return true;
}
//验证查询条件中不能含有“'”  
function checkOtherSign(value, name, length) {
    for (var i = 0; i < length; i++) {
        if (value.substring(i, i + 1) == "'") {
            alert("输入的" + name + "中不能含有“ ' ”字符");
            return false;
        }
    }
    return true;
}

//验证输入字符中是否含有“+ ？% '”特殊字符
function checkSpectCharactor(value,name,length){
     for(var i=0;i < length; i++){
         if(value.substring(i, i+1) == "'" || value.substring(i, i+1) == "+" || value.substring(i, i+1) == "%" || value.substring(i,i+1) == "?"){
             alert("输入的" + name + "中不能包含“+ ？% '”特殊字符！");
             return false;
         }
     }
     return true;
 }
/**
 * auther:yinxy
 *
 * 验证时间是否符合格式
 * 正确格式：yyyy-MM-dd HH:mm:ss
 *
 * str:验证的时间串
 * name:验证的时间名字
 *
 * str为空通过验证  str不为空进行格式验证
 *
 * return:  验证通过返回true 失败返回false
 */
function checkDate(str, name) {
    if (str != null) {
        if (str.length != 19) {
            alert("'" + name + "' 的格式不符合要求,请重新填写.(正确格式:yyyy-MM-dd HH:mm:ss) ");
            return false;
        }
    }

    var a = str.match(/^(\d{0,4})-(\d{0,2})-(\d{0,2}) (\d{0,2}):(\d{0,2}):(\d{0,2})$/);
    if (a != null) {
        var day;
        var tmp = new Date(a[1], a[2], 0);
        if (tmp.getDate() <= 28) {
            day = 29;
        } else if (tmp.getDate() <= 29) {
            day = 30;
        } else if (tmp.getDate() <= 30) {
            day = 31;
        } else if (tmp.getDate() <= 31) {
            day = 32;
        }
        if (a[2] >= 13 || a[3] >= day || a[4] >= 24 || a[5] >= 60 || a[6] >= 60) {
            alert("'" + name + "' 的格式不符合要求或日期无效,请重新填写.(正确格式:yyyy-MM-dd HH:mm:ss) ");
            return false;
        }
    }
    var time = str.split(" ");
    if(!checkIsValidDay(time[0])){
       alert("'" + name + "' 的格式不符合要求,请重新填写.(正确格式:yyyy-MM-dd HH:mm:ss) ");
        return false;
    } 
    if(!checkIsValidTime(time[1])){
       alert("'" + name + "' 的格式不符合要求,请重新填写.(正确格式:yyyy-MM-dd HH:mm:ss) ");
        return false;  
    }
    return true;
}

/**
 * auther:yinxy
 *
 * 验证时间是否符合格式
 * 正确格式：yyyy-MM-dd HH:mm
 *
 * str:验证的时间串
 * name:验证的时间名字
 *
 * str为空通过验证  str不为空进行格式验证
 *
 * return:  验证通过返回true 失败返回false
 */
function checkDates(str, name) {
    if (str != null) {
        if (str.length != 16) {
            alert("'" + name + "' 的格式不符合要求,请重新填写.(正确格式:yyyy-MM-dd HH:mm) ");
            return false;
        }
    }

    var a = str.match(/^(\d{0,4})-(\d{0,2})-(\d{0,2}) (\d{0,2}):(\d{0,2}):(\d{0,2})$/);
    if (a != null) {
        var day;
        var tmp = new Date(a[1], a[2], 0);
        if (tmp.getDate() <= 28) {
            day = 29;
        } else if (tmp.getDate() <= 29) {
            day = 30;
        } else if (tmp.getDate() <= 30) {
            day = 31;
        } else if (tmp.getDate() <= 31) {
            day = 32;
        }
        if (a[2] >= 13 || a[3] >= day || a[4] >= 24 || a[5] >= 60) {
            alert("'" + name + "' 的格式不符合要求或日期无效,请重新填写.(正确格式:yyyy-MM-dd HH:mm) ");
            return false;
        }
    }
    var time = str.split(" ");
    if(!checkIsValidDay(time[0])){
       alert("'" + name + "' 的格式不符合要求,请重新填写.(正确格式:yyyy-MM-dd HH:mm) ");
        return false;
    } 
    if(!checkIsValidTimes(time[1])){
       alert("'" + name + "' 的格式不符合要求,请重新填写.(正确格式:yyyy-MM-dd HH:mm) ");
        return false;  
    }
    return true;
}

/**
 * auther:yinxy
 *
 * 验证开始时间不能大于结束时间
 * 验证的时间格式是：yyyy-MM-dd HH:mm:ss ; yyyy-MM-dd ; yyyy-MM-dd HH:mm
 *
 * beginTime:开始时间串
 * endTime:结束时间串
 * beginName:验证的开始时间名字
 * endName:验证的结束时间名字
 *
 * beginTime,endTime为空通过验证  beginTime,endTime不为空进行格式验证
 *
 * return:  验证通过返回true 失败返回false
 */
function checkTime(beginTime, endTime, beginName, endName) {

    if (beginTime != "" && endTime != "") {
        if ((beginTime.length == 19 && endTime.length == 19) || (beginTime.length == 16 && endTime.length == 16)) {     //验证的时间格式是：yyyy-MM-dd HH:mm:ss , yyyy-MM-dd HH:mm
             if (!checkDay(beginTime, endTime)) {
                  alert("'" + beginName + "' 中的日期大于 '" + endName + "' 中的日期");
                return false;
            }
        } else if (beginTime.length == 10 && endTime.length == 10) {   //验证的时间格式是：yyyy-MM-dd
            if (!checkAfterTime(beginTime, endTime)) {
                alert("'" + beginName + "' 中的日期大于 '" + endName + "' 中的日期");
                return false;
            }
            return true;
        } 
        return true;
    }
    return true;
}

/**
 * 
 *
 * 验证时间大于当前时间
 * 验证的时间格式是：yyyy-MM-dd HH:mm:ss ; yyyy-MM-dd ; yyyy-MM-dd HH:mm
 *
 * str:验证时间串
 * name:验证时间名字
 *
 * str为空通过验证  str不为空进行格式验证
 *
 * return:  验证通过返回true 失败返回false
 */
function compareDate(str, name) {

    if (str != "") {
        var today = new Date();
        var strToDay = today.getYear() + "-";
        if ((today.getMonth() + 1) < 10) {
            strToDay = strToDay + "0" + (today.getMonth() + 1);
        } else {
            strToDay = strToDay + (today.getMonth() + 1);
        }
        if (today.getDate() < 10) {
            strToDay = strToDay + "-0" + today.getDate();
        } else {
            strToDay = strToDay + "-" + today.getDate();
        }
        if (today.getHours() < 10) {
            strToDay = strToDay + " 0" + today.getHours();
        } else {
            strToDay = strToDay + " " + today.getHours();
        }
        if (today.getMinutes() < 10) {
            strToDay = strToDay + ":0" + today.getMinutes();
        } else {
            strToDay = strToDay + ":" + today.getMinutes();
        }
        if (today.getSeconds() < 10) {
            strToDay = strToDay + ":0" + today.getSeconds();
        } else {
            strToDay = strToDay + ":" + today.getSeconds();
        }
        var toDay = strToDay.split(" ");
        if (str.length == 19) {       //验证的时间格式是：yyyy-MM-dd HH:mm:ss
            if (!checkDay(strToDay, str)) {
                alert("'" + name + "' 必须大于 '当前时间 " + strToDay + " '");
                return false;
            }
        } else if (str.length == 16) {      //验证的时间格式是： yyyy-MM-dd HH:mm
             if (!checkDay(strToDay, str)) {
                alert("'" + name + "' 必须大于 '当前时间 " + strToDay + " '");
                return false;
            }
        } else if (str.length = 10) {   //验证的时间格式是：yyyy-MM-dd
            if (!checkAfterTime(toDay[0], str)) {
                alert("'" + name + "' 必须大于 '当前时间 " + toDay[0] + " '");
                return false;
            }
        }
        return true;
    }
    return true;
}


/********************************** date ******************************************/
/**
 *校验字符串是否为日期型
 *返回值：
 *如果为空，定义校验通过，           返回true
 *如果字串为日期型，校验通过，       返回true
 *如果日期不合法，                   返回false    参考提示信息：输入域的时间不合法！（yyyy-MM-dd）
 */
function checkIsValidDate(str)
{
    //如果为空，则通过校验
    //  if (str == "")
    //     return true;
    var pattern = /^((\d{4})|(\d{2}))-(\d{1,2})-(\d{1,2})$/g;
    if (!pattern.test(str)) {
        //  alert("时间格式不正确");
        return false;
    }

    var arrDate = str.split("-");
    if (parseInt(arrDate[0], 10) < 100)
        arrDate[0] = 2000 + parseInt(arrDate[0], 10) + "";
    var date = new Date(arrDate[0], (parseInt(arrDate[1], 10) - 1) + "", arrDate[2]);
    if (date.getYear() == arrDate[0]
            && date.getMonth() == (parseInt(arrDate[1], 10) - 1) + ""
            && date.getDate() == arrDate[2])
        return true;
    else {
        // alert("时间格式不正确");
        return false;
    }
}
//~~~
/**
 *校验两个日期的先后
 *返回值：
 *如果其中有一个日期为空，校验通过,          返回true
 *如果起始日期早于等于终止日期，校验通过，   返回true
 *如果起始日期晚于终止日期，                 返回false    参考提示信息： 起始日期不能晚于结束日期。
 */
function checkDateEarlier(strStart, strEnd)
{
    if (checkIsValidDate(strStart) == false || checkIsValidDate(strEnd) == false) {
        alert("时间格式不正确");
        return false;
    }
    //如果有一个输入为空，则通过检验
    //  if (( strStart == "" ) || ( strEnd == "" ))
    //     return true;
    var arr1 = strStart.split("-");
    var arr2 = strEnd.split("-");
    var date1 = new Date(arr1[0], parseInt(arr1[1].replace(/^0/, ""), 10) - 1, arr1[2]);
    var date2 = new Date(arr2[0], parseInt(arr2[1].replace(/^0/, ""), 10) - 1, arr2[2]);
    if (arr1[1].length == 1)
        arr1[1] = "0" + arr1[1];
    if (arr1[2].length == 1)
        arr1[2] = "0" + arr1[2];
    if (arr2[1].length == 1)
        arr2[1] = "0" + arr2[1];
    if (arr2[2].length == 1)
        arr2[2] = "0" + arr2[2];
    var d1 = arr1[0] + arr1[1] + arr1[2];
    var d2 = arr2[0] + arr2[1] + arr2[2];
    if (parseInt(d1, 10) > parseInt(d2, 10)) {
        alert("开始时间不能晚于结束时间");
        return false;
    }
    else
        return true;
}


/**
 * 
 *
 * 验证开始时间等于结束时间  则返回false
 * 验证的时间格式是：yyyy-MM-dd
 *
 * beginTime:开始时间串
 * endTime:结束时间串
 *
 */
function checkDateEarlierEq(strStart, strEnd)
{
    var arr1 = strStart.split("-");
    var arr2 = strEnd.split("-");
    var date1 = new Date(arr1[0], parseInt(arr1[1].replace(/^0/, ""), 10) - 1, arr1[2]);
    var date2 = new Date(arr2[0], parseInt(arr2[1].replace(/^0/, ""), 10) - 1, arr2[2]);
    if (arr1[1].length == 1)
        arr1[1] = "0" + arr1[1];
    if (arr1[2].length == 1)
        arr1[2] = "0" + arr1[2];
    if (arr2[1].length == 1)
        arr2[1] = "0" + arr2[1];
    if (arr2[2].length == 1)
        arr2[2] = "0" + arr2[2];
    var d1 = arr1[0] + arr1[1] + arr1[2];
    var d2 = arr2[0] + arr2[1] + arr2[2];
    if (parseInt(d1, 10) == parseInt(d2, 10)) {
        return false;
    }
    else
        return true;
}
/**
 * 
 *
 * 验证开始时间不小于结束时间
 * 验证的时间格式是：yyyy-MM-dd
 *
 * beginTime:开始时间串
 * endTime:结束时间串
 *
 * strStart,strEnd为空通过验证  strStart,strEnd不为空进行格式验证
 *
 * return:  验证通过返回true 失败返回false
 */
function checkAfterTime(strStart, strEnd)
{
    if (strStart != "" && strEnd != "") {
        var arr1 = strStart.split("-");
        var arr2 = strEnd.split("-");
        var date1 = new Date(arr1[0], parseInt(arr1[1].replace(/^0/, ""), 10) - 1, arr1[2]);
        var date2 = new Date(arr2[0], parseInt(arr2[1].replace(/^0/, ""), 10) - 1, arr2[2]);
        if (arr1[1].length == 1)
            arr1[1] = "0" + arr1[1];
        if (arr1[2].length == 1)
            arr1[2] = "0" + arr1[2];
        if (arr2[1].length == 1)
            arr2[1] = "0" + arr2[1];
        if (arr2[2].length == 1)
            arr2[2] = "0" + arr2[2];
        var d1 = arr1[0] + arr1[1] + arr1[2];
        var d2 = arr2[0] + arr2[1] + arr2[2];
        if (parseInt(d1, 10) > parseInt(d2, 10)) {
            return false;
        }
            return true;
    }
      return true;
}

/**
 * 
 *
 * 验证时间的合法性
 * 验证的时间格式是：HH:mm:ss
 *
 * str:时间串
 
 * return:  验证通过返回true 失败返回false
 */
function checkIsValidTime(str) {
    var pattern = /^(20|21|22|23|[0-1]?\d):[0-5]?\d:[0-5]?\d$/;
    if (!pattern.test(str)) {
        return false;
    }
    return true;
}

/**
 * 
 *
 * 验证时间的合法性
 * 验证的时间格式是：HH:mm
 *
 * str:时间串
 
 * return:  验证通过返回true 失败返回false
 */
function checkIsValidTimes(str) {
    var pattern = /^(20|21|22|23|[0-1]?\d):[0-5]?\d$/;
    if (!pattern.test(str)) {
        return false;
    }
    return true;
}

/**
 * auther:yinxy
 *
 * 验证时间的合法性
 * 验证的时间格式是：yyyy-MM-dd
 *
 * str:时间串

 * return:  验证通过返回true 失败返回false
 */
function checkIsValidDay(str) {
     var pattern = /^((\d{4})|(\d{2}))-(\d{1,2})-(\d{1,2})$/g;
    if (!pattern.test(str)) {
        return false;
    }
    return true;
}
    
/**
 * auther:yinxy
 *
 * 验证开始时间不能大于结束时间
 * 验证的时间格式是：HH:mm:ss 、 HH:mm 、 HH
 *
 * beginTime:开始时间串
 * endTime:结束时间串
 *
 * beginTime,endTime为空通过验证  beginTime,endTime不为空进行格式验证
 *
 * return:  验证通过返回true 失败返回false
 */
function compareWithTime(beginTime, endTime) {
    if (beginTime != "" && endTime != "") {
        var arrDate1 = beginTime.split(":");
        var arrDate2 = endTime.split(":");
        if (parseInt(arrDate1[0], 10) > parseInt(arrDate2[0], 10)) {
            return false;
        }
        else if (parseInt(arrDate1[0], 10) == parseInt(arrDate2[0], 10)) {
            if (arrDate1[1] != undefined && arrDate2[1] != undefined) {
                if (parseInt(arrDate1[1], 10) > parseInt(arrDate2[1], 10)) {
                    return false;
                }
                else if (parseInt(arrDate1[1], 10) == parseInt(arrDate2[1], 10)) {
                    if (arrDate1[2] != undefined && arrDate2[2] != undefined) {
                        if (parseInt(arrDate1[2], 10) > parseInt(arrDate2[2], 10))
                            return false;
                    }
                }
            }
        }
        return true;
    }
    return true;
}
/**
 * auther:yinxy
 *
 * 验证开始时间不小于结束时间
 * 验证的时间格式是：yyyy-MM-dd HH:mm:ss
 *
 * strStart:开始时间串
 * strEnd:结束时间串
 *
 * strStart,strEnd为空通过验证  strStart,strEnd不为空进行格式验证
 *
 * return:  验证通过返回true 失败返回false
 */

function checkDay(strStart, strEnd)
{
    if (strStart != "" && strEnd != "") {
        var str1 = strStart.split(" ");
        var str2 = strEnd.split(" ");
        var arr1 = str1[0].split("-");
        var arr2 = str2[0].split("-");
        var date1 = new Date(arr1[0], parseInt(arr1[1].replace(/^0/, ""), 10) - 1, arr1[2]);
        var date2 = new Date(arr2[0], parseInt(arr2[1].replace(/^0/, ""), 10) - 1, arr2[2]);
        if (arr1[1].length == 1)
            arr1[1] = "0" + arr1[1];
        if (arr1[2].length == 1)
            arr1[2] = "0" + arr1[2];
        if (arr2[1].length == 1)
            arr2[1] = "0" + arr2[1];
        if (arr2[2].length == 1)
            arr2[2] = "0" + arr2[2];
        var d1 = arr1[0] + arr1[1] + arr1[2];
        var d2 = arr2[0] + arr2[1] + arr2[2];
        if (parseInt(d1, 10) > parseInt(d2, 10)) {
            return false;
        }
        if(parseInt(d1, 10) == parseInt(d2, 10)){
            if(!compareWithTime(str1[1],str2[1])){
               return false;
            }
        }
            return true;
    }
      return true;
}

/**
 * auther:yinxy
 *
 * 验证时间大于当前时间
 * 验证的时间格式是：yyyy-MM-dd HH:mm:ss ; yyyy-MM-dd ; yyyy-MM-dd HH:mm
 *
 * str:验证时间串
 * name:验证时间名字
 *
 * str为空通过验证  str不为空进行格式验证
 *
 * 不弹出提示框
 * return:  验证通过返回true 失败返回false
 */
function compareDates(str) {

    if (str != "") {
        var today = new Date();
        var strToDay = today.getYear() + "-";
        if ((today.getMonth() + 1) < 10) {
            strToDay = strToDay + "0" + (today.getMonth() + 1);
        } else {
            strToDay = strToDay + (today.getMonth() + 1);
        }
        if (today.getDate() < 10) {
            strToDay = strToDay + "-0" + today.getDate();
        } else {
            strToDay = strToDay + "-" + today.getDate();
        }
        if (today.getHours() < 10) {
            strToDay = strToDay + " 0" + today.getHours();
        } else {
            strToDay = strToDay + " " + today.getHours();
        }
        if (today.getMinutes() < 10) {
            strToDay = strToDay + ":0" + today.getMinutes();
        } else {
            strToDay = strToDay + ":" + today.getMinutes();
        }
        if (today.getSeconds() < 10) {
            strToDay = strToDay + ":0" + today.getSeconds();
        } else {
            strToDay = strToDay + ":" + today.getSeconds();
        }
        var toDay = strToDay.split(" ");
        if (str.length == 19) {       //验证的时间格式是：yyyy-MM-dd HH:mm:ss
            if (!checkDay(strToDay, str)) {
                return false;
            }
        } else if (str.length == 16) {      //验证的时间格式是： yyyy-MM-dd HH:mm
             if (!checkDay(strToDay, str)) {
                return false;
            }
        } else if (str.length = 10) {   //验证的时间格式是：yyyy-MM-dd
            if (!checkAfterTime(toDay[0], str)) {
                return false;
            }
        }
        return true;
    }
    return true;
}

/**
 * auther:yinxy
 *
 * 验证开始时间不能大于结束时间
 * 验证的时间格式是：yyyy-MM-dd HH:mm:ss ; yyyy-MM-dd ; yyyy-MM-dd HH:mm
 *
 * beginTime:开始时间串
 * endTime:结束时间串
 * beginName:验证的开始时间名字
 * endName:验证的结束时间名字
 *
 * 无弹出对话框
 * beginTime,endTime为空通过验证  beginTime,endTime不为空进行格式验证
 *
 * return:  验证通过返回true 失败返回false
 */
function checkDateTime(beginTime, endTime) {

    if (beginTime != "" && endTime != "") {
        if ((beginTime.length == 19 && endTime.length == 19) || (beginTime.length == 16 && endTime.length == 16)) {     //验证的时间格式是：yyyy-MM-dd HH:mm:ss , yyyy-MM-dd HH:mm
             if (!checkDay(beginTime, endTime)) {
                return false;
            }
        } else if (beginTime.length == 10 && endTime.length == 10) {   //验证的时间格式是：yyyy-MM-dd
            if (!checkAfterTime(beginTime, endTime)) {
                return false;
            }
            return true;
        } 
        return true;
    }
    return true;
}