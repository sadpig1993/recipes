#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/socket.h>
#include <signal.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#include <pthread.h>

/* 	ȫ�ֱ���		*/
int fd;

void *ptwrite(void *d)
{
	//д�߳�
	int r;
		char buf[256]={};
		while(1)
		{
			/* 4.1 ��������		*/
			//�ӱ�׼�����ȡ�ַ�
			read(0,buf,sizeof(buf)-1);
			if(r<=0){
				break;
			}
			/*	4.2��������		*/	
			write(fd,buf,r);
		}
}

void *ptread(void *d)
{
	//���߳�
	int r;
		char rcvbuf[256]={};
		while(1)
		{
			/*	5.1	��������	*/
			r =read(fd,rcvbuf,sizeof(rcvbuf)-1);
			if(r<=0){
				printf("��������Ͽ�����!\n");
				close(fd);
				exit(-1);	//�˳����߳�
			}
			printf(":%s\n",rcvbuf);
		}
	
	
}


main()
{
	/*	1.����socket	*/
	int fd=socket(AF_INET,SOCK_STREAM,0);
	if(fd == -1){
		perror("socket"),exit(-1);
	}
	printf("socket�����ɹ�!\n");

	/*	2.���ӷ�����	*/
	struct sockaddr_in addr={};
	addr.sin_family=AF_INET;
	addr.sin_port=htons(9999);
	//inet_aton("192.168.1.188",&addr.sin_addr);
	addr.sin_addr.s_addr=inet_addr("192.168.1.188");
	int r;
	r=connect(fd,(struct sockaddr *)&addr,sizeof(addr));
	if(r == -1){
		perror("connect"),close(fd),exit(-1);
	}
	printf("���ӷ������ɹ�,��������!\n");

	/*	3.���������̣߳�һ�����̣߳�һ��д�߳�	*/
	pthread_t twid,trid;
	
	pthread_create(&twid,0,ptwrite,0);
	pthread_create(&trid,0,ptread,0);
	
	pthread_join(twid,(void **)0);
	pthread_join(trid,(void **)0);

}
