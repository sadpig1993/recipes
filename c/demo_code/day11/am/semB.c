#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <sys/sem.h>
#include <signal.h>

key_t shmkey,semkey;
int shmid,semid;

main()
{

	/* 1.�õ������ڴ���ź���	*/
		shmkey=ftok(".",10);
		semkey=ftok(".",11);
		//�õ������ڴ�
		shmid=shmget(shmkey,100,0);
		//�õ��ź���
		semid=semget(semkey,1,0);
	
	/* 2.������������		*/
		//���ع����ڴ�
		char *buf=shmat(shmid,0,0);

		struct sembuf op;
		op.sem_num=0;
		op.sem_op=-1;
		op.sem_flg=0;

	/* 3.�����ȴ��ź�������		*/
	while(1)
	{
		semop(semid,&op,1);
		//��ȡ�ڴ�
		printf("::%s\n",buf);

	}

}
