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
	fd = open("book.dat",O_RDONLY);	
	if(fd == -1)
	{
		/*
		perror("open error.");
		*/
		printf("errno is %d\terrmsg is %s\n",errno,strerror(errno));
		exit(-1);
	}
	/* 2.ӳ���ļ��������ڴ�		*/
	/* �˴�ӳ����ڴ��Ȩ��Ӧ��open���ļ���Ȩ��һ�� ��ͬλ��	*/
	/* ��������дȨ�ޣ�����ϵͳ�ᱨ�δ���	*/
	p = mmap(0,getpagesize(),
			PROT_READ,
			MAP_SHARED,fd,0);//������������page�ı���
	if(p == (void *)0)
	{
		printf("errno is %d\terrmsg is %s\n",errno,strerror(errno));
		exit(-1);
	}
	/* ��ӡӳ���ڴ�ĵ�ַ */
	printf("0x%p\n",p);

	/* 3.���������ַ 	*/
	int age=0; 			// 4bytes
	float score=0;		// 4bytes
	char sex;			// 1bytes
	char name[20]={0};  // 20bytes

	void *ptmp = p;
	memcpy(name,ptmp,3);
	memcpy(&age,ptmp+20,sizeof(int));
	memcpy(&score,ptmp+24,sizeof(float));
	memcpy(&sex,ptmp+28,sizeof(char));
	printf("%s\t%d\t%.2f\t%c\n",name,age,score,sex);

	memcpy(name,ptmp+29,4);
	memcpy(&age,ptmp+49,sizeof(int));
	memcpy(&score,ptmp+53,sizeof(float));
	memcpy(&sex,ptmp+57,sizeof(char));
	printf("%s\t%d\t%.2f\t%c\n",name,age,score,sex);

	/* 4.ж�������ַ	*/
	munmap(p,getpagesize());

	/* 5.�ر��ļ�		*/
	close(fd);	
	
}
