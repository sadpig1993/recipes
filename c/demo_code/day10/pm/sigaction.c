#include <stdio.h>
#include <signal.h>
#include <stdlib.h>
#include <unistd.h>

/*
*	�ϰ汾���źŴ�����
*/
void handle(int s)
{
	printf("��ʼ���δ���!\n");
	sleep(5);
	printf("���δ������!\n");
}

main()
{
	/* �����ʼ���źŴ���ṹ��	*/
	struct sigaction act={0};
	act.sa_handler=handle;

	/* �жϺ�����ִ��ʱ�� �����ź�10 	*/
	sigemptyset(&act.sa_mask);
	sigaddset(&act.sa_mask,SIGUSR1);
	
	/* ʹ���ϰ汾���źŴ�����	*/
	act.sa_flags = 0;
	printf("::%d\n",getpid());

	sigaction(2,&act,0);
	//signal(2,handle);

	while(1);

}
