/*
* ���BUG��
* ��BUG�汾
*/
#include <stdio.h>
#include <math.h>
#include <pthread.h>
#include <curses.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>


/* ��ʾ�������ʱ��Ĵ���	*/
WINDOW *wnum,*wtime;
int num;
time_t tt;
struct tm *t;

/* ˢ���̺߳���	*/
void *winrefresh(void *data)
{
	while(1)	/* ��ѭ����ֹ�߳���ȥ	*/
	{
		/* ��ʾ�����		*/
		mvwprintw(wnum,1,1,"%07d",num);

		/* 	��ʾʱ��		*/
		mvwprintw(wtime,1,1,"%02d:%02d:%02d",
					t->tm_hour,t->tm_min,t->tm_sec);

		/*	ˢ����Ļ		*/
		refresh();
		wrefresh(wnum);
		wrefresh(wtime);
		usleep(10000);/* ��Ϣ10����	*/
	}
}

/* ������̺߳���	*/
void *num_run(void *data)
{
	while(1)
	{
		/* ����7λ�����	*/
		num=random()%10000000;
		usleep(10000);/* ��Ϣ10����	*/
	}
}

/* ʱ���̺߳���		*/
void *time_run(void *data)
{
	while(1)
	{
		/* ��ȡϵͳʱ��		*/
		tt=time(0);
		t=localtime(&tt);
		sleep(1);	/* ��Ϣ1��	*/
	}

}

main()
{

	pthread_t th_time,th_num,th_winrefresh;

	/* 1.��ʼ��curses 	*/
	initscr();
	/* ���ع��			*/
	curs_set(0);
	wnum=derwin(stdscr,3,9,LINES/2,(COLS-9)/2);
	wtime=derwin(stdscr,3,11,0,COLS-11);
		/* �ӱ߿�	*/
	box(wnum,0,0);
	box(wtime,0,0);
		/* ˢ�������ڼ�����С����	*/
	refresh();
	wrefresh(wnum);
	wrefresh(wtime);

	/* 2.�����߳�		*/
	pthread_create(&th_time,0,time_run,0);
	pthread_create(&th_num,0,num_run,0);
	pthread_create(&th_winrefresh,0,winrefresh,0);

	/* 3.�ȴ����߳̽���	*/
	pthread_join(th_time,(void **)0);
	pthread_join(th_num,(void **)0);
	pthread_join(th_winrefresh,(void **)0);

	/* 4.�ͷ�curses		*/
	delwin(wnum);
	delwin(wtime);
	endwin();

}
