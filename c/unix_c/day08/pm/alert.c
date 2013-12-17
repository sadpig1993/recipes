#include <signal.h>
#include <stdio.h>
#include <unistd.h>

void handle(int s)
{
	printf("catch SIGALRM signal!%d\n",s);
}
main()
{
	//5Ãëºó·¢ËÍSIGALRMÐÅºÅ
	alarm(5);

    // ¿¿¿¿¿¿¿¿ ¿SIGALRM¿¿¿¿¿¿¿¿handle
	signal(SIGALRM,handle);
	while(1);
}
