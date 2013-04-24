#include <curses.h>
#include <unistd.h>
#include <stdlib.h>
#include <math.h>
#include <sys/mman.h>

WINDOW *wnumb;

int flag=0;
void control(int s)
{
	if(flag==1){
	 flag=0;
	}
	else {
	 flag=1;
	}
}
main()
{

	//��ʼ��curses		
	initscr();	
	noecho();
	//��������
	curs_set(0);

	wnumb=derwin(stdscr,3,9,(LINES)/2,(COLS-9)/2);

	//����ӱ߿�
	box(wnumb,0,0);

	signal(34,control);

	if(fork())
	{
		//������Ҫ��������
		//��ʾ7λ�����

		int num;
		while(1)
		{
			//������ʾ����
			//flag Ϊ1��pause������
			if(flag)
			{
				pause();
			}
			/* ȡ7λ�����	*/
			num=random()%10000000;
			/* ���	*/
			mvwprintw(wnumb,1,1,"%07d",num);
			/* ˢ����Ļ	 ԭ����ﵽ�� */
			refresh();
			wrefresh(wnumb);

			usleep(100000);
		}
	}
	else
	{
		//�ӽ���Ҫ��������
		//������
		int ch;
		while(1)
		{
			/* ��������ǿո��ַ�ʱ */
			ch=getch();
			if(ch==32)
			{
				//������ʾ����
				kill(getppid(),34);
			}
		}

	}

	//�ͷ�cureses
	endwin();
}
