/*
*	 条件量实现多线程的控制
* 	对线程进行均匀的调度
* 	pthread_cond_signal 对单个线程发送
* 	pthread_cond_broadcast 对多个线程广播发送
*/
#include <stdio.h>
#include <semaphore.h>
#include <pthread.h>
#include <unistd.h>

/* 定义3个线程tid	*/
pthread_t t1,t2,t3;

/* 线程互斥量	*/
pthread_mutex_t m;

/*	线程条件量		*/
pthread_cond_t c;

/* 线程t1的处理函数	*/
void *r1(void *d)
{
	while(1)	//被控制线程
	{
		pthread_cond_wait(&c,&m);
		printf("线程---1!\n");
	}
}

/* 线程t2的处理函数	*/
void *r2(void *d)
{
	while(1)	//被控制线程
	{
		pthread_cond_wait(&c,&m);
		printf("线程----2!\n");
	}
}

/* 线程t3的处理函数	*/
void *r3(void *d)
{
	while(1)	//被控制线程
	{
		pthread_cond_wait(&c,&m);
		printf("线程-----3!\n");
	}

}

main()
{
	// 初始化互斥量，先初始化的最后释放
	pthread_mutex_init(&m,0);

	// 初始化条件量
	pthread_cond_init(&c,0);
	
	/* 创建3个线程	*/
	pthread_create(&t1,0,r1,0);
	pthread_create(&t2,0,r2,0);
	pthread_create(&t3,0,r3,0);

	while(1)
	{
		//控制3个子线程
		sleep(1);

		// 发送条件量
		//pthread_cond_signal(&c);
		pthread_cond_broadcast(&c);

	}
	
	/* 主线程等待3个子线程结束	*/
	pthread_join(t1,(void **)0);
	pthread_join(t2,(void **)0);
	pthread_join(t3,(void **)0);

	// 释放条件量
	pthread_cond_destroy(&c);

	// 释放互斥量
	pthread_mutex_destroy(&m);

}
