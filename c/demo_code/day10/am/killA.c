/*  ���մ����ź�	*/

#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

void handle(int s)
{
printf("�����ź�:%d\n",s);

}

main()
{

	signal(SIGRTMIN,handle);
	while(1);

}
