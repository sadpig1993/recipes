#��print.c�еĺ�����װ�ɶ�̬��������
gcc -shared -fpic print.c -olibdlku.so
gcc main.c -ldlku -L. -omainso
