#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <pthread.h>
#include <signal.h>


main()
{
	if(fork())
	{
		//������
		sigset_t sigs;
		sigemptyset(&sigs);
		/* ��34�źŷŽ��źż���		*/
		sigaddset(&sigs,34);
		int s;
	
		while(1)
		{
			sigwait(&sigs,&s);
			printf("�������!\n");
		}

	}
	else
	{
		//�ӽ���
		while(1)
		{
			sleep(1);
			kill(getppid(),34);
			printf("�Ѿ������ź�!\n");
		}

	}


}
