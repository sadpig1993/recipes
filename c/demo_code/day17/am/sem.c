/*
*	�ź���(�źŵ�)�������߳�
* 	�ź������źŵ�)���̵߳Ŀ��Ƶ����ǲ����ȵ�
* 	��ռȨ�ߵ��߳����е�ʱ�䳤
* 	��ռȨ�͵��߳����е�ʱ���
*/
#include <stdio.h>
#include <unistd.h>
#include <pthread.h>
#include <semaphore.h>

pthread_t t1,t2;

/* �ź����Ķ���		*/
sem_t sem;

/* �߳�t1�Ĵ�����		*/
void *r1(void *d)
{
	while(1)	//�ȴ��ź���
	{
		sem_wait(&sem);
		printf("�߳�1----ִ��!\n");
	}
}

/* �߳�t2�Ĵ�����		*/
void *r2(void *d)
{
	while(1)	//�ȴ��ź���
	{
		sem_wait(&sem);
		printf("�߳�2----ִ��!\n");
	}
}

main()
{
	/* ��ʼ���ź�����0��ʾ���߳�ʹ�ã�10��ʾ�ź����ĳ�ʼֵ	*/
	sem_init(&sem,0,10);

	/* ����2���߳�	*/
	pthread_create(&t1,0,r1,0);
	pthread_create(&t2,0,r2,0);

	while(1)
	{
		/* �����ź���		*/
		sleep(1);
		sem_post(&sem);

	}
	sem_destroy(&sem);
}
