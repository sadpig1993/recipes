#include <curses.h>

main()
{
	int x=1,y=5;
	int ch;
	initscr();
	curs_set(0);
	noecho();
	keypad(stdscr,TRUE);
	while(1)
	{
		clear();
		mvaddch(y,x,'A');
		refresh();

		/* 1.������������ */
		ch = getch();

		/* 2.���ݰ��������ַ���λ�� */
		switch(ch)
		{
			case KEY_UP:
				y--;	
				break;
			case KEY_RIGHT:
				x++;
				break;
			case KEY_DOWN:
					y++;
					break;
			case KEY_LEFT:
				x--;
				break;
		}

		/* 3.�ڱ䶯��λ����ʾ�ַ� */
		/*
		clear();
		mvaddch(y,x,ch);
		refresh();
		*/
	}

	endwin();

}
