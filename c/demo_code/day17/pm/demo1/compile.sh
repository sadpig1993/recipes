#!/bin/bash
# ����C++ͷ�ļ�
#g++ -c userdata.h
#g++ -c mythread.h

# ����C++�����ļ�
g++ -c userdata.cpp 
g++ -c mythread.cpp 
g++ -c data_main.cpp 

g++ userdata.o mythread.o data_main.o -omain -lpthread
