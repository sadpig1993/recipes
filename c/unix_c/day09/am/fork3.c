#include<stdio.h>
#include<unistd.h>
#include<sys/types.h>
main()
{	
	printf("This is parent process%d\n",getpid());
	pid_t p1,p2;
	int i;

	// ѭ��3�Σ�����3���ӽ���
	for(i=0;i<=2;i++)
	{
		if((p1=fork())==0)
		{
			printf("This is child%d:%d\n",i,getpid());
			return 0;//����ط��ǳ��ؼ�
		}
		//�����̵ȴ�p1����ִ�к�,���ܼ���fork�����ӽ���	
		wait(p1,NULL,0);		
	}

	printf("This is parent process%d\n",getpid());

}
