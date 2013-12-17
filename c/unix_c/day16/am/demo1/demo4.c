/*
* 解决BUG版
* 无BUG版本
*/
#include <stdio.h>
#include <math.h>
#include <pthread.h>
#include <curses.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>

pthread_mutex_t m;


/* 显示随机数和时间的窗体	*/
WINDOW *wnum,*wtime;
int num;
time_t tt;
struct tm *t;

/* 刷新线程		*/
void refreshwin()
{
		/* 显示随机数		*/
		mvwprintw(wnum,1,1,"%07d",num);

		/* 	显示时间		*/
		mvwprintw(wtime,1,1,"%02d:%02d:%02d",
					t->tm_hour,t->tm_min,t->tm_sec);

		/*	刷新屏幕		*/
		refresh();
		wrefresh(wnum);
		wrefresh(wtime);
		usleep(10000);/* 休息10毫秒	*/
}

/* 随机数线程函数	*/
void *num_run(void *data)
{
	while(1)
	{
		/* 产生7位随机数	*/
		num=random()%10000000;

		pthread_mutex_lock(&m);
		refreshwin();
		pthread_mutex_unlock(&m);

		usleep(10000);/* 休息10毫秒	*/
	}
}

/* 时间线程函数		*/
void *time_run(void *data)
{
	while(1)
	{
		/* 获取系统时间		*/
		tt=time(0);
		t=localtime(&tt);

		pthread_mutex_lock(&m);
		refreshwin();
		pthread_mutex_unlock(&m);

		sleep(1);	/* 休息1秒	*/
	}

}

main()
{

	pthread_mutex_init(&m,0);

	pthread_t th_time,th_num;

	/* 1.初始化curses 	*/
	initscr();
	/* 隐藏光标			*/
	curs_set(0);
	wnum=derwin(stdscr,3,9,LINES/2,(COLS-9)/2);
	wtime=derwin(stdscr,3,11,0,COLS-11);
		/* 加边框	*/
	box(wnum,0,0);
	box(wtime,0,0);
		/* 刷新主窗口及两个小窗口	*/
	refresh();
	wrefresh(wnum);
	wrefresh(wtime);

	/* 2.创建线程		*/
	pthread_create(&th_time,0,time_run,0);
	pthread_create(&th_num,0,num_run,0);

	/* 3.等待子线程结束	*/
	pthread_join(th_time,(void **)0);
	pthread_join(th_num,(void **)0);

	/* 4.释放curses		*/
	delwin(wnum);
	delwin(wtime);
	endwin();

	pthread_mutex_destroy(&m);
}
