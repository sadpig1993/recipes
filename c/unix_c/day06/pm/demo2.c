#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/stat.h>

main()
{

	int fd;

	struct stat st;
	int i;

	/* ��¼��	*/
	char logname[32];
	/* ��¼����	*/
	int count;

	/* 1.���ļ�	*/
	fd = open("wtmpx",O_RDWR);
	if(fd == -1)
	{
			perror("open error");
			exit(-1);
	}

	/* 2.��ȡ��¼����	*/
	/* �ļ����ȴ�С/ÿ����¼��ռ�õĿռ��С	*/
	fstat(fd,&st);
	count = st.st_size/372 ;

	/* 3.ѭ����ȡ��¼, ����ӡ����	*/
	for(i=0;i<count;i++)
	{
		lseek(fd, i*372 ,SEEK_SET);
		read(fd,logname,32);	
		printf("logname is %s\n",logname);
	}

	/* 4.�ر��ļ�	*/
	close(fd);
}
