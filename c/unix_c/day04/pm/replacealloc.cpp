#include <cstdio>
#include <cstdlib>
#include <new>

int main()
{
	char *c=(char *)malloc(2);

	/* ���4��c�Ŀռ�С,����c�Ŀռ�����c��ʼ�ĵ�ַ����4���ռ�Ĵ�С,ͬʱ��
		�Ŷ���Ŀռ�
		���4��c�Ŀռ�������ڴ����ͷ�c�Ŀռ䣬�������ڴ���Ѱ��һ��
		�Ƚϴ�Ŀռ�������4���ռ�
	*/
	int *p=(int *)realloc(c,4);


	char *c2=new char[2];
	int *p2=new(c2) int(100);


	printf("the addr of c is %x\n",c);
	printf("the addr of p is %x\n",p);


	printf("the addr of c2 is %x\n",c2);
	printf("the addr of p2 is %x\n",p2);
	return 0;
}
