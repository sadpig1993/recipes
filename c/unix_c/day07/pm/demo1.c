#include <curses.h>
#include <unistd.h>

int x;
int y;

main()
{
	initscr();
	x = 0;
	y = LINES/2;

	/* ���ع�� */
	curs_set(0);
	while(1)
	{
		/* ���� */
		/* 	clear();  */
		erase(); 
		/* �ı��ַ���λ����ʾ  */
		x++;
		if(x>=COLS)
		{
			x = 0;
		}
		move(y,x);
		addch('A'|A_BOLD);
		/*  ˢ��    */
		refresh();
		/* ��ͣ	*/
		/* ��ͣ���� */
		usleep(500000);
	}
	endwin();
}
