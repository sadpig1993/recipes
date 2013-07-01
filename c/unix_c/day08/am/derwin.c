#include <curses.h>
#include <math.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>

WINDOW *wnum;

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

main()
{
		int num;
		int i;

		/* ��ʼ������	*/

		/* ��ctrl+c�������ź���handle������	*/
		signal(2,handle);

		initscr();
		curs_set(0);	
		/* �����Ӵ���	*/
		wnum = derwin(stdscr,3,9,(LINES-3)/2,(COLS-9)/2);


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
			refresh();
			wrefresh(wnum);
			usleep(100000);
		}

		/* ɾ������	,�ͷ�curses */
		delwin(wnum);
		endwin();

}
