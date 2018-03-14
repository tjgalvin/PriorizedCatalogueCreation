#! /usr/bin/env bash

stilts="java -jar /group/mwa/software/stilts/stilts.jar"
out=$1
inputs=($@)
inputs=${inputs[@]:1}
nin=${#inputs[@]}

# join all the frequencies together one week at a time
if [[ ! -e ${out} ]]
then
     cmd="${stilts} tmatchn multimode=pairs nin=${nin} matcher=exact"
     for n in $(seq 1 1 ${nin})
     do
	cmd="${cmd} in${n}=${inputs[${n}]} values1='uuid' suffix1='_${n}'"
     done
     cmd="${cmd} out=${out}"
else
    echo "${out} exists, skipping"
fi
echo ${cmd}
$( ${cmd} )
exit $?
