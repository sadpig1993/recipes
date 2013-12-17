#include <stdio.h>
#include <unistd.h>
#include <signal.h>
#include <stdlib.h>


main()
{
		union sigval val;
		int i=0;
		val.sival_int = 8888;
		printf("::%d\n",getpid());
		for(;i<5;i++)
		{
			/* 向sigaction2.c 编译后的执行程序发送2信号 */
			sigqueue(4619,2,val);
		}

}
