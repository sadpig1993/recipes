#include <curses.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

main()
{
	char *title="ͼ�����ϵͳ";
	char *version="(v 1.0)";

	char *user="�û�:";
	char *pass="����:";

	char *inarea="           ";

	initscr();

	/* �����¼���� */
	/* ������� */
	mvaddstr(3,(COLS-strlen(title))/2,title);
	mvaddstr(5,(COLS-strlen(version))/2,version);


	mvaddstr(7,(COLS-strlen(user)-strlen(inarea))/2,user);	
	attron(A_UNDERLINE);
	addstr(inarea);
	attroff(A_UNDERLINE);
	
	mvaddstr(9,(COLS-strlen(user)-strlen(inarea))/2,pass);	
	attron(A_UNDERLINE);
	addstr(inarea);
	attroff(A_UNDERLINE);

	/* �����������	*/
	getch();
	endwin();

}
