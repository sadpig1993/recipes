#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>

main()
{
	int fd;
	char str[25];
	off_t pos;
	/* ʵ�ʶ�ȡ�ĸ��� */
	int rlen;

	/* 1.��һ���ı��ļ� */
	fd = open("text.c",O_RDONLY);

	/* 2.ʹ��read��ȡ�����ַ�������ӡ��ǰ��λ�� */
	pos = lseek(fd,0,SEEK_CUR);
	printf(" the cur location is %d\n",pos);
	/* �ڵ�ǰλ�� ��ȡ5���ַ� */
	read(fd,str,5);
	/* �ٴδ�ӡ��ǰ���ļ�λ�� */
	pos = lseek(fd,0,SEEK_CUR);
	printf(" the cur location is %d\n",pos);

	/* 3.ʹ��pread��ȡ�����ַ�������ӡ��ǰ��λ�� */
	pos = lseek(fd,0,SEEK_CUR);
	printf(" the cur location is %d\n",pos);
	/* ���ļ�λ��Ϊ10��ʱ�� ��ȡ5���ַ� */
	pread(fd,str,5,10);
	/* �ٴδ�ӡ��ǰ���ļ�λ�� */
	pos = lseek(fd,0,SEEK_CUR);
	printf(" the cur location is %d\n",pos);

	/* 4.�ر��ļ� */
	close(fd);
}
