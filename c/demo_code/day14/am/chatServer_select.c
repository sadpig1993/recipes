#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/select.h>
#include <sys/socket.h>
#include <string.h>
#include <netinet/in.h>
#include <arpa/inet.h>

main()
{
	int serverfd;	//������socket������
	int r;		//��ź�������ֵ

	int allfds[100];	//����������ӵĿͻ���������
	int idx;		//���ӵ������

	int maxfd;	//�����������
	fd_set fds;		//���ӵ������������������ݵ�����������
	char  buf[1024];	//��ȡ�ͻ����ݵ�������Ϣ


	/*	1.����socket								*/
	serverfd=socket(AF_INET,SOCK_STREAM,0);
	if(serverfd==-1)
	{
		perror("socket"),exit(-1);
	}
	printf("socket ok!\n");

	/*	2.�󶨵�ַ									*/
	struct sockaddr_in addr={};
	addr.sin_family=AF_INET;
	addr.sin_port=htons(9999);
	addr.sin_addr.s_addr=inet_addr("192.168.1.188");
	r=bind(serverfd,(struct sockaddr *)&addr,sizeof(addr));
	if(r==-1)
	{
		perror("bind"),close(serverfd),exit(-1);
	}
	printf("bind ok!\n");

	/*	3.����										*/
	r=listen(serverfd,10);
	if(r==-1)
	{
		perror("listen"),close(serverfd),exit(-1);
	}
	printf("listen ok!\n");


	int i;
	//�����
	for(i=0;i<100;i++)
	{
			allfds[i]=-1;
	}
	idx=0;
	/*	4.ѭ������select�������������ŵĸı�		*/
	while(1)
	{
		/*	4.1 ��ʼ����Ҫ���ӵ�����*/
		maxfd=-1;	//��ʼ��	
		FD_ZERO(&fds);	//���fds
			/*����serverfd�����ӵ�����������*/
		FD_SET(serverfd,&fds);
		maxfd=serverfd>maxfd?serverfd:maxfd;
			/*�������������������Ӽ���*/
		for(i=0;i<100;i++)
		{
			if(allfds[i]!=-1)
			{
				FD_SET(allfds[i],&fds);
				maxfd=allfds[i]>maxfd?allfds[i]:maxfd;
			}
		}
		/*	4.2 ����				*/
		r=select(maxfd+1,&fds,0,0,0);	
		if(r==-1)
		{
			break;//�ж�����ѭ��
		}
		printf("�ı���:%d\n",r);

	/*	5.�ж�serverfd�Ƿ�������*/
		/*	5.1���serverfd�ڣ��ͽ��������ӵĿͻ� */
		if(FD_ISSET(serverfd,&fds))
		{
			allfds[idx]=accept(serverfd,0,0);	
			idx ++;
		}

	/* 	6.�ж���Щ�����������ڷ��صĸı�ļ�����	*/
		for(i=0;i<100;i++)
		{
			if( (allfds[i]!=-1) && (FD_ISSET(allfds[i],&fds)) )
			{
				/*	6.1 ����ڣ����ȡ����	*/
				bzero(buf,sizeof(buf));
				r=read(allfds[i],buf,sizeof(buf)-1);
				if(r==-1){
					printf("���˹����˳�!\n");
					close(allfds[i]);
					allfds[i]=-1;
				}
				if(r==0){
					printf("���˹ر��˳�!\n");
					close(allfds[i]);
					allfds[i]=-1;
				}
				if(r>0){
				/*	6.2 �㲥����			*/
					buf[r]=0;
					printf("���Կͻ�����Ϣ:%s\n",buf);
					int j;
					for(j=0;j<100;j++)
					{
						if(allfds[j]!=-1)
						{
							write(allfds[j],buf,r);	
						}
					}
				}

			}
		}
	}
	close(serverfd);

}
