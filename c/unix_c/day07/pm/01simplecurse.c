#include <curses.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>

main()
{
	char *str="Hello Curses���";
	initscr();
	/* ����/���  */
	/*
	addstr(str);
	*/

	/* �����10��10�� */
/*	mvaddstr(10,10,str); */
	/* ���� */
	mvwaddstr(stdscr,LINES/2,(COLS-strlen(str))/2,str); 
	
	/* ˢ����Ļ	*/
	refresh();
	/* ������ֱ����������˳� */
	getch();
	
	/*
	sleep(20);
	*/

	endwin();

}
