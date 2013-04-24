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
	
	/* �õ���Ϣ����	*/
	key_t key=ftok(".",200);
	int msgid = msgget(key,0);

	//printf("msgid:%x\n",msgid);

	//��ȡ�ַ�����Ϣ
	struct charmsg cmsg={};
	int i;
	for(i=0;i<10;i++)
	{
		msgrcv(msgid,&cmsg,sizeof(cmsg.data),0,0);
		printf("%s\n",cmsg.data);
	}

	
	// ��ȡ ������Ϣ
	struct intmsg imsg={};
	for(i=0;i<10;i++)
	{
		msgrcv(msgid,&imsg,sizeof(imsg.data),0,0);
		printf("%d\n",imsg.data);
	}
}
