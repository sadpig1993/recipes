#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/mman.h>

#include <string.h>
/* memset,memcpy,��Ҫstringͷ�ļ� */

main()
{
	char *str=mmap(
				0,//ϵͳָ��ӳ����׵�ַ
				1*getpagesize(),//ӳ��Ĵ�С
				PROT_READ|PROT_WRITE,//ӳ���Ȩ��
				MAP_SHARED|MAP_ANONYMOUS,//��ʽ
				0,0);

	memset(str,0x00,1*getpagesize());
	memcpy(str,"Hello World!",12);
	
	printf("%s\n",str);
	munmap(str,1*getpagesize());

}

