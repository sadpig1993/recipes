#include <stdio.h>
#include <fcntl.h>
#include <signal.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <asm/sockios.h>

void handle(int s)
{
	char buf[20]={};

	read(0,buf,sizeof(buf)-1);
	printf("::%s",buf);
}

main()
{

	//���ź� SIGIO������
	signal(SIGIO,handle);

	/*
	int r=fcntl(0,F_SETFL,O_ASYNC);
	fcntl(0,F_SETOWN,getpid());
	*/

	int b=1;
	pid_t pid=getpid();
	ioctl(0,FIOASYNC,&b);
	fcntl(0,F_SETOWN,getpid());
	//ioctl(0,FIOSETOWN,&pid);

	printf("�޸��첽�ɹ�!\n");
	
	while(1);
	
}
