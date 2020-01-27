#!/bin/bash

files=./bin/*

arr=$(echo $files | tr " " "\n")
max_ver_num="$"
exe_file=${arr[0]}

OPTION1="--pattern-graph-type=market"
OPTION2="--pattern-graph-file=../../dataset/small/query_sm.mtx --undirected=1 --pattern-undirected=1 --num-runs=1 --quiet=False"

#put OS and Device type here
EXCUTION=$exe_file
DATADIR="/data-3/leyuan/ics20/"

for k in 0
do
    #put OS and Device type here
    SUFFIX="ubuntu16.04_TitanV"
    LOGDIR=eval_tran/$SUFFIX
    mkdir -p $LOGDIR

    for i in enron loc-gowalla_edges_adj 
    do
        for j in query_sm_6 query_sm_7 query_sm_8 query_sm_9 query_sm_10 query_sm_11 query_sm_12
        do
            echo $EXCUTION market $DATADIR/$i.mtx $OPTION1 --pattern-graph-file=./$j.mtx $OPTION2 --jsondir=$LOGDIR "> $LOGDIR/$i$j.txt 2>&1"
                 $EXCUTION market $DATADIR/$i.mtx $OPTION1 --pattern-graph-file=./$j.mtx $OPTION2 --jsondir=$LOGDIR  > $LOGDIR/$i$j.txt 2>&1
            sleep 30
        done
    done
done

