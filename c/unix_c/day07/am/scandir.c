#include <stdio.h>
#include <dirent.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>

int filter(const struct dirent *dir)
{
	/* ���������ļ� .��ͷ */

	if(memcmp(dir->d_name,".",1) == 0)
	{
		return 0;
	}
	else
	{
		return 1;
	}
}

int compare(const void *d1,const void *d2)
{
	/*
	return -alphasort(d1,d2);	
	*/
	/* ��.�ķ���ǰ�� */
	/*
	struct dirent *d = (struct dirent *)d1;
	if(memcmp(d->d_name,".",1) == 0)
	{
		return 0;
	}
	else
	{
		return 1;
	}
	*/
	/* �����ļ����ֵĳ��������� �ļ��������ŷ���ǰ��  */
	struct dirent **dd1=(struct dirent **)d1;
	struct dirent **dd2=(struct dirent **)d2;
	return (strlen((*dd2)->d_name) -  strlen((*dd1)->d_name));
}

main()
{
	struct dirent **dirs;
	
	int count;
	int i;
	/*
	count = scandir(".",&dirs,0,0);
	*/
	count = scandir(".",&dirs,0,compare);
	printf("Ŀ¼����:%d\n",count);

	for(i=0;i<count;i++)
	{
		printf("%s\n",dirs[i]->d_name);
	}
}
