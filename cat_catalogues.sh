#! /usr/bin/env bash

stilts="java -jar /group/mwa/software/stilts/stilts.jar"
out=$1
inputs=($@)
inputs=${inputs[@]:1}
nin=${#inputs[@]}

# concatenate a bunch of files
cmd="${stilts} tcatn nin=${nin}"
for n in $(seq 1 1 ${nin})
do
    cmd="${cmd} in${n}=${inputs[${n}]}"
done
cmd="${cmd} out=${out}"

echo ${cmd}
$( ${cmd} )
exit $?
