#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#include <signal.h>
#include <sys/mman.h>

main()
{

		/* ����100���û�����	*/
		int *fds=mmap(0,getpagesize(),
						PROT_READ|PROT_WRITE,
						MAP_ANONYMOUS|MAP_SHARED,0,0);;

		int i;
		//bzero(fds,sizeof(fds[100]));
		/* fds[100]��ʼ��Ϊ-1	*/
		for(i=0;i<100;i++){
			fds[i]=-1;
		}
		
		int cfd;	//�ͻ�����������ſͻ���������������
		int idx=0;	//ָʾ�ͻ��ĸ���

		/*	1.����socket	*/
		int serverfd=socket(AF_INET,SOCK_STREAM,0);
		if(serverfd == -1){
			perror("socket"),exit(-1);
		}
		printf("����������socket!\n");

		/*	2.�󶨵�ַ		*/
		struct sockaddr_in addr={};
		addr.sin_family=AF_INET;
		addr.sin_port=htons(9999);
		inet_aton("192.168.1.188",&addr.sin_addr);
		int r;
		r = bind(serverfd,(struct sockaddr *)&addr,sizeof(addr));
		if(r == -1){
			perror("bind"),close(serverfd),exit(-2);
		}
		printf("�������󶨵�ַ�ɹ�!\n");
		
		/*	3.����			*/
		r = listen(serverfd,10);
		if(r == -1){
			perror("listen"),close(serverfd),exit(-3);
		}
		printf("�����������ɹ�!,��ʼ�ȴ��ͻ�����.....\n");

		/* ����ṹ�����������ͻ��˵�IP��ַ	*/
		struct sockaddr_in cdr={};
		socklen_t soc_len=sizeof(cdr);

		// ��ʼ������ѭ��
		while(1){
			/*	4.���տͻ�����	*/
			
			//���տͻ����ӣ����洢�ͻ��˵�IP
			cfd=accept(serverfd,(struct sockaddr *)&cdr,&soc_len);
			if(cfd==-1){
				//����������
				close(serverfd);
				printf("����������!\n");
				//ʹ���ź�֪ͨ�ӽ���Ҳ�����ر�
				//ж�ع����ڴ�
				munmap(fds,getpagesize());
				exit(-1);

				break;
			}
			fds[Idx]=cfd;			
			printf("��������:%s\n",inet_ntoa(cdr.sin_addr));
			
			/*	5.�����ӽ���	*/
			if(fork())
			{
				//������
				Idx ++; 	// �Ƚ���Ҫ����һ����÷���fork��
				continue;	//continue ��ʹ������һ������ѭ��
			}
			else
			{
				//�ӽ���
				char buf[256];
				//�ӽ�����ѭ������ 6 7 һ������ѭ�����˳��ӽ���
				while(1)
				{

					/*	6.�ӽ��̽��տͻ�����	*/
					r=read(cfd,buf,sizeof(buf)-1);
					if(r==0)
					{
						fds[Idx]=-1;
						close(cfd);
						printf("�пͻ��˳�!\n");
						break;
					}
					if(r == -1)
					{
						close(fds[idx]);
						fds[idx]=-1;
						close(cfd);
						printf("�������!\n");
						break;
					}
					if(r>0)
					{
						/*	7.�ӽ��̹㲥����	*/
						buf[r]=0;
						printf("::%s\n",buf);
						for(i=0;i<100;i++)
						{
							if(fds[i] != -1)
							{
								write(fds[i],buf,r);
								//������ʵҲ���Դ������쳣
							}

						}
					}

				}
			
				exit(0);
			}

		}

}
