#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

main()
{

	int fd;
	int r;
	char buf[50];

	fd = open("fd.txt",O_RDWR);
	if(fd==-1) printf("open:%m\n"),exit(-1);

	/*  �Ӽ���д������ */
	r=read(0,buf,sizeof(buf)-1);
	buf[r]=0;

	/* ��buf�е����� ��fd.txt д��r������ */
	write(fd,buf,r);

	sleep(10);
	close(fd);
	
}
