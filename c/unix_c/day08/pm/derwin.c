#include <curses.h>
#include <math.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <sys/time.h>
#include <time.h>
#include <signal.h>

WINDOW *wnum;
WINDOW *wtime;	//����һ����ʾʱ��Ĵ��� ��1��

/* �źŴ�����	 */
void handle(int s)
{
	/* ɾ�����壬�ͷ�curses */
	delwin(wnum);
	endwin();
	//for test
	printf("OK\n");
	exit(0);
}

void timehandle(int s) //�趨��ʱʱ����źŴ�����  ��3��
{
	time_t tt;
	struct tm *t;

	//ȡ��ʱ��
	tt = time(0);
	t=localtime(&tt);

	//��ʾʱ��
	wclear(wtime);
	box(wtime,0,0);
	mvwprintw(wtime,1,1,"%02d:%02d:%02d",
			t->tm_hour,t->tm_min,t->tm_sec);
	//ˢ����Ļ
	refresh();
	wrefresh(wtime);
	wrefresh(wnum);
}

main()
{
		int num;
		int i;

		//��ʱ�������趨  ��5��
		struct itimerval it={};
		it.it_value.tv_usec = 1;
		it.it_interval.tv_sec = 1;

		/* ��ʼ������	*/

		/* ��ctrl+c�������ź���handle������	*/
		signal(2,handle);
		signal(SIGALRM,timehandle); //�󶨶�ʱ�������� ��4��

		initscr();
		curs_set(0);	

		//��ʱ�������
		setitimer(ITIMER_REAL,&it,0); //��ʱ����� ��6��

		/* �����Ӵ���	*/
		wnum = derwin(stdscr,3,9,(LINES-3)/2,(COLS-9)/2);
		
		wtime = derwin(stdscr,3,10,0,COLS-10);//�����ұ���ʾʱ�䴰��  ��2��

		/* ѭ����ʾ7λ�����	*/
		while(1)
		{
			num = 0;
			for(i=0;i<7;i++)
			{
				num = num *10;
				num +=random()%10 ;
			}

			// �Ӵ���clear
			wclear(wnum);
			// �ӱ߿�
			box(wnum,0,0);
			mvwprintw(wnum,1,1,"%07d",num);

			// ˢ�´��� 
			refresh();
			wrefresh(wnum);
			wrefresh(wtime);
			usleep(100000);
		}

		/* ɾ������	,�ͷ�curses */
		delwin(wnum);
		endwin();

}
