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
	ftruncate(fd,58);

	/* 3.���������ַ 	*/
	int age; 		// 4bytes
	float score;	// 4bytes
	char sex;		// 1bytes

	age = 20;
	score = 88.99f;
	sex='m';

	void *ptmp = p;
	memcpy(ptmp,"tom",3);
	ptmp += 20;
	memcpy(ptmp,&age,sizeof(int));
	ptmp += 4;
	
	memcpy(ptmp,&score,sizeof(float));
	ptmp += 4;

	memcpy(ptmp,&sex,sizeof(char));

	age = 30;
	score = 98.99f;
	sex='m';
	ptmp += 1;
	memcpy(ptmp,"jack",4);
	ptmp += 20;
	memcpy(ptmp,&age,sizeof(int));
	ptmp += 4;
	
	memcpy(ptmp,&score,sizeof(float));
	ptmp += 4;

	memcpy(ptmp,&sex,sizeof(char));

	/* 4.ж�������ַ	*/
	munmap(p,getpagesize());

	/* 5.�ر��ļ�		*/
	close(fd);	
	
}
