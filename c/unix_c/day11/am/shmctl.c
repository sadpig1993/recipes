#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <unistd.h>

main()
{
	/*	1.�õ�key	*/
	key_t key=ftok(".",2);

	/* 	2.����key�õ�ID */
	int shmid = shmget(key,4,0);

	/*  3.����ID�õ������ڴ��״̬	*/
	struct shmid_ds ds={};

	//int r = shmctl(shmid,IPC_STAT,&ds);
	int r = shmctl(shmid,IPC_RMID,&ds);
		
	printf("%d\n",r);

	/*
	printf("key:%x\n",ds.shm_perm.__key);
	printf("nattach:%d\n",ds.shm_nattch);
	*/

}
