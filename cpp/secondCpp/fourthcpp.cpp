#include<string>
#include<iostream>
using namespace std;

//������5.10��CMyException��Ķ���
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
		 cout<<"the program is begin!"<<endl;
     try{// ��̬�ڶ��й�����쳣���󣬵���һ�ι��캯����
          throw new CMyException ("obj1");
     		}
        // ע�⣺�����Ƕ����˰�ָ�뷽ʽ�����쳣����
        catch(CMyException *e)
        {   // �˴����ݸ�e��ʵ�������涯̬����ĵ�ַ��
              //��˲������κι��캯����
              cout<<"catcn a CMyException* type object,name is:"<<e->GetName()<<endl;
              delete e; //��̬�����Ķ�����Ҫ����
        }
        cout<<"the program is end!"<<endl;
      return 0;
}
