#include <stdio.h>
#include <signal.h>
#include <stdlib.h>
#include <unistd.h>

/*
*	�� �汾���źŴ�����
*/
void handle(int s,siginfo_t *info,void * m)
{
	printf("��ʼ���δ���!\n");

	printf("%d:%d\n",info->si_pid,info->si_int);

	sleep(2);
	printf("���δ������!\n");
}

main()
{
	/* �����ʼ���źŴ���ṹ��	*/
	struct sigaction act={0};
	/* sigaction �ṹ��ĵ�һ����Ա	*/
//	act.sa_handler=handle;
	
	/* sigaction �ṹ��ĵڶ�����Ա	*/
	act.sa_sigaction=handle;

	/* �жϺ�����ִ��ʱ�� �����ź�10 	*/
	sigemptyset(&act.sa_mask);
	sigaddset(&act.sa_mask,SIGUSR1);
	
	/* ʹ���ϰ汾���źŴ�����	*/
	//act.sa_flags = 0;

	// Ϊ���ܴ�������,ʹ��siginfo_t�ṹ��
	//���ȵ����°汾�Ĵ�����
	act.sa_flags = SA_SIGINFO;

	printf("::%d\n",getpid());

	sigaction(2,&act,0);

	while(1);

}
