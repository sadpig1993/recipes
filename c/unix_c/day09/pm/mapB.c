#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>

main()
{
	int fd;
	int *p;
	/* 1.���ļ�	*/
	fd = open("map.dat",O_RDWR);
	if(fd == -1)
	{
		perror("open");
		exit(-1);
	}
	/* 2.ӳ�������ַ	*/
	//ӳ��ΪMAP_PRIVATE
	/*
	p == mmap(0,4,PROT_READ,
				MAP_PRIVATE,fd,0);
	*/

	//ӳ��ΪMAP_SHARED
	p == mmap(0,4,PROT_READ|PROT_WRITE,
				MAP_SHARED,fd,0);
	if(!p)
	{
		perror("map");
		close(fd);
		exit(-1);
	}
	/* 3.��ӡ�����ַ�е�����	*/
	while(1)
	{
		printf("%d\n",*p);
		sleep(1);
	}

	/* 4.ж������ĵ�ַ	*/
	munmap(p,4);

	/* 5.�ر��ļ�	*/
	close(fd);

}
