#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdlib.h>

main()
{

	int fd ;

	/* 1.���ļ� */
	fd = open("text.txt",O_RDWR);	

	/* 2.�ı��ļ���С */
	ftruncate(fd,20);

	/* 3.�ر��ļ� */
	close(fd);

}
