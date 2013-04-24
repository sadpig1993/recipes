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
req: client������server����ѯ�ʣ� �Ƿ��а汾��Ҫ���� 
     {
       action  => 'upgrade_check',
       version => ��ǰ�ͻ��˰汾��,
     }
res: server�յ������ ��ȡ$upgrade_home/version.txt��ȡ
     �汾��ʷ�� ����ͻ��˱Ƚϰ汾�� ȷ���ͻ����Ƿ���Ҫ����
     ���ȷ���ͻ�����Ҫ���£� ���Ϳͻ��˵�ǰ��Ҫ���µİ汾��
     {
       action  => 'upgrade_check',
       status  => 0,
       version => �°汾��  
     }

     �ͻ����յ�Ӧ���:
     $self->{new_version} = $res->{version};
     ͬʱ���� upgrade_list����  

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
         
