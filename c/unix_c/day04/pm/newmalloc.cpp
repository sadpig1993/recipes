#include <cstdio>
#include <cstdlib>
#include <new>

int main()
{
	int *p1 = new int(); /* ��ʼ��Ϊ0 */
	int *p2 = (int *)malloc(4); /* ����ʼ�� */
	int *p3 =(int *)calloc(1,4);/* ��ʼ�� */
	

	printf("%d\n",*p1);
	printf("%d\n",*p2);
	printf("%d\n",*p3);
	free(p1);
	delete(p2);
	delete(p3);
	return 0;
}
