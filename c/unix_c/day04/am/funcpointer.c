#include <stdio.h>

int add (int a,int b)
{
	return a+b ;
}

/* ����ϵͳ��ѹջ˳�� */
/*
int __attribute__((stdcall)) add(int a,int b)
{
	return a+b ;
}
*/

main()
{
		/* ����һ������ָ������ */
        /* 
            ������������
            ���� ��� �����int���������int
        */
		typedef int (*addfunc)(int,int);

		// printf("%x\n",main);
		// printf("%x\n",&main);

        /* 
            ��������� 
            �����int���������int
        */
		int (*padd)(int,int);
		/* ���ָ�����Ͳ�һ���ǣ����Խ���ת�� */
		padd =(int (*)(int,int))add;
		/*
		padd = add;
		padd = &add;
		*/
        printf("padd: %d\n", padd(100,100));

        /* ���addfunc ���������a */
		addfunc a;
		a = add;
		int r = a(45,55);

		printf("%d\n",r);


}		
