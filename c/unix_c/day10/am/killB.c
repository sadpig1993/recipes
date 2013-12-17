/* 向指定的进程发信号   */

#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

main()
{
	int i;
	for(i=0;i<5;i++)
	{
		kill(13535,34);
	}
}
