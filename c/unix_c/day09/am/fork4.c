#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>

/* 
* 
*
*/
main()
{	
	printf("parent process:%d begin\n",getpid());
	pid_t p1,p2;
	int i;
	int status;

	//	ѭ��3��һ������7���ӽ��̣�����ֻ��3���ӽ���
	//	�Ǹ����̲����ģ�ʣ�µĶ����ӽ���fork������
	for(i=0;i<=2;i++)
	{
		p1 = fork();
		if( p1==0 )
		{
			printf("child%d pid:%d\n",i,getpid());
	//		exit(0);
		}
		else if(p1 > 0)
		{
			printf("parent pid:%d\tppid:%d\n",getpid(),getppid());
		}
		p2 = wait(p1,&status,0);		
	}
	printf("parent process%d end\n",getpid());
}
