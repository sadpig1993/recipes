#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/stat.h>

struct book
{
	char name[32];
	char author[32];
	float price;
	int amount;
}

/* ���ھʹ��ļ��������ھʹ����ļ�	 */
int opendb(const char *file)
{
	if(file == NULL)
			return -1;
	int fd;
	fd = open(file,O_CREAT|O_RDWR,0666);
	if(fd == -1)
	{
		perror("opendb error,file cannot open");
		return -1;
	}
	return 0;
}

/* ӳ���ļ�	  */
void *mapdb(int fd)
{
	if(fd == -1)
		return -1;
	void *p;
	p = mmap(0,getpagesize(),
				PROT_READ|PROT_WRITE,
				MAP_SHARED,fd,0);
	if(p == (void *)0)
	{
		perror("mmap error.");
		exit(-1);
	}
	return p;
}

/* ���뱣��һ�������Ϣ  */
int inputbook(struct book *b)
{
	memset(b,0x00,sizeof(struct book));

	printf("�����������Ϣ\n");
	
	printf("����������\n");
	scanf("%s",b->name);

	printf("�������������\n");
	scanf("%s",b->author);

	printf("��������ļ۸�\n");
	scanf("%f",b->price);

	printf("�������������\n");
	scanf("%d",b->amount);

	return 0;

}

/* ��������������� */	
/* �����������ת�������� */
void inputint(const char *info,int *n)
{
	if(info == NULL)
		return -1;
	
}
void inputstr(const char *info,char *str)
void inputch(const char *info,char *ch)
void inputfloat(const char *info,float *f)

/* �޸��ļ���С������һ����¼�Ŀռ䣬���������ļ��Ĵ�С		*/
size_t addrecord();

main()
{
	int fd;
	struct book *b;
	char isover;
	size_t size;

	/* 1.�򿪻��ߴ����ļ� 	*/
	fd = open("book.dat");
	b = mapdb(fd);

	while(1)
	{
		/* 2.����ͼ����Ϣ	*/
		inputbook(b);

		/* 3.��������	*/
	  	szie=addrecord();

		/* 4.��ʾ�Ƿ��������	*/
		inputchar("�Ƿ��������",&isover);
		if(isover!='y' || isover !='Y')
				break;

	}

	/* 5.�ͷŹر�	*/
	munmap(*p,size);
	close(fd);
}
