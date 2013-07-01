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
	/* 5.ɾ���ܵ�	*/
	unlink(pipefile);

	exit(0);

}

main()
{

	signal(2,closeproc);

	/* 1.�����ܵ��ļ�	*/
	r = mkfifo(pipefile,0666);
	if(r == -1)
	{
		printf("mkfifo:%m\n");
		exit(-1);
	}

	/* 2.�򿪹ܵ��ļ�	*/
	fd = open(pipefile,O_RDWR);
	if(fd == -1)
	{
		printf("open:%m\n");
		unlink(pipefile);
		exit(-1);
	}

	/* 3.ÿ��һ���ӣ�д��һ������	*/
	int  i=0;
	while(1)
	{
		write(fd,&i,sizeof(int));
		i++;
		read(fd,&r,sizeof(int));
		printf("::%d\n",r);
		sleep(1);
	}


}
