#!/bin/bash

echo $$ > polling_pid

while /bin/true
do
	sleep 10
	echo "Im alive"
done


