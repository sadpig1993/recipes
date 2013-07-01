#include <stdio.h>

void main()
{
	char a;
	a = getc(stdin);	/* equal a = getchar(); */
	char *p = &a;
	
	printf("%c\t%d\n",a,a);
	printf("%c\t%d\n",*p,*p);
}
