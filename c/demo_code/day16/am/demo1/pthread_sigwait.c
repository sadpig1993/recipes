/*
* 
*
*/
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <pthread.h>
#include <signal.h>

pthread_t ta,tb;

void *A(void *data)
{

	while(1)
	{
		//printf("�߳�---A!\n");
		sleep(2);
		
		/* ���Լ��߳����ڵĽ��̷����ź� */
		//raise(34);
		//kill(getpid(),34);

		/* ÿ��һ����B�̷߳����ź�	*/
		pthread_kill(tb,34); /*���߳�tb���ڵĽ��̷����ź�*/
	}
}

void *B(void *data)
{
	/* for sigwait */
	sigset_t sigs;
	sigemptyset(&sigs);
	sigaddset(&sigs,34);
	int s;

	while(1)
	{
		sigwait(&sigs,&s);
		printf("B---�߳�!\n");
		sleep(1);
	}
}

main()
{
	/* �����߳�		*/
	pthread_create(&ta,0,A,0);
	pthread_create(&tb,0,B,0);

	pthread_join(ta,0);
	pthread_join(tb,0);

}
