#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <string.h>
#include <stdlib.h>

main()
{
	
	/* ���س��򣬴�ͨ�ܵ�	*/
	//��ֻ����ʽ�����ܵ�
	//	FILE *f = popen("test.sh","r"); 

	//��ֻд��ʽ�����ܵ�
	FILE *f = popen("test.sh","w"); //��ֻд��ʽ�����ܵ�
	if(!f)
	{
		perror("popen error");
		exit(-1);
	}

	/* �� f ת�����ļ���������	*/
	int fd = fileno(f);
	//д����
	write(fd,"Killer\n",7);

	/* for read info
	char buf[256];
	int r;
	while(1)
	{
		//��ȡ����test.sh ���еı�׼���
		bzero(buf,sizeof(buf));
		r = read(fd,buf,sizeof(buf)-1);
		if(r<=0)
			break;
		printf("buf is [%s]\n",buf);
	}
 	read end	*/

	/* �ر��ļ���ͨ�� 	*/
	pclose(f);
}
