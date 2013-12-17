#include <unistd.h>
#include <stdio.h>

/*
    利用pipe创建一个进程间通信的管道，并且调用fork后，子进程用于向管道write，父进程用于从管道read
*/

main()
{
	int fd[2]={0};

	pipe(fd);

	if(fork())
	{
		//父进程
		//fd[0] reading
		//fd[1]	writing 
		//关闭写
		close(fd[1]);
        char buf[10]={0};
        int r=0;
		while(1)
		{
			r = read(fd[0], buf, sizeof(buf)-1);
            buf[r] = 0;
			printf("parent process read data from child process ::%s\n",buf);
		}

	}
	else
	{
		//子进程
		//fd[0] reading
		//fd[1]	writing 
		//关闭写
		close(fd[0]);
		while(1)
		{
			write(fd[1], "hello", 5);
			//printf("child process write data to parent process ::%s\n","hello");
            sleep(1);
		}

	}
}
