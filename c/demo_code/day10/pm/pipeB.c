#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <signal.h>

char pipefile[]="p.pipe"; //�ܵ��ļ���
int fd;	//�򿪹ܵ����ļ���������
int r ;

void closeproc(int s)
{
	/* 4.�رչܵ�	*/
	close(fd);
	exit(0);

}

main()
{

	signal(2,closeproc);

	/* 2.�򿪹ܵ��ļ�	*/
	fd = open(pipefile,O_RDWR);
	if(fd == -1)
	{
		printf("open:%m\n");
		unlink(pipefile);
		exit(-1);
	}

	/* 3.ÿ��һ���ӣ���ȡ һ������	*/
	while(1)
	{
		read(fd,&r,sizeof(int));
		printf("%d\n",r);
	}

}
