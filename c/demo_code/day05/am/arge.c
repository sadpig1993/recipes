#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
extern char **environ;

/*main�������� 
*argc :��������
*argv :����ֵָ�� ,��ָ���ָ��
*arge :������������ָ���ָ��
*/
int main(int argc,char **argv,char **arge)
{
	/*
	while( arge && *arge)
	{
		printf("%s\n",*arge);
		arge ++;
	}
	*/

	/*
	int i=0;
	while( arge && arge[i])
	{
		printf("%s\t",arge[i]);
		printf("%x\n",arge[i]);
		i++;
	}
	*/

	/*
	while( environ && *environ )
	{
		printf("%s\n",*environ);
		environ ++;
	}
	*/

	printf("%s\n",getenv("PATH"));
	printf("logname is %s\n",getenv("LOGNAME"));
	return 0;

}
