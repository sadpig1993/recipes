#!/bin/bash

for file in `ls *.csv`
do
	echo $file
	# 把日期中的 / 替换为 -
	sed -i 's/\//-/g' $file
done


