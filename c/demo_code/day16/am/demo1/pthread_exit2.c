/*
* A�߳���30�����ֹB�߳�
*
*/
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <pthread.h>

pthread_t ta,tb;
void *A(void *data)
{
	int i=0;
	while(1)
	{
		printf("�߳�---A!\n");
		sleep(1);
		i++;
		if(i==30)
		{
			pthread_cancel(tb);
		}

	}
}

void *B(void *data)
{
	while(1)
	{
		printf("B---�߳�!\n");
		sleep(1);
		pthread_testcancel();
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
