#include <curses.h>

main()
{
	initscr();
	int ch;
	while(1)
	{
		/* 1.����һ���ַ� */
		mvaddstr(4,10,"����ѡ��(Y/y)");
		refresh();

		ch = getch();

		/* 2.�ж��ַ�	*/
		if(ch == 'y' || ch == 'Y')
		{
			break;
		}
		/* ���� ��������ʱ����Կ������� */
		clear();

		mvprintw(10,2,"��������ַ���:%c",ch);
	}

	endwin();

}
