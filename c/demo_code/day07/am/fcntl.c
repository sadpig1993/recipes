#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>

main()
{
	//��ȡ1��״̬��� 1�Ǳ�׼��� 
	int st=fcntl(1,F_GETFL);
	if(st & O_RDONLY)
	{
		printf("only read\n");
	}
	if(st & O_WRONLY)
	{
		printf("only write\n");
	}
	if(st & O_RDWR)
	{
		printf("read and write\n");
	}
}
