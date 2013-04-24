#ifndef MY_THREAD_H
#define MY_THREAD_H

#include <pthread.h>

class MyThread
{
	private:
		pthread_t tid;
		static void *s_run(void *d);	//�߳�ִ�еĴ���
	public:
		void start();	//�����߳�
		void join();	// �ȴ��߳̽���	
	public:
		virtual	void run();	//�麯�� �߳�ִ��
};

#endif
