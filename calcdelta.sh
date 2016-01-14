#!/bin/bash

YDAY=`date +%Y_%m_%d -d "yesterday"`
TODAY=`date +%Y_%m_%d`
OUTPUT_DIR="output_$TODAY"

mkdir $OUTPUT_DIR
YESTERDAYSFILE="input/ofac_full_$YDAY.xml"
TODAYSFILE="input/ofac_full_$TODAY.xml"
ADDED="$OUTPUT_DIR/added.xml"
REMOVED="$OUTPUT_DIR/removed.xml"
CHANGED="$OUTPUT_DIR/changed.xml"

echo $YESTERDAYSFILE
echo $TODAYSFILE

#clear outputs
if [ -e $ADDED ]; then
 rm $ADDED 
fi
if [ -e $REMOVED ]; then
 rm $REMOVED
fi

#Calc added lines
ADDEDLINES=( `diff $YESTERDAYSFILE $TODAYSFILE | grep -n -E '^[0-9]+,?[0-9]*[a][0-9]+,?[0-9]*' | awk -Fa '{print $2}'` )
for (( i = 0 ; i < ${#ADDEDLINES[@]} ; i++ ))
do
sed -n ${ADDEDLINES[$i]}p $TODAYSFILE >> $ADDED
done

#Calc removed lines
REMOVEDLINES=( `diff $YESTERDAYSFILE $TODAYSFILE | grep -n -E '^[0-9]+,?[0-9]*[d][0-9]+,?[0-9]*' | awk -Fd '{print $1}'` )
for (( i = 0 ; i < ${#REMOVEDLINES[@]} ; i++ ))
do
sed -n ${REMOVEDLINES[$i]}p $TODAYSFILE >> $REMOVED
done

#Calc changed lines
#CHANGEDLINES=( `diff $YESTERDAYSFILE $TODAYSFILE | grep -n -E '^[0-9]+,?[0-9]*[c][0-9]+,?[0-9]*' | awk -Fc '{print $2}'` )
#for (( i = 0 ; i < ${#CHANGEDLINES[@]} ; i++ ))
#do
#sed -n ${CHANGEDLINES[$i]}p $TODAYSFILE >> $CHANGED
#done
