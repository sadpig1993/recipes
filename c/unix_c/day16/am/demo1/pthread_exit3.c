/*
* A�߳���30���,�˳���B�̼߳���ִ��
* �˳�����A�߳��˳�����Ϊ�߳�Aû�н����������߳�Bû��ִ��
*/
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <pthread.h>

pthread_t ta,tb;
pthread_mutex_t m;

void *A(void *data)
{
	int i=0;
	while(1)
	{
		pthread_mutex_lock(&m);
		printf("�߳�---A!\n");
		i++;
		if(i==30)
		{
			pthread_exit("byebye");
		}
		pthread_mutex_unlock(&m);
		sleep(1);
	}
}

void *B(void *data)
{
	while(1)
	{
		pthread_mutex_lock(&m);
		printf("B---�߳�!\n");
		sleep(1);
		pthread_mutex_unlock(&m);
	}
}

main()
{
	/* �̻߳�����  */
	pthread_mutex_init(&m,0);

	/* �����߳�		*/
	pthread_create(&ta,0,A,0);
	pthread_create(&tb,0,B,0);

	pthread_join(ta,0);
	pthread_join(tb,0);

	pthread_mutex_destroy(&m);

}
