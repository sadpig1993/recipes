#include<stdio.h>
#include<unistd.h>
#include<sys/types.h>
main()
{	
	printf("This is parent:%d\n",getpid());

	int i;
	pid_t pid[3];

	//ѭ�����Σ�����3���ӽ���
	for(i=0;i<3;i++)
	{
		if((pid[i]=fork()) == 0)
		{
				break;
		}
		else
			printf("child%d:%d\n",i,pid[i]);
	}
}
