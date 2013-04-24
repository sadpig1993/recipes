#include "myslots.h"
#include <QApplication>
#include <QDialog>
#include <QPushButton>

int main(int argc,char **argv)
{

	QApplication app(argc,argv);

	QDialog dg;

	dg.resize(400,400);

	QPushButton btn1("OK",&dg);
	QPushButton btn2("Cancel",&dg);
	btn1.resize(100,30);
	btn2.resize(100,30);

	btn1.move(100,50);
	btn2.move(200,50);

	MySlots myslo;
	QObject::connect(
		        &btn1,//�źŷ�����
				SIGNAL(clicked()),//���͵��ź�
			    &myslo,//�źŷ��͵Ĳۺ����Ķ���
			    SLOT(handle_ok())//�ۺ���
				   );
	QObject::connect(
		        &btn2,//�źŷ�����
				SIGNAL(clicked()),//���͵��ź�
			    &myslo,//�źŷ��͵Ĳۺ����Ķ���
			    SLOT(handle_cancel())//�ۺ���
				   );

	dg.setVisible(true);

	return app.exec();


}
