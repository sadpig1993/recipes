#include <curses.h>
#include <stdlib.h>
#include <string.h>

// ����ȫ�ֱ���
char *struser="�û�: ";
char *strpass="����: ";
char *strblank="[           ]";

void init(); /* ���curses��ʼ�� */
void showLoginUI(int b);  /*	���Ƶ�¼���� */
void input(char *user,char *pass);  /* ���� */
int verify(const char *user,const char *pass);  /*  У�� */
void showMainUI(); /* �л�������Ļ��*/
void destroy();  /* ����curses  */
main()
{
	char user[11];
	char pass[11];

	int b;

	init();
	while(1)
	{
		showLoginUI(b);

		bzero(user,sizeof(user));
		bzero(pass,sizeof(user));

		input(user,pass);

		if(b = verify(user,pass))
		{
			break;
		}
	}
	showMainUI();
	destroy();
}

int verify(const char *user,const char *pass)
{
	if( memcmp(user,"tom",strlen("tom"))!=0 ||memcmp(pass,"123",strlen("123"))!=0 )
	{
		/* ��ʾʧ��	*/
		return 0;
	}
	/* ��ʾ�ɹ� */
	return 1;
}

void init()
{
	/* ��ʼ������ */
	initscr();
	/* ������ʼ��������������ɫ */

	keypad(stdscr,TRUE); /* ��ֹ���ܼ�������� */

}

void destroy()
{
	/* ��������˳� */
	getch();
	/* ����win */
	endwin();
}

void showLoginUI( b)
{
	char *strheader="ѧ����Ϣ����ϵͳ(SIMS) v1.0";

	/* ���֮ǰ������ */
	clear();

	mvaddstr(2,(COLS-strlen(strheader))/2,strheader);

	mvaddstr(6,(COLS-strlen(struser)-strlen(strblank))/2,struser);
	mvaddstr(6,(COLS-strlen(struser)-strlen(strblank))/2 + strlen(struser)+1,strblank);
	mvaddstr(8,(COLS-strlen(strpass)-strlen(strblank))/2,strpass);
	mvaddstr(8,(COLS-strlen(struser)-strlen(strblank))/2 + strlen(strpass)+1,strblank);
	if(!b)
	{
		mvaddstr(LINES-2,(COLS-strlen("��¼ʧ��"))/2,"��¼ʧ��");
	}
	
	/* �����Ҫˢ����Ļ�� */
	refresh();
}
void input(char *user,char *pass)
{
	/* ���ƶ���ָ��λ�� */
	move(6,(COLS-strlen(struser) - strlen(strblank))/2+strlen(struser)+2);
	getnstr(user,10);

	move(8,(COLS-strlen(strpass) - strlen(strblank))/2+strlen(strpass)+2);
	getnstr(pass,10);
}
void showMainUI()
{
	char *strwelcome="��ӭʹ��ѧ����Ϣ����ϵͳSIMS(v1.0)";
	char *strinfo="��������˳�!";

	clear();

	mvaddstr(LINES/2,(COLS-strlen(strwelcome))/2,strwelcome);

	mvaddstr(LINES-2,(COLS-strlen(strinfo))/2,strinfo);

	refresh();
}
