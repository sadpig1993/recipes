#include <unistd.h>
#include <stdio.h>

main()
{
	int fd[2]={0};

	pipe(fd);

	if(fork())
	{
		//������
		//fd[0] reading
		//fd[1]	writing 
		//�رն�
		close(fd[0]);
		while(1)
		{
			write(fd[1],"hello",5);
			sleep(1);
		}

	}
	else
	{
		//�ӽ���
		//fd[0] reading
		//fd[1]	writing 
		//�ر�д
		close(fd[1]);
		char buf[10];
		int r;
		while(1)
		{
			r = read(fd[0],buf,sizeof(buf)-1);
			buf[r]=0;
			printf("::%s\n",buf);
		}

	}
}
