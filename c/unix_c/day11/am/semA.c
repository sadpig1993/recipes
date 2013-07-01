#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/ipc.h>
#include <sys/sem.h>
#include <sys/shm.h>
#include <signal.h>

/* ȫ�ֱ�������	*/
union semun{
		int val;
		struct semid_ds *ds;
		unsigned short *array;
		struct seminfo *_buf;
};

int shmid,semid;
key_t shmkey,semkey;

//char buf[50];//����Ļ���
int r;

main()
{

	/* 1.���������ڴ� �ź���	*/
		shmkey=ftok(".",10);
		semkey=ftok(".",11);	
		//����100�ֽڵĹ����ڴ�
		shmid=shmget(shmkey,100,IPC_CREAT|IPC_EXCL|0666);
		if(shmid == -1)
		{
			perror("�����ڴ�ʧ��"),exit(-1);
		}
		//����1���ź���
		semid=semget(semkey,1,IPC_CREAT|IPC_EXCL|0666);
		if(semid == -1)
		{
			perror("�ź���ʧ��"),exit(-1);
		}
		// ��ʼ���ź���
		union semun v;
		v.val=0;
		semctl(semid,0,SETVAL,v);

	/* 2.���ع����ڴ�����		*/
		char  *buf=shmat(shmid,0,0);

	/*	3.�����ź����Ĳ��������ҽ��в���	*/
		struct sembuf op;
		op.sem_num = 0;
		op.sem_op=1;
		op.sem_flg=0;

		while(1)
		{
			//�ӱ�׼���������ȡ����
			r = read(0,buf,49);
			if(r<=0)
			{
				break;	//ctrl+d
			}
			buf[r]=0;

			//�޸��ź���(���ź���+2����֤�����Ľ��̲�����)
			semop(semid,&op,1);

		}

	//ж�ع����ڴ�
	shmdt(buf);

	//ɾ�������ڴ�
	shmctl(shmid,IPC_RMID,0);

	//ɾ���ź���
	semctl(semid,0,IPC_RMID,0);
	
}
