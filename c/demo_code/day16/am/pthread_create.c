#include <stdio.h>
#include <pthread.h>
#include <unistd.h>
#include <sched.h>

void *run(void *data)
{
	//while(1)
	//{
		printf("�����߳�!\n");
		printf("::%s\n",data);
		//sched_yield();	/* ����CPU */
		//sleep(1);
	//}
	return "world";
}

main()
{
	pthread_t tid;
	/* ���������ݸ��̺߳���
	int r=pthread_create(&tid,0,run,0);
	*/
	/* ��������"hello"���̺߳��� */
	int r=pthread_create(&tid,0,run,"hello");
	if(r)
	{
		printf("����ʧ��!\n");
	}
	//while(1)
	//{
		printf("�����ɹ�!\n");
		//sched_yield();	/* ����CPU */
		//sleep(1);
	//}

	/* �̺߳������ص����� */
	char *buf;
	pthread_join(tid,(void **)&buf);
	printf("%s\n",buf);
	
	/* �̺߳�������������	
	pthread_join(tid,(void **)0);
	*/
}
