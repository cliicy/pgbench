#!/bin/bash

for i in {0..1000}; 
do clear; cat /proc/cpuinfo | grep -e "cpu MHz"| head -4 >> $1/cpuhz.info; echo -e "\n" >> $1/cpuhz.info;sleep 3; done
