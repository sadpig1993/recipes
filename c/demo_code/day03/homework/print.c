#include <stdio.h>

extern int input(int);

/* �ж�����a��b֮�����������ӡ  */
void print(int a,int b)
{
		int i=0;

		for(i=a;i<b;i++)
		{
			if(judgeprime(i) > 0)
			{
				printf("%d\t",i);
			}
			continue;
		}
		printf("\n");
}

/* �ж�һ�����ǲ�������  */
int judgeprime(int number)
{
	int i=0;
	for (i=2; i<number; i++)
	{
		if(number % i == 0)
			return -1;
	}
	return 1;
}
