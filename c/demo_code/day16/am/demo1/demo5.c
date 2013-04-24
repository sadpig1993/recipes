/*
* 4���߳���ʵ��ҡ������һ���߳���ʾ�������һ���߳���ʾʱ�� 
* һ���߳���ˢ����Ļ��һ���߳���ʵ�ֿո񰴼���������Ŀ���
* ������ʹ��pthread_kill + sigwait + ����ֵ��ʵ�ֿո񰴼���������Ŀ���
*/
#include <stdio.h>
#include <math.h>
#include <pthread.h>
#include <curses.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>
#include <signal.h>

pthread_t th_time,th_num,th_winrefresh,th_signal;

/* ��ʾ�������ʱ��Ĵ���	*/
WINDOW *wnum,*wtime;
int num;
time_t tt;
struct tm *t;

/* ���Ʋ���ֵ	*/
int flag=0;

/* �ո���ƺ���		*/
void *control(void *data)
{
	int ch;
	while(1)
	{
		ch=getch();
		if(ch==32)
		{
			if(flag==1)
			{
				flag=0;
			}
			else
			{
				flag=1;
			}
			usleep(10000);
			pthread_kill(th_num,34);
		}
	}

}

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
	sigset_t sigs;
	sigemptyset(&sigs);
	sigaddset(&sigs,34);
	int s;

	while(1)
	{
		if(flag)
		{
			sigwait(&sigs,&s);
		}
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
	pthread_create(&th_signal,0,control,0);

	/* 3.�ȴ����߳̽���	*/
	pthread_join(th_time,(void **)0);
	pthread_join(th_num,(void **)0);
	pthread_join(th_winrefresh,(void **)0);
	pthread_join(th_signal,(void **)0);

	/* 4.�ͷ�curses		*/
	delwin(wnum);
	delwin(wtime);
	endwin();

}
