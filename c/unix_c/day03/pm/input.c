#include <stdio.h>

int input(char *q)
{
	if(!q)
	{
		printf("pointer is illegal\n");
		return -1;
	}
	if (*q <= 0)
	{
		printf("input value is illegal.\n");
		return -1;
	}
	else
		return *q;
}
