#include "myslots.h"		/* ""��ͷ�ļ����û��Զ����ͷ�ļ�	*/
#include <QMessageBox>

void MySlots::handle()
{

	QMessageBox::information(NULL,
				"Information","this is a test");

}
