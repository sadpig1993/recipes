#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <sys/wait.h>

main()
{
	int r;
	
	//r=system("ls -l");

	printf("���ý���ID:%d\n",getpid());

	r = system("testa");	
	// r=system("a.sh");

	//r����8λ , Ȼ����255�����ҵ�λ����
	//printf("==%d\n",r>>8&255);


	printf("==%d\n",WEXITSTATUS(r));
}
