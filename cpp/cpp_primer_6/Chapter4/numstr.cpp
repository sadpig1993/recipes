// numstr.cpp -- following number input with line input
/*
* �˳����BUG�ǵ�cin��ȡ��ݣ����س������ɵĻ��з����������������
* �����cin.getline(address,80);�������з��󣬽���Ϊ��һ�����У�����һ��
* ���ַ�����ֵ��address���顣
* ���BUG��˼·�ǣ��ڶ�ȡ��ַ֮ǰ���ȶ�ȡ���������з�������ʹ��û�в�����
* get()��ʹ�ý���һ��char������get()
* cin >>year;
* cin.get();// or cin.get(ch);
*/ 
#include <iostream>
int main()
{
    using namespace std;
    cout << "What year was your house built?\n";
    int year;
    cin >> year;
    // cin.get();
    cout << "What is its street address?\n";
    char address[80];
    cin.getline(address, 80);
    cout << "Year built: " << year << endl;
    cout << "Address: " << address << endl;
    cout << "Done!\n";
    // cin.get();
    return 0; 
}
