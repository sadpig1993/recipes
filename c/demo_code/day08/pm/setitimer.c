#include <signal.h>
#include <stdio.h>
#include <unistd.h>
#include <sys/time.h>


void handle(int s)
{
	printf("��ʱ��!\n");
}

main()
{
	/* ���ö�ʱ������ */
	struct itimerval it={0};
	/*
	it.it_value.tv_sec=5;
	it.it_value.tv_usec=0;
	*/
	it.it_value.tv_sec=0;
	it.it_value.tv_usec=1;

	it.it_interval.tv_sec=1;
	setitimer(ITIMER_REAL,&it,0);

	signal(SIGALRM,handle);
	while(1);
}

