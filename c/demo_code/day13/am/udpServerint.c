#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

//	ʹ�úܴ󻺳���տͻ�����
//	ÿ��ֻ����һ���ͻ�

main()
{

	/* 1.����socket����		*/
		int fd=socket(PF_INET,SOCK_DGRAM,0);
		if(fd == -1)
		{
			perror("socket"),exit(-1);
		 }
		printf("scoket OK!\n");

	/* 2.�󶨵�ַ			*/
		struct sockaddr_in addr={};
		addr.sin_family=PF_INET;
		addr.sin_port=htons(9999);
		//addr.sin_addr.s_addr==inet_addr("192.168.1.188");
		inet_aton("192.168.1.188",&addr.sin_addr);	

		int r;
		r = bind(fd,(struct sockaddr *)&addr,sizeof(addr));
		if(r == -1)
		{
			perror("bind"),close(fd),exit(-1);
		 }
		printf("bind OK!\n");


	/* 5.���տͻ����� 		*/
		int a;
		while(1)
		{
			//r = read(fd,&a,sizeof(int)); ע��������һ�е�����
			// ��ȡ�������ȵ����� recv����������ʹ��MSG_WAITALL
			r = recv(fd,&a,sizeof(int),MSG_WAITALL);
			if(r==0)
			{
				printf("�ͻ��˳�!\n");
				break;
			}
			if(r>0)
			{
				//buf[r]=0;
				printf("::%d\n",a);
			}
			if(r==-1)
			{
				printf("�������!\n");
				break;
			}
		}
	/* 7.�ر�socket			*/
		close(fd);	

}
