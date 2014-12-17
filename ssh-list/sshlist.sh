#!/bin/bash
fileList=/home/saka/SSH/list
keyfile=/home/saka/Key/yoga.private
TotalList=`cat $fileList | awk '{print $1}'|wc -l`
let TotalList=$TotalList+1

selectList () {
        number=$numberSelected
        selectServer="`head -n $number $fileList|tail -n 1|awk '{print $1}'`"
        selectIP="`head -n $number $fileList|tail -n 1|awk '{print $2}'`"
        selectUser="`head -n $number $fileList|tail -n 1|awk '{print $3}'`"
        selectPort="`head -n $number $fileList|tail -n 1|awk '{print $4}'`"
        ssh -i $keyfile ${selectUser}@${selectIP} -p ${selectPort}

}

number=1
while [ $number -lt $TotalList ]; do
	showServer="`head -n $number $fileList|tail -n 1|awk '{print $1}'`"
	printf "$number) $showServer\n"
	let number=$number+1
done
echo
printf "ssh to) "
read numberSelected
case $numberSelected in
	[a-z]|[A-Z])
		printf "Wrong Input\n"
		exit 1
		;;
	[0-9]|[1-9][0-9])
		if [ $numberSelected -lt $TotalList ]; then
			echo "Begin ssh to `head -n $numberSelected $fileList|tail -n 1|awk '{print $1}'`"
			selectList
		else
			printf "wrong number\n"
		fi
esac
exit 0
