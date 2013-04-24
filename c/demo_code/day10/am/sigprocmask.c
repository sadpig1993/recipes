/*  ���� 1 - 10000 ֮��ĺ�	*/
/* ����ctrl+c������SIGINT�ź�	*/

#include <signal.h>
#include <stdio.h>
#include <unistd.h>


main()
{
	int sum = 0;
	int i;
	
	sigset_t masksigs;
	sigemptyset(&masksigs);

	/* 1.����һ���źż���	*/
	sigset_t sigs;

	/* 2.��� ���� �ź�	*/
	sigemptyset(&sigs);
	sigaddset(&sigs,SIGINT);
	//	�������е��ź�
	//	sigfillset(&sigs);

	/* 3.�����źż��ϱ�����		*/
	sigprocmask(SIG_BLOCK,&sigs,0);

	/***********************************/
	for(i=0;i<10001;i++)
	{
		sum += i;
		usleep(10);

		sigpending(&masksigs);
		if(sigismember(&masksigs,2))
		{
			printf("����ctrl+c,��Ҫ��!\n");
		}
	}

	printf("sum is %d\n",sum);
	printf("�������!\n");

	/*  ����ź�����	*/
	sigprocmask(SIG_UNBLOCK,&sigs,0);

	/**********************************/

	printf("��������!\n");
}
