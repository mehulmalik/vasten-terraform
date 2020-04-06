#!/bin/bash
all_lines=`cat ../templates/hostnames_list.txt`
declare -i x=1
declare -i y=2

for line in $all_lines ;
do
    sed -e "s~hostname_$x~$line~" ../templates/hostname_list_template.txt 
    if [ $y -ge 3 ]
      then
        break
      fi
done
