// textin4.cpp -- reading chars with cin.get()
#include <iostream>
int main(void)
{
    using namespace std;
    int ch;                         // should be int, not char
    int count = 0;

    while ((ch = cin.get()) != EOF) // test for end-of-file
    {
        cout.put(char(ch));		//cout.put(ch);��ʾ�ַ�ch��ch�Ĳ���������char,
								// ����int,����ǿ��ת��
        ++count;
    }
    cout << endl << count << " characters read\n";
	return 0; 
}
