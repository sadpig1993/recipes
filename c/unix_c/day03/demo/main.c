#include <stdio.h>
#include <stdlib.h>
#include <dlfcn.h>

int main()
{
	/* ���庯��ָ��ָ��add���� function pointer */
	/* 
	 *	��������padd,padd���������int���
	 *	������int 
	*/
	int (*padd)(int,int);
	int (*pmlu)(int,int);
	/* ��������ָ�� */	
	void *h;

	/* 1. �򿪼��ع���� first open and load the .so */
	/* 
	 * ��dlopen�����������������
	 * �����������void *���
	*/
	h = dlopen("libku.so",RTLD_LAZY);
	if(!h)
	{
		printf("load error\n");
		exit(-1);
	}
	/* 2. ���Һ��� second look the function */
	/* 
	 * dlsym���������������add���
	 * ��add����������
	*/
	padd = dlsym(h,"add");
	if(!padd)
	{
		printf("look error\n");
		exit(-1);
	}
	pmlu = dlsym(h,"mul");
	if(!pmlu)
	{
		printf("look error\n");
		exit(-1);
	}

	/* ���ú��� call the function */
	/*
	 * ����������int add(int,int)
	*/
	int r = padd(45,55);
	printf("the result is [%d]\n",r);
	
	r = pmlu(100,100);	
	printf("the result is [%d]\n",r);
	/*  �رչ���� close the .so */
	dlclose(h);
	return 0;
}
