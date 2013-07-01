#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>
#include <sys/mman.h>

main()
{

	int fd;
	int *p;
	/*	1. ����һ���ļ� */
	fd = open("map.dat",O_RDWR|O_CREAT,0666);
	if(fd == -1)
	{
		perror("open");
		exit(-1);
	}	

	/*	2. ���ļ���С����Ϊ4�ֽ� */
	ftruncate(fd,4);

	/*	3. ӳ���ļ��������ڴ�	*/
	//ӳ��ΪMAP_PRIVATE
	/*
	p=mmap(0,4,PROT_READ|PROT_WRITE,
			MAP_PRIVATE,fd,0); 
	*/

	
	//ӳ��ΪMAP_SHARED
	p=mmap(0,4,PROT_READ|PROT_WRITE,
			MAP_SHARED,fd,0); 
	if(!p)
	{
		perror("mmap");
		close(fd);
		exit(-1);
	}

	/*	4. ����һ�����ݵ��ڴ�	*/
	int i=0;
	while(1)
	{
		*p = i;
		i++;
		sleep(1);
	}

	/* 	5.ж��ӳ��	*/
	munmap(p,4);

	/*	6. �ر��ļ�	*/
	close(fd);

}
