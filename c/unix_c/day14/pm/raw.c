/*
*�˳�����Ҫroot����ִ��
*/
#include <stdio.h>
#include <sys/socket.h>
#include <linux/if_ether.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>

main()
{
	//vi /etc/protocols �鿴rawԭ����֧�ֵ�Э��
	int fd=socket(AF_INET,SOCK_RAW,6);		
	//int fd=socket(AF_INET,SOCK_RAW,17);		
	if(fd==-1){
		perror("socket"),exit(-1);
	}
	int r;
	char buf[1024];
	while(1)
	{
	 r=read(fd,buf,sizeof(buf)-1);	
	 buf[r]=0;  
	 printf(":%s\n",buf);	
	}
	close(fd);
}
