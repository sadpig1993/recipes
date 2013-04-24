#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ipc.h>
#include <sys/shm.h>

main()
{
	key_t key;
	int shmid;
	/* 1.����Ŀ¼����key	*/
	key=ftok(".",2);
	if(key==-1)
	{
		perror("ftok");
		exit(-1);
	}
	/* 2.����keyΨһ���������ڴ棬������ID	*/
	shmid=shmget(key,4,IPC_CREAT|IPC_EXCL|0666);
	if(shmid == -1)
	{
		perror("shmget");
		exit(-1);
	}
	printf("key:%x,id:%d\n",key,shmid);

	/* 3.�����ڴ�	*/
	int *p=shmat(shmid,0,0);
	if(!p)
	{
		perror("shmat");
		exit(-1);
	}

	/* 4.�����ڴ�	*/
	*p = 9999;

	/* 5.ж�ص�ַ	*/
	sleep(20);
	shmdt(p);

}
