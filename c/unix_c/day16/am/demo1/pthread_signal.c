/*
* 
*
*/
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <pthread.h>
#include <signal.h>

void handler(int s)
{
	printf("���ź�!\n");
}
pthread_t ta,tb;

void *A(void *data)
{
	signal(34,handler);
	while(1)
	{
		printf("�߳�---A!\n");
		sleep(1);
		
		/* ���Լ��߳����ڵĽ��̷����ź� */
		//raise(34);
		//kill(getpid(),34);

		/* ÿ��һ����B�̷߳����ź�	*/
		pthread_kill(tb,34); /*���߳�tb���ڵĽ��̷����ź�*/
	}
}

void *B(void *data)
{
	//signal(34,handler);
	while(1)
	{
		printf("B---�߳�!\n");
		sleep(3);
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
