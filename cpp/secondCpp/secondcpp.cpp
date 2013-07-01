#include<string>
#include<iostream>
using namespace std;
class CMyException
{
	//�쳣�࣬����Ķ�����Ϊ�׳��쳣ʱ���ݵ��쳣������
public:
     CMyException (string n="none") : name(n)
     {//���캯�������ݲ���n����һ������Ϊn���쳣�����
          cout<<"Construct a CMyException object,the object's name is:"<<name<<endl;
      }
      CMyException (const CMyException &e)
      {//�������캯�������ݲ���e��������һ���쳣�����
             name = e.name;
             cout<<"copy a CMyException type object,the object's name is:"<<name<< endl;
       }
      virtual ~ CMyException () 
      {
            cout << "delete a CMyException object,the object's name is:"<<name<< endl;
       }
      string GetName() {return name;} 
protected:
      string name; //�쳣����������
};
int main()
{
	  cout<<"the program is begin!"<< endl;
      try{
           // ����һ���쳣���󣬼������һ��CMyException��
           //�Ĺ��캯�������Ǹ��ֲ�������
           CMyException obj1("obj1");        //�����׳��쳣����ע�⣺��ʱVC�������Ḵ��
           //һ���µ��쳣���󣬼�����һ��CMyException
           //��Ŀ������캯�����¿����Ķ����Ǹ���ʱ������
           throw obj1;
     }
     catch(CMyException e)
     {    //���쳣�������ݸ�eʱ�������Ǵ�ֵ��ʽ����
               //�˻����һ�ο������캯��
            cout<<"catch a CMyException type object,the object's name is��"<<e.GetName()<<endl;
     }
     cout<<"the program is end!"<< endl;
     return 0;
}
