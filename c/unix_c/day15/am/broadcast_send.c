#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

/*
1.扢离嫘畦恁砐
2.砃嫘畦華硊嫘畦
*/

main()
{
	int fd=socket(AF_INET,SOCK_DGRAM,0);

	/* 扢离嫘畦恁砐	*/
	int b=1;
	int r=setsockopt(fd,SOL_SOCKET,SO_BROADCAST,&b,sizeof(b));

	/* 砃嫘畦華硊嫘畦	*/
	struct sockaddr_in addr={};
	addr.sin_family=AF_INET;
	addr.sin_port=htons(8888);
	addr.sin_addr.s_addr=inet_addr("192.168.1.255"); /* 嫘畦華硊 */
	
	int i;
	for(i=0;i<100;i++)
	{
		sleep(1);
		sendto(fd,"hello",5,0,(struct sockaddr *)&addr,sizeof(addr));
	}
		
	close(fd);
}
