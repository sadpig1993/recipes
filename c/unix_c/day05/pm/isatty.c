#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>

main()
{

	/* add */
	int fd;


	int r;
	r = isatty(1);

	/* add */
	fd = open("/dev/tty",O_RDWR);
	if(r == 1)
	{
		write(fd,"û�ö���,ֱ�����\n",strlen("û�ö���,ֱ�����\n"));
	}
	else
	{
		write(fd,"�Ѿ�����,������������ն�\n",strlen("�Ѿ�����,������������ն�\n"));
	}
}
