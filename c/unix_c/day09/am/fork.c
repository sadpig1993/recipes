#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/mman.h>

main()
{
	int a=30;
	int *ip=malloc(4);
	*ip=10;

	int *c=sbrk(4);
	*c=8;

	/*ӳ��Ŀռ�ΪMAP_PRIVATE˽��ӳ��,˽��ӳ��Ŀռ䣬���ӽ��̻���Ӱ��
	int *d=mmap(0,4,PROT_READ|PROT_WRITE,
					MAP_ANONYMOUS|MAP_PRIVATE,0,0);
	*/

	/* ӳ��Ŀռ�MAP_SHARED����ӳ��,����ӳ��Ŀռ䣬���ӽ����໥Ӱ�� */
	int *d=mmap(0,4,PROT_READ|PROT_WRITE,
					MAP_ANONYMOUS|MAP_SHARED,0,0);
	printf("%m\n");
	
	*d=7;

	printf("������!\n");

	pid_t pid=fork();

	//printf("�����ӽ���:%d\n",pid);
	if(pid > 0)
	{
		while(1)
		{
			printf("�����̣�%d\n",pid);
			a = 999;
			*ip = 999;
			*c = 999;
			*d = 7777;
			sleep(10);
		}
	}
	if(pid == 0)
	{
		while(1)
		{
			printf("�ӽ��̣�%d\n",pid);
			printf("a:%d\n",a);
			printf("*ip:%d\n",*ip);
			printf("*c:%d\n",*c);
			printf("*d:%d\n",*d);
			sleep(2);
		}
	}
	if(pid ==-1)
	{	
		perror("fork");
		exit(-1);
	}

}
