#!/bin/bash

gMaxPercentage=60   
PCT_FILE="/home/sunje/shell/${gMaxPercentage}_pct.txt"
SCALE_OUT_FILE="/home/sunje/shell/scale_out.txt"
DB_CREATE_FILE="/home/sunje/shell/db_create_complete.txt"
SPLIT_SHARD_FILE="/home/sunje/shell/split_shard.txt"

GSQLNET="gsqlnet sys gliese --no-prompt"

if [ ! -e "$SCALE_OUT_FILE" ]; then
    echo "$SCALE_OUT_FILE does not exist. SKIP .."
else
    group_num=$(cat ${PCT_FILE})
    add_group_num=$((group_num+1))
    add2_group_num=$((add_group_num+1))
    sudo kubectl get pods -n ns-goldi -o wide | awk 'NR==1 || $3 ~ /^(ContainerCreating|Running|Pending|Error|Completed|CrashLoopBackOff|Unknown)$/ {print $3}' | tail -1 > $SCALE_OUT_FILE
    STATUS=$(cat "$SCALE_OUT_FILE")
    echo ""
    echo "========================================="
    echo "POD STATUS : " $STATUS
    echo "========================================="
    echo ""
    if [ $STATUS != "Running" ]; then
        echo ""
        echo "Scale-out is in progress."
        echo ""
    else
        sudo kubectl cp ns-goldi/goldilocks-$add_group_num:/home/sunje/db_create_complete.txt /home/sunje/shell/db_create_complete.txt 2>&1 | grep -v "tar: Removing leading" | grep -v "Cannot stat" | grep -v "tar: Exiting with failure status due to previous errors"
        if [ ! -e "$DB_CREATE_FILE" ]; then
            echo ""
            echo "DB does not create. SKIP .."
            echo ""
        else
            echo ""
            echo "*** DB created. Proceeding with split shard and sequence expansion. ***"
            echo ""
            if [ -e "$SPLIT_SHARD_FILE" ]; then 
                echo ""
                echo "$SPLIT_SHARD_FILE exist. SKIP .."
                echo ""
            else
                touch $SPLIT_SHARD_FILE 

current_seq=(`$GSQLNET << EOF
set timing off
set heading off
select min(c2) from t1;
EOF`)
change_seq=$((current_seq-100000))
change_seq_2=$((change_seq-1000))

echo ""
echo "=========================================================="
$GSQLNET << EOF
alter table t1 split shard s${add_group_num} into ( shard s${add2_group_num} values less than (${change_seq}) at cluster group g${add2_group_num} );
alter sequence SEQ1 restart with ${change_seq_2};
EOF
echo "=========================================================="
echo ""

                rm -f $SPLIT_SHARD_FILE 
                rm -f $DB_CREATE_FILE 
                rm -f $SCALE_OUT_FILE
                rm -f $PCT_FILE
            fi
        fi
    fi
fi 
