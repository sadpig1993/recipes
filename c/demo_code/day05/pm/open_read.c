#include <stdio.h>
#include <unistd.h>

/* �ļ�����ͷ�ļ� */
#include <fcntl.h> 
#include <stdlib.h>
#include <string.h>

main()
{
	
	int fd;
	char name[20];
	int age;
	float score;
	char sex;
	char *filename="a.dat";
	
	/* 1.���ļ� */
	fd = open(filename,O_RDWR);
	if(fd == -1)
	{
			/*
		printf("open error:%m\n",);
			*/
			perror("open error");
			exit(-1);
	}
	
	/* 2.ѭ����ȡ���� */

	int r;
	while(1)
	{
		r = read(fd,name,sizeof(name));
		if(r<=0)
				break;
		r = read(fd,&age,sizeof(int));
		r = read(fd,&score,sizeof(float));
		r = read(fd,&sex,sizeof(char));

		printf("%s,%d,%5.2f,%c\n",name,age,score,sex);
	}
	/* 3. �ر��ļ�  */
	close(fd);	
}
