#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>

main()
{
	int fd;
	off_t pos;

	/* 1.��һ���ļ� */
	fd = open("text.txt",O_RDWR);

	/* 2.�õ���ǰλ�� */
	pos = lseek(fd,0,SEEK_CUR);
	printf(" the cur location is %d\n",pos);

	/* 3.�ƶ�  λ�� */
	pos = lseek(fd,300,SEEK_SET);

	/* �õ�λ�� */
	printf(" the cur location is %d\n",pos);

	/* 5.�ر��ļ�,�鿴�ļ��Ĵ�С�Ƿ�ı� */
	close(fd);
}
