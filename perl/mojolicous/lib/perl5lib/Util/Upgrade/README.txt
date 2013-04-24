########################################################
# upgrade server:
########################################################
upgrade_home:
             /version.txt
             /v0.1
                  /list.txt
                  /libexec/ma.pl
                  /libexec/mb.pl
                  /conf/server.conf
                  /conf/client.conf
             /v0.2
                  /list.txt
                  /libexec/mc.pl
                  /libexec/md.pl
                  /conf/server.conf
                  /conf/client.conf

########################################################
# upgrade client:
########################################################
app_home:
        /libexec
        /bin
        /conf
        /etc
        /log


########################################################
# protocol:
########################################################

#-------------------------------------------------------
#  upgrade_check
#-------------------------------------------------------
req: client定期向server发起询问， 是否有版本需要更新 
     {
       action  => 'upgrade_check',
       version => 当前客户端版本号,
     }
res: server收到请求后， 读取$upgrade_home/version.txt获取
     版本历史， 再与客户端比较版本， 确定客户端是否需要更新
     如果确定客户端需要更新， 发送客户端当前需要更新的版本号
     {
       action  => 'upgrade_check',
       status  => 0,
       version => 新版本号  
     }

     客户端收到应答后:
     $self->{new_version} = $res->{version};
     同时发起 upgrade_list请求  

#-------------------------------------------------------
#  upgrade_list
#-------------------------------------------------------
req: 
     {
       action  => 'upgrade_list',
       version => $self->{new_version},
     }

res: 
     {
       action  => 'upgrade_list',
       version => $self->{new_version},
       list    => \@file_list,
     }

#-------------------------------------------------------
#  request_file
#-------------------------------------------------------
req: 
     {
       action   => 'request_file',
       version  => $self->{new_version},
       filename => $filename,
     }

res: 
     {
       action   => 'request_file',
       version  => $self->{new_version},
       filename => $filename,
       content  => $content,
     }
         
