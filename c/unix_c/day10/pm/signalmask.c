#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <signal.h>

void handle(int s)
{

	printf("�����ж�...\n");
	sleep(10);
	printf("�жϴ������!\n");
}

main()
{
	signal(2,handle);

	while(1);
}

/*
*	����������ctrl+c
*/

/*
*	��һ��ctrl+c,	����SINGUSR1�ź�
*/
