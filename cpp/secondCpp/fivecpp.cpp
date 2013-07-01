#include<string.h>
#include<iostream>
using namespace std;
//�˴�������5.10�е�CMyException�����
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
class CTestClass
{//�����࣬�乹�캯�������׳�int�ͻ�char*���쳣
public:
    CTestClass(int x) throw(int,char*);
    void print();
private:
    int a;
};
CTestClass:: CTestClass(int x) throw(int,char*)
{//�����׳�int�ͻ�char*���쳣�����䱾������int�����쳣
    try{
        if(x==0)
        	throw 0;
        if(x>1000)
        	throw "the value of x is too large.";
        a = 100/x;
    }
    catch(char* s)
    {
        cout<<"have dealed the char* type info:"<<s<<endl;
    }
}
void CTestClass::print()
{
    cout<<a<<endl;
}

void func8(int x) throw(CMyException, int)
{// �����׳�CMyException, int�����쳣
    CTestClass a(x);
    a.print();
    CMyException obj2("obj2");
    throw obj2;
}

void func9() throw(char*)
{// �����׳�char*�����쳣
    char *p = new char[20];
    try{//���������쳣�Ĵ��� 
        throw "error";
    }
    catch(...)
    {// �ͷ�����Ŀռ�p���쳣�����׳�
        cout <<"�ͷ�����Ŀռ�"<<endl;
        delete p;
       	throw;
    }
}
int  main()
{
	cout<<"the program is begin!"<<endl;
    try{ //���ܲ����쳣�Ĵ���
        throw new CMyException("obj1");
    }
    catch(CMyException *e)
    {
         cout<<"catch a CMyException type object ,the name is:"<<e->GetName()<<endl;
         delete e;
    }
    try{
        cout<<"please input an int type value:";
        int x=0;
        cin>>x;
        func8(x);
        func9();
    }
    catch(int x)
    {
        cout<<"have dealed the int type exception:"<<x<<endl;
    }
    catch(char *s)
    {
        cout<<"have dealed the char* type exception:"<<s<<endl;
    }
    catch(CMyException &e)
    {
        cout<<"have dealed CMyException type exception:"
            <<e.GetName()<<endl;
    }
    catch(...)
    {
        cout<<"have dealed the all type exception"<<endl;
    }
    cout<<"the program is end!"<< endl;
    
    return 0;
}
