#include <stdio.h>
#include <signal.h>

void handle(int s)
{
	printf("����ı�!\n");
}
main()
{
	signal(SIGWINCH,handle);
	while(1);
}
