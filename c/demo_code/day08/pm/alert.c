#include <signal.h>
#include <stdio.h>
#include <unistd.h>

void handle(int s)
{
	printf("��ʱ��!\n");
}
main()
{
	//5�����SIGALRM�ź�
	alarm(5);

	signal(SIGALRM,handle);
	while(1);
}
