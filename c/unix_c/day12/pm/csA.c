#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/socket.h>
#include <linux/un.h>
#include <netinet/in.h>
#include <arpa/inet.h>

main()
{

	/* 1.����socket	:socket		*/
		//	int fd=socket(AF_FILE,SOCK_STREAM,0);	//�Ա����ļ���ʽ��socket
		int fd=socket(AF_INET,SOCK_STREAM,0);	//��������ʽ��socket
		if(fd==-1)
		{
			perror("socket"),exit(-1);
		}
		printf("����socket�ɹ�!\n");

	/* 2.�󶨵�ַ	:bind		*/
		int r;

		// �Ա����ļ���ʽ
		/* �����ļ���ʽ
		struct sockaddr_un addr={};
		addr.sun_family=AF_FILE;
		sprintf(addr.sun_path,"%s","s.socket");
		*/

		//��������ʽ��socket
		struct sockaddr_in addr={};
		addr.sin_family=AF_INET;
		addr.sin_port=htons(11111);
		inet_aton("192.168.1.188",&addr.sin_addr);

		r = bind(fd,(struct sockaddr *)&addr,sizeof(addr));
		if(r==-1)
		{
			perror("bind"),close(fd),exit(-1);
		}
		printf("��socket�ɹ�!\n");

	/* 3.��������	:listen		*/
		r=listen(fd,10);
		if(r==-1)
		{
			perror("listen"),close(fd),exit(-1);
		}
		printf("���������ɹ�!\n");

		while(1)
		{
	/* 4.���ؼ������Ŀͻ�����	:accept		*/
			int cfd;//������������
			cfd=accept(fd,0,0);
			if(cfd==-1)
			{
				break;
			}
			printf("�пͻ���������:%d\n",cfd);
	/* 5.ͨ�����ص�����,ֻ��ÿͻ���������	:read/write	ϵ�к���	*/
			write(cfd,"Hello",5);	
	/* 6.�رտͻ�����	:close		*/
			close(cfd);
		}

	/* 7.�ر�socket		:close		*/
		close(fd);

}
