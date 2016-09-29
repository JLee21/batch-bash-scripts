#!/bin/bash
clear
for file in /home/tmp/outputFiles -iname "*.out" ;
	do
		clear		
		echo "Beginning to find all errors and fatals"
		echo "Make sure your first and only argument is a txt file"
		echo
		echo "*******************************************" > $1
		echo "  E R R O R S " >> $1
		echo "*******************************************">> $1
		more $file | grep -i  "error" >> $1
		echo "*******************************************">> $1
		echo "  F A T A L S " >> $1
		echo "*******************************************">> $1
		more $file | grep -i  "fatal" >> $1
		echo "*******************************************">> $1
		echo "  C R I T I C A L " >> $1
		echo "*******************************************">> $1
		more $file | grep -i  "crit" >> $1
		echo "*******************************************">> $1
		echo "  N O  S U C H  F I L E ">> $1
		echo "*******************************************">> $1
		more $file | grep -i  "No such file" >> $1
		
done
