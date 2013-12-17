#include <stdio.h>
#include <pthread.h>
#include <unistd.h>
#include <sched.h>

void *run(void *data)
{
	//while(1)
	//{
		printf("我是线程!\n");
		printf("::%s\n",data);
		//sched_yield();	/* 放弃CPU */
		//sleep(1);
	//}
	return "world";
}

main()
{
	pthread_t tid;
	/* 不传递数据给线程函数
	int r=pthread_create(&tid,0,run,0);
	*/
	/* 传递数据"hello"给线程函数 */
	int r=pthread_create(&tid,0,run,"hello");
	if(r)
	{
		printf("创建失败!\n");
	}
	//while(1)
	//{
		printf("创建成功!\n");
		//sched_yield();	/* 放弃CPU */
		//sleep(1);
	//}

	/* 线程函数返回的数据 */
	char *buf;
	pthread_join(tid,(void **)&buf);
	printf("%s\n",buf);
	
	/* 线程函数不返回数据	
	pthread_join(tid,(void **)0);
	*/
}
