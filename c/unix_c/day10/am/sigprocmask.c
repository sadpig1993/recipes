/*  计算1 - 1000 的和  */

/* 靠sigprocmask 屏蔽ctrl+c发出的SIGINT信号    */

#include <signal.h>
#include <stdio.h>
#include <unistd.h>


main()
{
	int sum = 0;
	int i;
	
    /* define an signal set and empty it */
	sigset_t masksigs;
	sigemptyset(&masksigs);

	/* 1.*/
	sigset_t sigs;
	sigemptyset(&sigs);
	sigaddset(&sigs,SIGINT);
	//	屏蔽所有的信号
	//	sigfillset(&sigs);

	/* 3.设置信号集合被屏蔽		*/
	sigprocmask(SIG_BLOCK,&sigs,0);

	/***********************************/
	for(i=0;i<10001;i++)
	{
		sum += i;
		usleep(100);

		sigpending(&masksigs);
		if(sigismember(&masksigs,2))
		{
			printf("SIGINT pending\n");
		}
	}

	printf("sum is %d\n",sum);
	printf("mask end \n");

	/*  解除信号屏蔽	*/
	sigprocmask(SIG_UNBLOCK,&sigs,0);

	/**********************************/

	printf("end\n");
}
