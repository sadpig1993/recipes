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
	signal(3,handle);

	while(1);
}

/*
* ������������ 3�ж��ź�
*/

/*
* ��һ��3�ж��źţ��ٷ���һ�������ź�
*/
