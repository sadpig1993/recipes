#include "userdata.h"

/* ���캯��ʵ��	*/
UserData::UserData()
{
	/* ���������������ĳ�ʼ��	*/
	pthread_mutex_init(&mutex,0);
	pthread_cond_init(&cond,0);
	/* �˴�û��ʵ���쳣����	*/
}

/* ��������ʵ��		*/
UserData::~UserData()
{
	/* �����������������ͷ�		*/
	pthread_mutex_destroy(&mutex);
	pthread_cond_destroy(&cond);
}

/*	����� д����	*/
/*	�ӻ�������ʱ���ǵ����߳�д����	
*  	���ӻ�������ʱ�򣬶���߳̿�ͬʱ
*  	д������
*/
void UserData::push_data(int num)
{
	pthread_mutex_lock(&mutex);

	data.push_back(num);
	printf("��������:%d,��֪ͨ\n",num);
	pthread_cond_broadcast(&cond);
	
	pthread_mutex_unlock(&mutex);
}

int UserData::pop_data()
{
	int ret;
	pthread_mutex_lock(&mutex);

	while(data.empty())
	{
		printf("û������,�ȴ���......\n");
		pthread_cond_wait(&cond,&mutex);
	}
	ret=data.back();
	data.pop_back();
	pthread_mutex_unlock(&mutex);	//�������������ȷ��

	return ret;
//	pthread_mutex_unlock(&mutex); ����������������
}
