#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <signal.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

main()
{
	/* 1.����socket 	*/
		int fd=socket(AF_INET,SOCK_DGRAM,0);
		if(fd == -1)
		{
			perror("sock"),exit(-1);
		}
		printf("����socket�ɹ�!\n");

	/* 2.���ӵ�Ŀ��socket		*/
		struct sockaddr_in addr={};	
		addr.sin_family=AF_INET;
		addr.sin_port=htons(8888);
		inet_aton("192.168.1.188",&addr.sin_addr);
		int r;

		/*
		r=connect(fd,(struct sockaddr *)&addr,sizeof(addr));
		if(r==-1)
		{
			perror("connectʧ��!\n");
			close(fd);
			exit(-1);
		}
		printf("���ӳɹ�!\n");
		*/

	/* 3.�������ݲ�����		*/

		while(1)
		{
			char buf[256]={};
		
			// �ӱ�׼��������
			r=read(0,buf,sizeof(buf)-1);
			if(r<=0)
			{
				printf("����ʧ��\n");
			}
			else
			{
				//������д��socket
				//write(fd,buf,r);
				sendto(fd,buf,r,0,
						(struct sockaddr *)&addr,sizeof(addr));

				//��socket��ȡ����
				r = read(fd,buf,sizeof(buf));
				buf[r]=0;
				printf("::%s\n",buf);
			}
		}

	/* 4.�ر�����		*/
		close(fd);	
}
