#include <stdio.h>
#include <poll.h>
#include <unistd.h>

main()
{
	struct pollfd fds[1]={};
	fds[0].fd=0;	//���ӱ�׼����
	fds[0].events=POLLIN ;

	poll(fds,1,-1);
	if(fds[0].revents & POLLIN )
	{
		char buf[20]={};
		read(0,buf,sizeof(buf)-1);
		printf("������!\n");			
		printf("::%s",buf);
	}
}
