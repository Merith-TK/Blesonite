#!/bin/bash
echo -e "\033[7;92mINPUT\033[0;92m $1\033[0m" >&2
#im sorry to whoever that reads this
while read userinput
do
	#hack for empty strings to not be empty
	userinput=_$userinput
	if [ $userinput == "_Y" -o $userinput == "_y" ]
	then
		echo "1"
		exit
	elif [ $userinput == "_N" -o $userinput == "_n" ]
	then
		echo "0"
		exit
	fi
	echo -e "\033[7;92mINPUT\033[0;92m $1\033[0m" >&2
done

