#include <stdio.h>

int diamond(char *q)
{
	if(!q)
	{
		printf("pointer is illegal.\n");
		return -1;		
	}
	if(*q <= 0)
	{
		printf("this is a diamond.\n");
		return 1;
	}
	else
	{
		printf("this is not a diamond.\n");
		return -1;
	}

}
