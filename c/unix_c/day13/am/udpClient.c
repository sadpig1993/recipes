#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

//	ʹ�úܴ󻺳巢������

main()
{

	/* 1.����socket����		*/
		int fd=socket(AF_INET,SOCK_DGRAM,0);
		if(fd == -1)
		{
			perror("socket"),exit(-1);
		 }
		printf("scoket OK!\n");

	/* 2.���ӷ�����		*/
		struct sockaddr_in addr={};
		addr.sin_family=AF_INET;
		addr.sin_port=htons(9999);
		//addr.sin_addr.s_addr==inet_addr("192.168.1.188");
		inet_aton("192.168.1.188",&addr.sin_addr);	

		int r;
		r = connect(fd,(struct sockaddr *)&addr,sizeof(addr));
		if(r == -1)
		{
			perror("connect"),close(fd),exit(-1);
		}
	/* 3.ѭ������10������		*/
		int i;
		for(i=0;i<10;i++)
		{
			write(fd,"Hello",5);
		}
		
	/* 4.�ر�socket			*/
		close(fd);	

}
