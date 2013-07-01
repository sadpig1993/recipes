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

	/*	1.����socket	*/
		int fd=socket(AF_INET,SOCK_DGRAM,0);
		if(fd == -1)
		{
			perror("socket failure"),exit(-1);
		}
		printf("����socket�ɹ�!\n");

	/*	2.�󶨵�ַ		*/
		struct sockaddr_in addr={};
		addr.sin_family=AF_INET;
		//	��Ӧ�Ķ˿�
		addr.sin_port=htons(8888);

		// ��IP��ַ����ת�����Ҵ�ŵ��ṹ���Ӧ�ı�����
		inet_aton("192.168.1.188",&(addr.sin_addr));

		// ��
		int r = bind(fd,(struct sockaddr *)&addr,sizeof(addr));
		if(r==-1)
		{
			perror("bind failure\n"),close(fd),exit(-1);	
		}
		printf("��ַ�󶨳ɹ�!\n");
		
	/*	3.ѭ�����տͻ����ݣ�������һ����Ϣ		*/
		char buf[256]={};
		struct sockaddr_in caddr={};
		socklen_t len=sizeof(caddr);
		while(1)
		{
			// ��ȡ���� ���ж��Ƿ�����������	
			//r = read(fd,buf,sizeof(buf)-1);

			r=recvfrom(fd,buf,sizeof(buf)-1,0,(struct sockaddr *)&caddr,&len);
			if( r<= 0)
			{
				break;
			}
			buf[r]=0;
			printf("����%s:%u������::%s\n",
					inet_ntoa(caddr.sin_addr)		
					,ntohs(caddr.sin_port)
					,buf);

			//��������
			sendto(fd,"Cow Boy",strlen("Cow Boy"),0,
					(struct sockaddr *)&caddr,sizeof(caddr));
		}
		
	/*  4.ͨ���źŹر�socket����		*/
		close(fd);	

}
