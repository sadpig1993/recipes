#include <stdio.h>

/* �ж��������������  */
int input(int a)
{
	if(a<0 || a ==0)
	{
		printf("the value is illegal.\n");
		return -1;
	}
	else
		return a;
}
