##################################################################################
#                      通联机构规范8583
##################################################################################
# 说明:
# id:    域号
# type:  检验数据是否只包含指定类型的字符
# len:   数据域长度(如果是固定域的话) || 数据域的最大长度(llvar|lllvar)
# class: 变长|固定长 undef|llvar|lllvar
# denc:  数据域的数据编码方式:
# lenc:  llvar/lllvar数据的长度部分编码方式
##################################################################################
# id   type   len  class        lenc    denc     描述
##################################################################################
  0    n      4    undef        undef   undef    报文标示符 
  1    b      16   undef        undef   undef    bitmap
  2    n      19   undef        undef   undef    主账号
  3    n      6    undef        undef   undef    交易处理码
  4    n      12   undef        undef   undef    交易金额
  5    n      12   undef        undef   undef    清算金额
  6    n      12   undef        undef   undef    持卡人扣账金额
  7    n      10   mmddhhmmss   undef   undef    交易传输时间
  9    n      8    undef        undef   undef    清算汇率
  10   n      8    undef        undef   undef    持卡人扣账汇率
  11   n      6    undef        undef   undef    系统跟踪号
  12   n      6    hhmmss       undef   undef    受卡方所在地时间
  13   n      4    mmdd         undef   undef    受卡方所在地日期
  14   n      4    undef        undef   undef    卡有效期
  15   n      4    undef        undef   undef    清算日期
  16   n      4    undef        undef   undef    兑换日期
  18   n      4    undef        undef   undef    商户类型
  19   n      3    undef        undef   undef    受理机构国家代码
  22   n      3    undef        undef   undef    服务点输入方式码
  23   n      3    undef        undef   undef    卡序列号
  25   n      2    undef        undef   undef    服务点条件码
  26   n      2    undef        undef   undef    服务点PIN获取码
  28   Xn     9    undef        undef   undef    交易费
  32   n      11   llvar        undef   undef    代理机构标识码
  33   n      11   llvar        undef   undef    发送机构标识码
  35   b      37   llvar        undef   undef    第二磁道数据
  36   b      104  lllvar       undef   undef    第三磁道数据
  37   an     12   undef        undef   undef    检索参考号
  38   an     6    undef        undef   undef    授权标识应答码
  39   an     2    undef        undef   undef    应答码
  41   ans    8    undef        undef   undef    受卡机终端标识码
  42   ans    14   undef        undef   undef    受卡方标识码
  43   ans    40   undef        undef   undef    受卡方名称地址
  44   ans    25   llvar        undef   undef    附加响应数据
  45   b      79   llvar        undef   undef    第一磁道数据
  46   ans    255  llvar        undef   undef    附加数据-行业卡数据
  48   b      512  llvar        undef   undef    附加数据——私有
  49   an     3    undef        undef   undef    交易货币代码
  50   an     3    undef        undef   undef    清算货币代码
  51   an     3    undef        undef   undef    持卡人帐户货币代码
  52   b      8    undef        undef   undef    个人标识码数据
  53   n      16   undef        undef   undef    安全控制信息
  54   an     40   lllvar       undef   undef    实际余额
  55   b      255  lllvar       undef   undef    IC卡数据域
  57   ans    100  lllvar       undef   undef    附加交易信息
  58   ans    100  lllvar       undef   undef    IC(PBOC)卡交易数据
  59   ans    600  lllvar       undef   undef    明细查询数据
  60   ans    30   lllvar       undef   undef    自定义域
  61   ans    200  lllvar       undef   undef    持卡人身份认证信息
  62   ans    200  lllvar       undef   undef    交换中心数据
  63   ans    200  lllvar       undef   undef    金融网络数据
  70   n      3    undef        undef   undef    网络管理信息码
  90   n      42   undef        undef   undef    原始数据元
  96   b      8    undef        undef   undef    报文安全码
  100  n      11   llvar        undef   undef    接收机构标识码
  102  ans    28   llvar        undef   undef    帐户标识1
  103  ans    28   llvar        undef   undef    帐户标识2
  121  ans    100  lllvar       undef   undef    交换中心保留
  122  ans    100  lllvar       undef   undef    受理方保留
  123  ans    100  lllvar       undef   undef    发卡方保留
  128  b      8    undef        undef   undef    报文鉴别码
##################################################################################
