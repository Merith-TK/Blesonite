#!/bin/bash
echo -e "\033[7;92mINPUT\033[0;92m $2\033[0m" >&2
#im sorry to whoever that reads this
while read userinput
do
	#hack for empty strings to not be empty
	userinput=$userinput/
	if [ -f $userinput/$1 ]; then
		echo $userinput
		exit
	else
		echo "Couldn't find the file \`$1\` in folder \`$userinput\`!" >&2
		echo -e "\033[7;92mINPUT\033[0;92m $2\033[0m" >&2
	fi
done

