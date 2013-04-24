#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/ipc.h>
#include <sys/msg.h>

/* 
* ��Ϣ��ʽ�û��Լ�����
* ���涨����������Ϣ�ṹ��
*/

struct charmsg
{
	long type;
	char data[100];
};

struct intmsg
{
	long type;
	int data;
};

main()
{
	key_t key=ftok(".",200);

	int msgid = msgget(key,IPC_CREAT|IPC_EXCL|0666);

	//printf("msgid:%x\n",msgid);

	//�����ַ�����Ϣ
	struct charmsg cmsg={};
	int i;
	for(i=0;i<10;i++)
	{
		cmsg.type = 1;
		bzero(cmsg.data,sizeof(cmsg.data));
		sprintf(cmsg.data,"��Ϣ:%d",i);
		msgsnd(msgid,&cmsg,strlen(cmsg.data),0);
	}

	
	//����������Ϣ
	struct intmsg imsg={};
	for(i=0;i<10;i++)
	{
		imsg.type = 2;
		imsg.data = i;
		msgsnd(msgid,&imsg,sizeof(imsg.data),0);
	}
}
