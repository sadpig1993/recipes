#include <stdio.h>
#include <arpa/inet.h>

main()
{
	char *ip="192.168.0.26";

	//ip��������ʾ 
	struct in_addr sip={};
	//����IP��������ʾ
	struct in_addr hip={};
	//����IP��������ʾ
	struct in_addr nip={};

	//ip�ڼ�����ڲ���������ʾ �޷�������
	sip.s_addr=inet_addr(ip);
	printf("%u\n",sip.s_addr);

	//ip�ڼ�����ڲ���������ʾ �޷�������
	inet_aton(ip,&sip);
	printf("%u\n",sip.s_addr);

	//�õ�������ʶ
	hip.s_addr=inet_lnaof(sip);
	//�õ������ʶ
	nip.s_addr=inet_netof(sip);
	

	printf("������ʶ:%s\n",inet_ntoa(hip));
	printf("�����ʶ:%s\n",inet_ntoa(nip));

}
