#��print.c�еĺ�����װ�ɾ�̬��������
gcc -c -fpic  print.c
ar rv libku.a print.o
gcc main.c -fpic -lku -L. -omain
