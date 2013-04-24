#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#define BUF_LEN 1024

// �������Ǵ��� ���ͻ�����
main()
{

	/* 	1.����socket		*/
		int fd=socket(AF_INET,SOCK_STREAM,0);
		if(fd==-1)
		{
			perror("socket");
			exit(-1);
		}
		printf("socket ok!\n");

	/*  2.�󶨵�ַ			*/
		struct sockaddr_in addr={};
		addr.sin_family=AF_INET;
		addr.sin_port=htons(9998);
		inet_aton("192.168.1.188",&addr.sin_addr);
		int r;
		r = bind(fd,(struct sockaddr *)&addr,sizeof(addr));
		if(r==-1)
		{
			perror("socket");
			close(fd);
			exit(-1);
		}
		printf("bind ok!\n");
	/* 3.����				*/
		r = listen(fd,10);	
		if(r==-1)
		{
			perror("socket");
			close(fd);
			exit(-1);
		}
		printf("listen ok!\n");	

	/* 4.����һ���ͻ�		*/
		int cfd;
		cfd=accept(fd,0,0);
		if(cfd==-1)
		{
			perror("socket");
			close(fd);
			exit(-1);
		}
		printf("��ʼ���մ����ļ�!\n");

	/* 5.ѭ�����տͻ����ݵ��ļ�		*/
		/* 5.1	�����ļ�������		*/
		  int len;	
		  r=recv(cfd,&len,sizeof(int),MSG_WAITALL);
		  printf("�ļ�������:%u\n",len);

		/* 5.2 �����ļ���		*/
			char buf[BUF_LEN];	//�������ݵĻ���
			bzero(buf,BUF_LEN);
			recv(cfd,buf,len,MSG_WAITALL);
			printf("���ݵ��ļ���:%s\n",buf);
			int filefd = open(buf,O_RDWR|O_CREAT,0666);
			//�쳣����˴�����

		/* 5.3 �����ļ�����		*/
			recv(cfd,&len,sizeof(int),MSG_WAITALL); 	
			printf("�ļ�������:%d\n",len);	

		/* 5.4 �����ļ�����		*/
			int count = len/BUF_LEN ;
			int remainder = len%BUF_LEN ;
			int i;
			for(i=0;i<count;i++)
			{
				recv(cfd,buf,BUF_LEN,MSG_WAITALL);
				//�ѽ��յ�������д���ļ�
				write(filefd,buf,BUF_LEN);
			}
			if(remainder>0)
			{
				recv(cfd,buf,remainder,MSG_WAITALL);
				write(filefd,buf,remainder);
			}
			close(filefd);
	/* 6.�رտͻ�			*/
			close(cfd);	
			
	/* 7.�ر�socket			*/
			close(fd);

}
