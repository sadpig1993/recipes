#include <stdio.h>

int add (int a,int b)
{
	return a+b ;
}

/* 更改系统的压栈顺序 */
/*
int __attribute__((stdcall)) add(int a,int b)
{
	return a+b ;
}
*/

main()
{
		/* 定义一个函数指针类型 */
        /* 
            靠靠靠靠靠靠
            靠靠 靠� 靠靠縤nt靠靠靠靠縤nt
        */
		typedef int (*addfunc)(int,int);

		// printf("%x\n",main);
		// printf("%x\n",&main);

        /* 
            靠靠靠靠� 
            靠靠縤nt靠靠靠靠縤nt
        */
		int (*padd)(int,int);
		/* 如果指针类型不一致是，可以进行转换 */
		padd =(int (*)(int,int))add;
		/*
		padd = add;
		padd = &add;
		*/
        printf("padd: %d\n", padd(100,100));

        /* 靠縜ddfunc 靠靠靠靠縜 */
		addfunc a;
		a = add;
		int r = a(45,55);

		printf("%d\n",r);


}		
