#include <stdio.h>
#include <sys/socket.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>
#include <linux/un.h>

main
(
)

{
	/* ����socket	*/
	int fd;
	fd = socket(AF_LOCAL,SOCK_DGRAM,0);
	if( fd == -1)
	{
		perror("socket"),exit(-1);
	}
	printf("socket�����ɹ�!\n");

	struct sockaddr_un	addr={};
	addr.sun_family=AF_LOCAL;
	sprintf(addr.sun_path,"./my.socket");

	/* ��socket	*/
	int r;
	r=bind(fd,(struct sockaddr*)&addr,sizeof(addr));
	if(r==-1)
	{
		perror("bind"),close(fd),exit(-1);
	}
	printf("�󶨳ɹ�!�ȴ���������....\n");

	/* ��������	*/
	char buf[100];
	while(1)
	{
		r = read(fd,buf,99);
		if(r<=0)
			break;
		buf[r]=0;
		printf("::%s\n",buf);

	}
	close(fd);
}
