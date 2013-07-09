##db2数据库常用命令.md

### [实例管理](#instance) 
1.  [创建实例](#inst_create)
2.  [启动/停止/列出实例](#inst_start)
3.  [更新实例](#inst_update)
4.  [删除实例](#inst_delete)
5.  [实例参数](#inst_param)  

### [表空间管理](#tablespace)
1.  [表空间创建]()

------------------------------

<h3 id="instance">实例管理</h3>
<h4 id="inst_create">1.创建实例</h4>   

**什么是实例？**  
  
DB2的实例就是一组进程和一组共享内存。可把实例想象为一个数据库的集合，共同运行在一个逻辑服务单元中（同一个端口）。在一个系统中，用户可以创建若干个实例，每一个实例使用各自不同的端口服务于远程应用程序。每一个实例可以包含若干个数据库。  

**创建实例**  
```
[root@canna ~]# /opt/ibm/db2/V9.7/instance/db2icrt -?
DBI1001I  Usage:

 db2icrt [-h|-?]
         [-d]
         [-a AuthType]
         [-p PortName]
         [-s InstType]
         -u FencedID InstName

Explanation: 

An invalid argument was entered for the db2icrt command. Valid arguments
for this command are: 

-h|-?    display the usage information.

-d       turn debug mode on.

-a AuthType
         is the authentication type (SERVER, CLIENT, or SERVER_ENCRYPT)
         for the instance.

-p PortName
         is the port name or port number to be used by this instance.

-s       InstType is the type of instance to be created (ese,wse,
         standalone, or client). 

         ese      used to create an instance for a DB2 database server
                  with local and remote clients with DPF support. This
                  type is the default instance type for DB2 Enterprise
                  Server Edition.

         wse      used to create an instance for a DB2 database server
                  with local and remote clients. This type is the
                  default instance type for DB2 Workgroup Edition, DB2
                  Express or Express-C Edition, and DB2 Connect
                  Enterprise Edition.

         standalone
                  used to create an instance for a DB2 database server
                  with local clients. This type is the default instance
                  type for DB2 Personal Edition.

         client   used to create an instance for a IBM Data Server
                  Client. This type is the default instance type for IBM
                  Data Server Client products and DB2 Connect Personal
                  Edition.

          

         DB2 products support their default instance types and the
         instance types lower than their default ones. For instance, DB2
         Enterprise Edition supports the instance types of 'ese', 'wse',
         'standalone' and 'client'.


-u FencedID
         is the name of the user under which fenced UDFs and fenced
         stored procedures will be run. This flag is not required if
         only a IBM Data Server Client is installed.

InstName is the name of the instance.

User response: 

Confirm that user IDs and group names used to create the DB2 instance
are valid. For information about naming rules, see the topic called
"User, user ID and group naming rules" in the DB2 Information Center.

Refer to the DB2 Information Center for a detailed description of the
command. Correct the syntax and reissue the command.
```
创建服务端实例命令：  
`
db2icrt -a server -s ese -p 55555 -u db2fenc db2inst
`  
上述命令创建了实例名为db2inst的服务端实例，实例的端口为55555，实例的受防护用户为db2fenc。  

**受防护的用户**  

  - 表示用来运行受防护用户定义的函数 (UDF) 和受防护存储过程的用户的名称，受防护的用户用于在 DB2 数据库所使用的地址空间之外运行用户定义的函数（UDF）和存储过程（UDP）。缺省用户为 db2fenc1，缺省组为 db2fadm1。如果不需要此安全级别（例如，在测试环境中），那么可以使用实例所有者作为受防护的用户
  - 如果您正在 DB2 客户机上创建实例，那么此标志不是必需的。  

创建客户端实例命令：  
`
db2icrt -s client ark
`  
上述命令创建了实例名为ark的客户端实例。  

<h4 id="inst_start">2. 启动/停止/列出实例</h4>  

  - 启动实例。实例创建后，需要通过db2start命令启动才能工作。在UNIX平台下，在实例用户环境下启动实例是:  
`
db2start
`
  - 停止实例。停止实例的命令是:  
`
db2stop
`  
如果当前实例下某数据库有应用连接，则db2stop会报错，这时可通过
`
db2 force applications all
`  
把所有应用连接断开，或通过  
`
 db2stop force
`  
强制停止实例。
  - 列出实例。可以通过  
`
db2ilist
`  
查看某个DB2版本下有哪些实例。

**实例停止不了的问题？**  
当遇到`db2stop force`无法停止，而`db2start`也无法启动的问题，在UNIX/LINUX下，可通过`db2_kill`强制终止所有分区上执行的进程，然后执行`ipcclear`清理IPC资源，当重新启动数据库时，DB2会做崩溃恢复。

<h4 id="inst_update">3. 更新实例</h4>

实例更新命令是`db2iupdt`，一般在打补丁或版本升级时使用。`db2iupdt`命令需要root用户执行，执行前需要首先停止实例。

<h4 id="inst_delete">4. 删除实例</h4>
删除实例的命令是`db2idrop`，使用root用户执行，删除前必须停止实例。注意：删除实例并不会删除实例下的数据库。
```
1. db2stop force
2. cd /opt/ibm/db2/V9.7/instance
3. ./db2idrop db2inst
```

<h4 id="inst_param">5. 实例参数</h4>
每个实例都有一个配置参数文件用于控制实例相关的参数，如诊断路径，监控开关，安全相关的控制及服务端口号等。通过`db2 get dbm cfg`命令查看实例参数，以下对一些重要的参数进行来标注：  
! [实例参数1](data/inst_param1.png)
  
! [实例参数2](data/inst_param2.png)

! [实例参数3](data/inst_param3.png)

