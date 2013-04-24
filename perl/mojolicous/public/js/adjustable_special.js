function findArray(str){
	var array;
	if(str=="0001"||str=="客户托收备付金") 
	array=new Array('客户编号','产品类型','交易编码','交易成功日期');//客户托收备付金
	if(str=="0002"||str=="备付金存款") 
	array=new Array('银行账户号');//备付金存款
	if(str=="0003"||str=="成本") 
	array=new Array('客户编号','产品类型','交易编码');//成本
	if(str=="0004"||str=="收入") 
	array=new Array('客户编号','产品类型','交易编码');//收入
	if(str=="0005"||str=="往来") 
	array=new Array('应收自有','应付备付','应收备付','应付自有');//往来
	if(str=="0006"||str=="未结客户款") 
	array=new Array('客户编号','审核状态','账户号');//未结客户款
	if(str=="0007"||str=="已核应付银行款") 
	array=new Array('银行账户号','技术接口编号','资金对账日期');//已核应付银行款
	if(str=="0008"||str=="已核应付银行手续费") 
	array=new Array('银行账户号','技术接口编号','资金对账日期');//已核应付银行手续费
	if(str=="0009"||str=="已核应收银行款") 
	array=new Array('银行账户号','技术接口编号','资金对账日期');//已核应收银行款
	if(str=="0010"||str=="银行长款") 
	array=new Array('银行账户号','技术接口编号','差错日期');//银行长款
	if(str=="0011"||str=="银行短款") 
	array=new Array('银行账户号','技术接口编号','差错日期');//银行短款
	if(str=="0012"||str=="客户冻结备付金") 
	array=new Array('客户编号','冻结日期');//客户冻结备付金
	if(str=="0013"||str=="客户托管备付金") 
	array=new Array('客户编号','账户号');//客户托管备付金
	if(str=="0014"||str=="已核应收银行手续费") 
	array=new Array('银行账户号','技术接口编号','资金对账日期');//已核应收银行手续费
	if(str=="0015"||str=="自有资金存款") 
	array=new Array('银行账户号');//自有资金存款
	if(str=="0016"||str=="应付银行款") 
	array=new Array('银行账户号','客户银行账户号','提交日期','技术接口编号');//应付银行款
	if(str=="0017"||str=="应付银行手续费") 
	array=new Array('银行账户号','技术接口编号');//应付银行手续费
	if(str=="0018"||str=="应付费用") 
	array=new Array('');//应付费用
	if(str=="0019"||str=="应付客户款") 
	array=new Array('客户编号','资金性质','提交日期');//应付客户款
	return array;
}			
function findName(s){
	var name;
	if(s=="0001") 
	name="客户托收备付金";
	if(s=="0002")
	name="备付金存款";
	if(s=="0003")
	name="成本";
	if(s=="0004") 
	name="收入";
	if(s=="0005") 
	name="往来";
	if(s=="0006")
	name="未结客户款";
	if(s=="0007")
	name="已核应付银行款";
	if(s=="0008")
	name="已核应付银行手续费";
	if(s=="0009")
	name="已核应收银行款";
	if(s=="0010")
	name="银行长款";
	if(s=="0011")
	name="银行短款";
	if(s=="0012")
	name="客户冻结备付金";
	if(s=="0013")
	name="客户托管备付金";
	if(s=="0014")
	name="已核应收银行手续费";
	if(s=="0015")
	name="自有资金存款";
	if(s=="0016")
	name="应付银行款";
	if(s=="0017")
	name="应付银行手续费";
	if(s=="0018")
	name="应付费用";
	if(s=="0019")
	name="应付客户款";				
	return name;
}
function findArr(str){
	var array;
	if(str=="0001"||str=="客户托收备付金") 
	array=new Array('C_ID','P_ID','TX_CODE','TX_DATE');//客户托收备付金
	if(str=="0002"||str=="备付金存款") 
	array=new Array('B_ACCT');//备付金存款
	if(str=="0003"||str=="成本") 
	array=new Array('C_ID','P_ID','TX_CODE');//成本
	if(str=="0004"||str=="收入") 
	array=new Array('C_ID','P_ID','TX_CODE');//收入
	if(str=="0005"||str=="往来") 
	array=new Array('YSZY','YFBF','YSBF','YFZY');//往来
	if(str=="0006"||str=="未结客户款") 
	array=new Array('C_ID','AP_STATUS','B_ACCT');//未结客户款
	if(str=="0007"||str=="已核应付银行款") 
	array=new Array('B_ACCT','T_ID','ZJDZ_DATE');//已核应付银行款
	if(str=="0008"||str=="已核应付银行手续费") 
	array=new Array('B_ACCT','T_ID','ZJDZ_DATE');//已核应付银行手续费
	if(str=="0009"||str=="已核应收银行款") 
	array=new Array('B_ACCT','T_ID','ZJDZ_DATE');//已核应收银行款
	if(str=="0010"||str=="银行长款") 
	array=new Array('B_ACCT','T_ID','ERROR_DATE');//银行长款
	if(str=="0011"||str=="银行短款") 
	array=new Array('B_ACCT','T_ID','ERROR_DATE');//银行短款
	if(str=="0012"||str=="客户冻结备付金") 
	array=new Array('C_ID','FREEZE_DATE');//客户冻结备付金
	if(str=="0013"||str=="客户托管备付金") 
	array=new Array('C_ID','B_ACCT');//客户托管备付金
	if(str=="0014"||str=="已核应收银行手续费") 
	array=new Array('B_ACCT','T_ID','ZJDZ_DATE');//已核应收银行手续费
	if(str=="0015"||str=="自有资金存款") 
	array=new Array('B_ACCT');//自有资金存款
	if(str=="0016"||str=="应付银行款") 
	array=new Array('B_ACCT','B_ACCT_CUST','SB_DATE','T_ID');//应付银行款
	if(str=="0017"||str=="应付银行手续费") 
	array=new Array('B_ACCT','T_ID');//应付银行手续费
	if(str=="0018"||str=="应付费用") 
	array=new Array();//应付费用
	if(str=="0019"||str=="应付客户款") 
	array=new Array('C_ID','ZJ_ATTR','TX_DATE');//应付客户款
	return array;
}			
function findKm(s){
	var name;
	if(s=="客户托收备付金") 
	name="001";
	if(s=="备付金存款")
	name="0002";
	if(s=="成本")
	name="0003";
	if(s=="收入") 
	name="004";
	if(s=="往来") 
	name="0005";
	if(s=="未接客户款")
	name="0006";
	if(s=="已核应付银行款")
	name="0007";
	if(s=="已核应付银行手续费")
	name="0008";
	if(s=="已核应收银行款")
	name="0009";
	if(s=="银行长款")
	name="0010";
	if(s=="银行短款")
	name="0011";
	if(s=="客户冻结备付金")
	name="0012";
	if(s=="客户托管备付金")
	name="0013";
	if(s=="已核应收银行手续费")
	name="0014";
	if(s=="自有资金存款")
	name="0015";
	if(s=="应付银行款")
	name="0016";
	if(s=="应付银行手续费")
	name="0017";
	if(s=="应付费用")
	name="0018";
	if(s=="应付客户款")
	name="0019";				
	return name;
}