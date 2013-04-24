#include <curses.h>
#include <unistd.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>
#include <sys/mman.h>

WINDOW *wnumb;
WINDOW *wtime;

main()
{

	int *p=mmap(0,4,PROT_READ|PROT_WRITE,MAP_SHARED|MAP_ANONYMOUS,0,0);
	*p=0;

	//��ʼ��curses		
	initscr();	
	curs_set(0);

	/* ָ�����ڵ�λ�� */
	wnumb=derwin(stdscr,3,9,(LINES)/2,(COLS-9)/2);
	wtime=derwin(stdscr,3,10,0,COLS-10);

	/* �����ڼӱ߿�	*/
	box(wnumb,0,0);
	box(wtime,0,0);
	
	/* ˢ�´���  ���⵽�� ���ˢ��	*/
	refresh();
	wrefresh(wnumb);
	wrefresh(wtime);

	if(fork())
	{
		//������
		//��ʾ7λ�����

		int num;
		while(1)
		{
			
			while( (*p) !=0 );
			*p =1;
			
			/* ȡ7λ�����	*/
			num=random()%10000000;
			/* ���	*/

			/* �ڴ���wnumb�е�1��1�е�λ����ʾ7λ�����	*/
			mvwprintw(wnumb,1,1,"%07d",num);

			/* ˢ����Ļ	*/
			refresh();
			wrefresh(wnumb);
			wrefresh(wtime);
			*p = 0;
			usleep(100000);

		}
		
		delwin(wnumb);
	}
	else
	{
		//�ӽ���
		//��ʾʱ��
		time_t tt;
		struct tm *t;

		while(1)
		{
			tt = time(0);
			t=localtime(&tt);

			while( (*p) != 0);
			*p = 1;
			mvwprintw(wtime,1,1,"%02d:%02d:%02d",t->tm_hour,t->tm_min,t->tm_sec);

			refresh();
			wrefresh(wtime);
			wrefresh(wnumb);
			*p = 0;
			
			sleep(1);
		}
		delwin(wtime);
	}

	//�ͷ�cureses
	endwin();
}
