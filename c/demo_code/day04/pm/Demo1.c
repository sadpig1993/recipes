#include <stdio.h>
#include <unistd.h>

/* �ж�һ�����Ƿ�������  */
int isprimer(int a)
{
	int i;
	for(i=2;i<a;i++)
	{
		/* ���� */
		if(a%i==0)
			return 1;
	}

	return 0; /* ���� */
}

main()
{
	/* 1. ���ҵ�һ���׵�ַ */
		int *pstart=sbrk(0);
		int *p; /* ��¼��ǰ��ַ */
		p=pstart;

	/* 2. ѭ�����������ҵ��ͷ���4�ֽڣ���������Ž�ȥ */
	
		int i;
		for(i=2;i<10000;i++)
		{
			if(!isprimer(i))
			{
				brk(p+1);
				*p=i;
				p=sbrk(0); /* �����ϴε�ĩβ��ַ  */
			}
		}

	/* 3. �õ�ĩβ��ַ */
	int *pend = sbrk(0);

	/* 4. ѭ���ڴ棬��ӡ�������� */
	p = pstart;
	while(p!=pend)
	{
		printf("%d\n",*p);
		p++;
	}

	printf("the num of the primer is %d\n",(pend-pstart));
	/* 5. �ͷſռ� */
	brk(pstart);
}

