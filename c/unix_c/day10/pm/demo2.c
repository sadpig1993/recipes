#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <curses.h>
#include <signal.h>
#include <string.h>
#include <math.h>
#include <time.h>

/* 4������
* 1.��ʾʱ�䣬�����
* 2.���������
* 3.��ȡʱ��
* 4.������
*/

WINDOW *wtime,*wnumb;

main()
{
	/* ��ʼ������	*/
	initscr();
	int id=0;

	//����3���ӽ���
	for(id;i<3;id++)
	{
		if(fork())
		{
			//������	
	
		}
		else
		{
			//�ӽ���	
			switch(id)
			{
				case 0:
					while(1)	//���������
					{

					}
					break;
				case 1:
					while(1) 	//����ʱ��
					{

					}
					break;
				case 2:
					while(1)	//���𰴼�
					{

					}
					break;
			}
	
		}
	}

	//ѭ������ˢ�� ��ʾ�������ʱ��


	/* �������		*/	
	endwin();
}

