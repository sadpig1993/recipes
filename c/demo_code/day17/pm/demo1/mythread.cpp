#include "mythread.h"

void MyThread::start()
{
	pthread_create(&tid,0,s_run,this);
}

void MyThread::join()
{
	pthread_join(tid,(void **)0);
}

void MyThread::run()
{
	// ������ʵ���û��Լ���ҵ���߼�
	
}

void * MyThread::s_run(void *d)
{
	MyThread *th=(MyThread *)d;
	th->run();
}
