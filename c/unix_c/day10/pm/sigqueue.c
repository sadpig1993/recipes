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
			/* 7413 ��sigaction2��ִ�е�PID */
			sigqueue(7413,2,val);
		}

}
