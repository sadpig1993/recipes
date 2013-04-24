#include <curses.h>
#include <unistd.h>
#include <stdlib.h>
#include <math.h>
#include <sys/mman.h>

WINDOW *wnumb;

/* ͨ���ո������� */
main()
{

	/* ָ��Pָ����������������� */
	int *p;
	p=mmap(0,4,PROT_READ|PROT_WRITE,MAP_SHARED|MAP_ANONYMOUS,0,0);
	*p=0;

	//��ʼ��curses		
	initscr();	
	noecho();
	//��������
	curs_set(0);

	wnumb=derwin(stdscr,3,9,(LINES)/2,(COLS-9)/2);

	//����ӱ߿�
	box(wnumb,0,0);

	if(fork())
	{
		//������Ҫ��������
		//��ʾ7λ�����

		int num;
		while(1)
		{

			//������ʾ����
			if( (*p)==0 )
			{
				/* ȡ7λ�����	*/
				num=random()%10000000;
				/* ���	*/
				mvwprintw(wnumb,1,1,"%07d",num);
				/* ˢ����Ļ	 ԭ����ﵽ�� */
				refresh();
				wrefresh(wnumb);
			}	
			usleep(100000);
		}
	}
	else
	{
		//�ӽ���Ҫ��������
		//������
		int ch;
		while(1)
		{
			/* ��������ǿո��ַ�ʱ */
			ch=getch();
			if(ch==32)
			{
				//������ʾ����
				if(*p == 0)
				{
					*p=1;
				}
				else
				{
					*p=0;
				}
			}
		}

	}

	//�ͷ�cureses
	endwin();
}
