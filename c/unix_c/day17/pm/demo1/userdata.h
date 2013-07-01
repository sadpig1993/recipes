#ifndef DATA_CONTAINER_H
#define DATA_CONTAINER_H

#include <deque>
#include <pthread.h>
using namespace std;

class UserData
{
	private:
		deque<int> data;		
		pthread_mutex_t mutex;
		pthread_cond_t cond;
	public:
		/* ѹ������	*/
		void push_data(int num);		
		/* ��������	*/
		int pop_data();	

		/* ���캯��	*/
		UserData();
		/* ��������	*/
		~UserData();
};

#endif
