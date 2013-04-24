#include <stdio.h>
#include <stdlib.h>
#include <dlfcn.h>

int main()
{
	/* ׼������ ��������ָ�� */
	/* ���庯��ָ��ָ��add���� function pointer */
	int (*padd)(int,int);
	/* ��������ָ�� */	
	void *h;

	/* 1. �򿪼��ع���� first open and load the .so */
	h = dlopen("libku.so",RTLD_LAZY);
	if(!h)
	{
		printf("load error\n");
		exit(-1);
	}
	/* 2. ���Һ��� second look the function */
	padd = dlsym(h,"add");
	if(!padd)
	{
		printf("look error\n");
		exit(-1);
	}

	/* ���ú��� call the function */
	int r = padd(45,55);
	printf("::%d\n",r);
	
	/*  �رչ���� close the .so */
	dlclose(h);
	return 0;
}
