#!/bin/bash

for i in {1..3}
do 
	make clean
	make
	./test 50 /tmp/tmp.DHb4SHq57v
	diff multi_thread/ single_thread/
	python diff.py multi_thread/ single_thread/
done
