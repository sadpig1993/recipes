#include <stdio.h>
#include <sys/select.h>
#include <unistd.h>

main()
{
	fd_set fds;//����������
	FD_ZERO(&fds);	//�������������
	FD_SET(0,&fds);	//�ѱ�׼������������0��ӵ�����������

	int r=select(1,&fds,0,0,0);
	if(FD_ISSET(0,&fds))
	{
		printf("��������!\n");
		char buf[20]={};
		read(0,buf,sizeof(buf)-1);
		printf("�������:%s",buf);
	}

}
