// brass.h  -- bank account classes
/* �����嵥13_7 brass.h
*	��Ҫ˵�����¼��㣺
*	1.BrassPlus����Brass��Ļ����������3��˽�����ݳ�Ա��3�����г�Ա����
*	2.Brass���BrassPlus�඼������ViewAcct()��Withdraw()��������BrassPlus�����Brass�������Щ������
*		��Ϊ�ǲ�ͬ��
*	3.Brass��������ViewAcct()��Withdraw()ʱʹ�����¹ؼ���virtual����Щ��������Ϊ�鷽����virtual method��
*	4.Brass�໹������һ����������������Ȼ������������ִ���κβ�����
*
*/
#ifndef BRASS_H_
#define BRASS_H_
#include <string>
// Brass Account Class	����Brass
class Brass
{
private:
    std::string fullName;	/* �ͻ�����	*/
    long acctNum;	/* �˺�*/
    double balance;	/*	��ǰ���ࣨ�˻���*/
public:
    Brass(const std::string & s = "Nullbody", long an = -1,
                double bal = 0.0);
    void Deposit(double amt);	/* ���	*/
    virtual void Withdraw(double amt);	/* ȡ��鷽����	*/
    double Balance() const;	/* */
    virtual void ViewAcct() const;	/* �鷽��	*/
    virtual ~Brass() {}	/* �鷽��	*/
};

//Brass Plus Account Class	������BrassPlus�����м̳�Brass��
class BrassPlus : public Brass
{
private:
    double maxLoan;	/* ͸֧�޶�	*/
    double rate;	/* ����	*/
    double owesBank;	/* Ƿ���	*/
public:
    BrassPlus(const std::string & s = "Nullbody", long an = -1,
            double bal = 0.0, double ml = 500,
            double r = 0.11125);
    BrassPlus(const Brass & ba, double ml = 500, 
		                        double r = 0.11125);
    virtual void ViewAcct()const;
    virtual void Withdraw(double amt);
    void ResetMax(double m) { maxLoan = m; }
    void ResetRate(double r) { rate = r; };
    void ResetOwes() { owesBank = 0; }
};

#endif
