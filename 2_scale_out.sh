#!/bin/bash

gMaxPercentage=60   
PCT_FILE="/home/sunje/shell/${gMaxPercentage}_pct.txt"
SCALE_OUT_FILE="/home/sunje/shell/scale_out.txt"

if [ ! -e "$PCT_FILE" ]; then
    echo ""
    echo "$PCT_FILE does not exist. SKIP .."
    echo ""
else
    if [ -e "$SCALE_OUT_FILE" ]; then   
        echo ""
        echo "$SCALE_OUT_FILE exist. SKIP .."
        echo ""
    else
        touch $SCALE_OUT_FILE
        group_num=$(cat ${PCT_FILE})
        add_group_num=$((group_num+1))
        add2_group_num=$((add_group_num+1))
        date
        sudo kubectl scale -n ns-goldi statefulset goldilocks --replicas=$add2_group_num
    fi
fi
