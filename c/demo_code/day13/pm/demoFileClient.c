#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#define BUF_LEN 1024

main()
{

	/* 	1.����socket		*/
		int fd=socket(AF_INET,SOCK_STREAM,0);
		if(fd==-1)
		{
			perror("socket");
			exit(-1);
		}
		printf("socket ok!\n");

	/*  2.���ӷ�����			*/
		struct sockaddr_in addr={};
		addr.sin_family=AF_INET;
		addr.sin_port=htons(9998);
		inet_aton("192.168.1.188",&addr.sin_addr);
		int r;
		r = connect(fd,(struct sockaddr *)&addr,sizeof(addr));
		if(r==-1)
		{
		    perror("connect");
		    close(fd);
		    exit(-1);
	    }
		printf("connect ok!\n");
		
	/*  3.1 �����ļ�������				*/
		char filename[]="file.txt";	
		char path[]="/home/ltl/linux_c_danei/day13";
		char file[256]; //�ļ�������·��
		int len;
		len=strlen(filename);
		write(fd,&len,sizeof(int));
		printf("�ļ�������:%u\n",len);

	/*  3.2 �����ļ��� 	*/
		write(fd,filename,len);

	/*  3.3 ���ļ�			*/
		sprintf(file,"%s/%s",path,filename);
		int filefd=open(file,O_RDONLY);
		if(filefd==-1)
		{
			perror("open file"),close(fd),exit(-1);
		}
		printf("file open ok!\n");

	/*  3.4 ��ȡ�ļ����� 	*/
		struct stat st;
		fstat(filefd,&st);
		//�ļ�����
		len = st.st_size;
		printf("�ļ�����:%u\n",len);

	/*  3.5 �����ļ�����		*/
		write(fd,&len,sizeof(int));

	/*  3.6 �����ļ�����		*/
		char buf[1024];
		while(1)
		{
			r = read(filefd,buf,sizeof(buf));
			if(r<=0) //�����ļ�β
			{
				break;
			}
			write(fd,buf,r);
		}
	/*  3.7 �ر��ļ�		*/
		close(filefd);
	/*  4.�ر�socket			*/
		close(fd);


}
