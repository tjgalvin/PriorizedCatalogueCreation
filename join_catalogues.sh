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

echo 'relabeling/trimming catalog'
# relabel some of the columns and drop the ones that are not useful
python ../trim_subs.py ${out%%.fits}_long.fits ${out} > temp.sh
source temp.sh
[[ $? ]] | exit

#rm ${out%%.fits}_long.fits

# xmatch_white_subs.sh
final="GLEAMy2_IDR1.fits"
if [[ ! -e ${final} ]]
then
    echo "combining deep and subs"
# note that all sources have a detection/measurement at 076MHz, but not always at higher freqs.
     stilts tmatchn multimode=pairs nin=2 matcher=exact \
	in1=${input} values1='uuid' suffix1='_deep' join1=always \
	in2=${out} values2='uuid_final' suffix2='' \
	fixcols=all out=all_wide.fits ofmt=fits-basic
    [[ $? ]] | exit

    echo "Cleaning up catalog"
    python ../add_names.py all_wide.fits GLEAM_with_names.fits
    [[ $? ]] | exit
    python ../update_meta.py GLEAM_with_names.fits GLEAM_with_meta.fits > update_meta.sh
    source update_meta.sh
    [[ $? ]] | exit
    # python zap.py GLEAM_with_meta.fits ${final}
    cp GLEAM_with_meta.fits ${final}
    stilts tpipe in=${final} out=${final%%.fits}.vot ofmt='votable-binary-inline'
    echo "done"

fi


