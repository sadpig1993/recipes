#include <stdio.h>
#include <unistd.h>

/* �ļ�����ͷ�ļ� */
#include <fcntl.h> 
#include <stdlib.h>
#include <string.h>

main()
{
	
	int fd;
	char *filename="a.dat";
	char name[20];
	int age;
	float score;
	char sex;
	
	/* 1.�����ļ� */
	fd = open(filename,O_RDWR|O_CREAT,0666);
	if(fd == -1)
	{
			/*
		printf("open error:%m\n",);
			*/
			perror("open error");
			exit(-1);
	}
	
	/* 2.д��¼  */
	//bzero(name,sizeof(name));
	memset(name,0x00,sizeof(name));
	memcpy(name,"tom",3);
	age = 20;
	score = 89.99f;
	sex = 'm';
	write(fd,name,sizeof(name));
	write(fd,&age,sizeof(age));
	write(fd,&score,sizeof(score));
	write(fd,&sex,sizeof(sex));

	bzero(name,sizeof(name));
	memcpy(name,"jack",4);
	age = 18;
	score = 99.88f;
	sex = 'f';
	write(fd,name,sizeof(name));
	write(fd,&age,sizeof(age));
	write(fd,&score,sizeof(score));
	write(fd,&sex,sizeof(sex));


	/* 3. �ر��ļ�  */
	close(fd);	
}
