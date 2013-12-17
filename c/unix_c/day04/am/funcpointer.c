#include <stdio.h>

int add (int a,int b)
{
	return a+b ;
}

/* ¸ü¸ÄÏµÍ³µÄÑ¹Õ»Ë³Ğò */
/*
int __attribute__((stdcall)) add(int a,int b)
{
	return a+b ;
}
*/

main()
{
		/* ¶¨ÒåÒ»¸öº¯ÊıÖ¸ÕëÀàĞÍ */
        /* 
            ¿¿¿¿¿¿¿¿¿¿¿¿
            ¿¿¿¿ ¿¿¿ ¿¿¿¿¿int¿¿¿¿¿¿¿¿¿int
        */
		typedef int (*addfunc)(int,int);

		// printf("%x\n",main);
		// printf("%x\n",&main);

        /* 
            ¿¿¿¿¿¿¿¿¿ 
            ¿¿¿¿¿int¿¿¿¿¿¿¿¿¿int
        */
		int (*padd)(int,int);
		/* Èç¹ûÖ¸ÕëÀàĞÍ²»Ò»ÖÂÊÇ£¬¿ÉÒÔ½øĞĞ×ª»» */
		padd =(int (*)(int,int))add;
		/*
		padd = add;
		padd = &add;
		*/
        printf("padd: %d\n", padd(100,100));

        /* ¿¿¿addfunc ¿¿¿¿¿¿¿¿¿a */
		addfunc a;
		a = add;
		int r = a(45,55);

		printf("%d\n",r);


}		
