#include <stdio.h>
#include <unistd.h>

/* �ļ�����ͷ�ļ� */
#include <fcntl.h> 
#include <stdlib.h>
#include <string.h>

writefile()
{
	
	int fd;
	/* �Ƿ��������ı�־ */
	/*
	int iscon;
	*/
	char iscon ;

	char *filename="a.dat";
	char bookname[100];
	int count;
	float price;
	char authorname[20];
	
	/* 1.�����ļ� */
	fd = open(filename,O_RDWR|O_CREAT,0666);
	if(fd == -1)
	{
			/*
		printf("open error:%m\n",);
			*/
			perror("open error");
			exit(-1);
	}
	
	/* 2.д��¼  */


	/*
	while(1)	
	{
		bzero(bookname,sizeof(bookname));
		bzero(authorname,sizeof(authorname));
		printf("���������� ������ �۸� ����\n");
		scanf("%s%s%f%d",bookname,authorname,&price,&count);
		write(fd,bookname,sizeof(bookname));
		write(fd,authorname,sizeof(authorname));
		write(fd,&price,sizeof(price));
		write(fd,&count,sizeof(count));
		
		printf("\n�Ƿ��������\n");
		scanf("%d",&iscon);
		if(iscon <= 0)
			break;
	}
	*/
	do
	{
		bzero(bookname,sizeof(bookname));
		bzero(authorname,sizeof(authorname));
		printf("���������� ������ �۸� ����\n");
		scanf("%s%s%f%d",bookname,authorname,&price,&count);
		write(fd,bookname,sizeof(bookname));
		write(fd,authorname,sizeof(authorname));
		write(fd,&price,sizeof(price));
		write(fd,&count,sizeof(count));
		
		printf("\n�Ƿ��������\n");
		scanf(" %c",&iscon);
	
	}while((iscon == 'y')|| (iscon == 'Y'));


	/* 3. �ر��ļ�  */
	close(fd);	
}

readfile()
{
	
	int fd;
	char bookname[100];
	int count;
	float price;
	char authorname[20];
	char *filename="a.dat";
	
	/* 1.���ļ� */
	fd = open(filename,O_RDWR);
	if(fd == -1)
	{
			/*
		printf("open error:%m\n",);
			*/
			perror("open error");
			exit(-1);
	}
	
	/* 2.ѭ����ȡ���� */

	int r;
	while(1)
	{
		r = read(fd,bookname,sizeof(bookname));
		if(r<=0)
				break;
		r = read(fd,authorname,sizeof(authorname));
		r = read(fd,&price,sizeof(float));
		r = read(fd,&count,sizeof(int));

		printf("%s,%s,%.2f,%d\n",bookname,authorname,price,count);
	}
	/* 3. �ر��ļ�  */
	close(fd);	
}

/* �����������������鼮��Ϣ */
SelectInfoByName(char *name)
{
	int fd;
	char bookname[100];
	int count;
	float price;
	char authorname[20];
	char *filename="a.dat";
	
	/* 1.���ļ� */
	fd = open(filename,O_RDWR);
	if(fd == -1)
	{
		perror("open error");
		exit(-1);
	}
	
	/* 2.ѭ����ȡ���� */
	int r;
	while(1)
	{
		/* select according to bookname
		r = read(fd,bookname,sizeof(bookname));
		if(strcmp(bookname,name) != 0)
				continue;
		else
		{
			r = read(fd,authorname,sizeof(authorname));
			r = read(fd,&price,sizeof(float));
			r = read(fd,&count,sizeof(int));
			printf("%s,%s,%.2f,%d\n",bookname,authorname,price,count);
			break;
		}
		*/

		r = read(fd,bookname,sizeof(bookname));
		r = read(fd,authorname,sizeof(authorname));
		if(strcmp(authorname,name) != 0)
				continue;
		else
		{
			r = read(fd,&price,sizeof(float));
			r = read(fd,&count,sizeof(int));
			printf("%s,%s,%.2f,%d\n",bookname,authorname,price,count);
			break;
		}
	}

	/* 3. �ر��ļ�  */
	close(fd);	
	return;
}
