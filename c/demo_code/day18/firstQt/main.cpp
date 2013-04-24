#include "myslots.h"
#include <QApplication>
#include <QWidget>
#include <QPushButton>
#include <QLineEdit>
#include <QTextCodec>

int main(int argc,char **argv)
{

	/*	1.����QTӦ��	*/
	QApplication app(argc,argv);	

	/* ʹ����������ʾ	*/
	QTextCodec *codec=QTextCodec::codecForName("gb2312");
	QTextCodec::setCodecForTr(codec);

	/*	2.��������		*/
	QWidget win;

	/*	3.���ô��巽�����ƴ���		*/
	//�����С400*300
	win.resize(400,300);		
	//������ʾ
	win.move((1024-400)/2,(768-300)/2);	

	//���button �ڴ�����
	QPushButton btn("OK",&win);
	btn.resize(100,30);
	btn.move(100,100);

	// 	���QLineEdit����		�ڴ�����
	//	ʹ����������ʾ
	QLineEdit le(QObject::tr("���"),&win);
	le.resize(50,50);
	le.move(20,20);

	MySlots myslo;
	/* �����ť����һ��messagebox
	QObject::connect(
		&btn,//�źŷ�����
		SIGNAL(clicked()),//���͵��ź�
		&myslo,//�źŷ��͵Ĳۺ����Ķ���
		SLOT(handle())//�ۺ���
	);
	*/
	
	/* �����ť�˳�����	*/
	QObject::connect(
		&btn,//�źŷ�����
		SIGNAL(clicked()),//���͵��ź�
		&app,//�źŷ��͵Ĳۺ����Ķ���
		SLOT(quit())//�ۺ���
	);

	win.setVisible(true);
	/*	4.�ȴ����д������߳���ֹ	*/
	return app.exec();

}
