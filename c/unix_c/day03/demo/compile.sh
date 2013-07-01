#!/bin/bash

# 编译生成动态库
gcc ku.c -shared -fpic -olibku.so

# main.c连接动态库
gcc main.c -ldl -omain
