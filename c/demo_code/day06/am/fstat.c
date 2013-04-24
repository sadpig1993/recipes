#include <unistd.h>
#include <sys/stat.h>
#include <stdio.h>
#include <fcntl.h>

main()
{
	int fd;
	struct stat st;
	int r;

	/* 1. ���ļ�  */
	fd = open("text.txt",O_RDONLY);

	/* 2. �����ļ���Ϣ */
	r = fstat(fd,&st);
	if (r == -1)
	{
		perror("fstat error.");
	}
	else
	/* 3. ��ӡ�ļ���Ϣ */
	{
		printf("size:%d,\tmode:%05o\n",
				st.st_size,st.st_mode);
	}

	/* 4. �ر��ļ� */
	close(fd);
}
