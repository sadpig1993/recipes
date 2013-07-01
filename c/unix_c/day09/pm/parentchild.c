#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>

/* ��ʬ���̻��պ��� */
void handle(int s)
{
	int status;
	wait(&status);
	printf("%d\n",WEXITSTATUS(status));
}

main()
{
	/* ��ָ���źŵĴ����� */
	signal(SIGCHLD,handle);

	if(fork())
	{
		//������
		while(1)
		{
			printf("������!\n");
			sleep(1);
		}
	}
	else
	{
		//�ӽ���
		while(1)
		{
			printf("�ӽ���!%d\n",getpid());
			sleep(10);
			return 99;
		}
	}

}
