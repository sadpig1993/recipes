/* 注册信号处理函数 */

#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

void handle(int s)
{
    printf("received signal :%d\n",s);
}

main()
{

	signal(SIGRTMIN,handle);
	while(1);

}
