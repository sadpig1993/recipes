#include <stdio.h>
#include <stdlib.h>
#include <dlfcn.h>

/*
* 	ͨ������/lib/libdl.so�е�dlopen,dlsym,dlclose�����ж�̬��ĵ���
*/
int main()
{
	int m;
	void (*p)()=NULL;
	void *h;
	do
	{
		printf("������ѡ�\n");
		printf("1.��ӡ����\n");
		printf("2.��ӡ�˷���\n");
		printf("3.�˳�\n");
		scanf("%d",&m);
		printf("%d\n",m);
		if( m>3 || m<0)
		{
			printf("���벻�Ϸ�������������\n");
		}
	}while( m>4 || m <0);

	/* �򿪶�̬�� */	
	h = dlopen("libdlku.so",RTLD_LAZY);
	if(!h)
	{
	     printf("load error\n");
	     exit(-1);
	 }
	
	/* ��������ȷ�����ҵĺ����� */
	if( m ==1)
		p=dlsym(h,"print_rhombus");
	else if (m==2)
		p=dlsym(h,"print_cf");
	else if (m == 3)
		exit(0);
	
	if(!p)
	{
		printf("look error\n");
		exit(-1);
	}
	p();

	/*  �رչ���� close the .so */
	dlclose(h);

	return 0;
}
