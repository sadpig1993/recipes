#include <stdio.h>

int main()
{
	int m;
	void (*p) ();
	do
	{
		printf("������ѡ�\n");
		printf("1.��ӡ����\n");
		printf("2.��ӡ�˷���\n");
		printf("3.�˳�\n");
		scanf("%d",&m);
		printf("%d\n",m);
		if( m>3 || m<0)
		{
			printf("���벻�Ϸ�������������\n");
		}
	}while( m>4 || m <0);
		if( m ==1)
			p=print_rhombus();
		else if (m==2)
			p=print_cf();
		else if (m == 3)
			exit(0);
	return 0;
}
