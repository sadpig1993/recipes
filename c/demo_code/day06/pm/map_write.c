#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <errno.h>

main()
{
	
	int fd;
	void *p;

	/* 1.����һ���ļ�	 */	
	fd = open("book.dat",O_RDWR|O_CREAT,0666);	
	if(fd == -1)
	{
		/*
		perror("open error.");
		*/
		printf("errno is %d\terrmsg is %s\n",errno,strerror(errno));
		exit(-1);
	}
	/* 2.ӳ���ļ��������ڴ�		*/
	/* �˴�ӳ����ڴ��Ȩ��Ӧ��open���ļ���Ȩ��һ�� ��ͬλ��д 		*/
	p = mmap(0,getpagesize(),
			PROT_READ|PROT_WRITE,
			MAP_SHARED,fd,0);//������������page�ı���
	if(p == (void *)0)
	{
		printf("errno is %d\terrmsg is %s\n",errno,strerror(errno));
		exit(-1);
	}
	/* ��ӡӳ���ڴ�ĵ�ַ */
	printf("0x%p\n",p);

	/* ���ļ�ָ��һ����С,���ļ���С��Ϊ0��  ����ᱨbus error���ߴ��� */
	ftruncate(fd,20);

	/* 3.���������ַ 	*/
	// *((int *)p) = 20;
	memcpy(p,"Hello World,Hello World,Hello World",36);

	/* 4.ж�������ַ	*/
	munmap(p,getpagesize());

	/* 5.�ر��ļ�		*/
	close(fd);	
	
}
