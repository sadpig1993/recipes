#include <stdio.h>
#include <sys/socket.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>
#include <linux/un.h>

main()
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

	/* ����socket ��fd	*/
	int r;
	r=connect(fd,(struct sockaddr*)&addr,sizeof(addr));
	if(r==-1)
	{
		perror("connect"),close(fd),exit(-1);
	}

	int i=0;
	for(;i<10;i++)
		write(fd,"hello",5);
	close(fd);
}
