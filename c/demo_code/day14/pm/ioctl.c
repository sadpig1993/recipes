/*
1.��ȡ���нӿ�
2.��ȡĳ���ӿڵĵ�ַ���㲥��ַ,MTU
*/

#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/ioctl.h>
#include <net/if.h>
#include <netinet/in.h>
#include <arpa/inet.h>

main()
{
	struct ifreq reqs[5]; /* ��ŷ��صĽӿ�	*/
	struct ifconf conf;

	conf.ifc_len=sizeof(reqs);
/*	conf.ifc_ifcu.ifcu_req=reqs;�������еȼ�	*/
	conf.ifc_req=reqs;	

	int fd = socket(AF_INET,SOCK_STREAM,0);
	int r=ioctl(fd,SIOCGIFCONF,&conf);
	if(!r){
		printf("��ȡ�ɹ�!\n");
	}

	int len=conf.ifc_len/sizeof(struct ifreq);
	printf("�ӿڸ���:%d\n",len);
	int i;
	for(i=0;i<len;i++)
	{
		printf("�ӿ�%d:%s\n",i+1,reqs[i].ifr_name);
	}

/* ��ȡeth0��IP��ַ��㲥��ַ	*/
	struct ifreq req;
	/* ������ǽӿ����֣�����ӿڵĸ��ֲ���	*/
	memcpy(req.ifr_name,"eth0",5);
	ioctl(fd,SIOCGIFADDR,&req);
	
	struct sockaddr_in *addr=
	(struct sockaddr_in*)&req.ifr_addr ;
	
	printf("��ַ:%s\n",inet_ntoa(addr->sin_addr));

	close(fd);
}
