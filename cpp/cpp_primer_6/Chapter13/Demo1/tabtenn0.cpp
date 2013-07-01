//tabtenn0.cpp -- simple base-class methods
#include "tabtenn0.h"
#include <iostream>

/* 
*	�˴����캯��ʹ���˵�12�½��ܵĳ�Ա��ʼ���б���﷨��
*
*	Ҳ���Բ����������ʽ
* TableTennisPlayer::TableTennisPlayer (const string & fn, 
*    const string & ln, bool ht)
*	{
*		firstname = fn;
*	 	lastname = ln;
*		hasTable = ht;
*	}
*	������ʽ����Ϊfirstname����string��Ĭ�Ϲ��캯�����ڵ���string�ĸ�ֵ�������firstname
*	����Ϊfn������ʼ���б�ֱ��ʹ��string�ĸ��ƹ��캯����firstname��ʼ��Ϊfn��
*/
TableTennisPlayer::TableTennisPlayer (const string & fn, 
    const string & ln, bool ht) : firstname(fn),
	    lastname(ln), hasTable(ht) {}
    
void TableTennisPlayer::Name() const
{
    std::cout << lastname << ", " << firstname;
}
