/*
*	 ������ʵ�ֶ��̵߳Ŀ���
* 	���߳̽��о��ȵĵ���
* 	pthread_cond_signal �Ե����̷߳���
* 	pthread_cond_broadcast �Զ���̹߳㲥����
*/
#include <stdio.h>
#include <semaphore.h>
#include <pthread.h>
#include <unistd.h>

/* ����3���߳�tid	*/
pthread_t t1,t2,t3;

/* �̻߳�����	*/
pthread_mutex_t m;

/*	�߳�������		*/
pthread_cond_t c;

/* �߳�t1�Ĵ�����	*/
void *r1(void *d)
{
	while(1)	//�������߳�
	{
		//pthread_mutex_lock(&m);	// �������
		pthread_cond_wait(&c,&m);
		printf("�߳�---1!\n");
		sleep(10);
		//pthread_mutex_unlock(&m);	// �������
	}
}

/* �߳�t2�Ĵ�����	*/
void *r2(void *d)
{
	while(1)	//�������߳�
	{
		//pthread_mutex_lock(&m);	// �������
		pthread_cond_wait(&c,&m);
		printf("�߳�----2!\n");
		//pthread_mutex_unlock(&m);	// �������
	}
}

/* �߳�t3�Ĵ�����	*/
void *r3(void *d)
{
	while(1)	//�������߳�
	{
		//pthread_mutex_lock(&m);	// �������
		pthread_cond_wait(&c,&m);
		printf("�߳�-----3!\n");
		//pthread_mutex_unlock(&m);	// �������
	}

}

main()
{
	// ��ʼ�����������ȳ�ʼ��������ͷ�
	pthread_mutex_init(&m,0);

	// ��ʼ��������
	pthread_cond_init(&c,0);
	
	/* ����3���߳�	*/
	pthread_create(&t1,0,r1,0);
	pthread_create(&t2,0,r2,0);
	pthread_create(&t3,0,r3,0);

	while(1)
	{
		//����3�����߳�
		sleep(1);

		// ����������
		pthread_cond_signal(&c);
		//pthread_cond_broadcast(&c);

	}
	
	/* ���̵߳ȴ�3�����߳̽���	*/
	pthread_join(t1,(void **)0);
	pthread_join(t2,(void **)0);
	pthread_join(t3,(void **)0);

	// �ͷ�������
	pthread_cond_destroy(&c);

	// �ͷŻ�����
	pthread_mutex_destroy(&m);

}
