#include <stdio.h>
#include <unistd.h>

main()
{
	char buf[256];
	int r;

	r = read(0,buf,sizeof(buf));

	if(r == 0)
	{
		printf("������ֹ����\n");
	}

	if(r>0)
	{
		buf[r]='\0';
		printf("�������ݣ�%s\n",buf);
	}

	if(r == -1)
	{
		printf("�豸����\n");
	}
}
