#!/bin/bash

export GOLDILOCKS_HOME=$HOME/goldilocks_home
export PATH=$GOLDILOCKS_HOME/bin:$PATH

gMaxPercentage=60   
gSleepTime=2
gLoopCount=28
PCT_FILE="/home/sunje/shell/${gMaxPercentage}_pct.txt"
GSQLNET="gsqlnet sys gliese --no-prompt"

exCheckTBS() {
local result
result=$($GSQLNET << EOF | awk '/GOLDILOCKS-/ {
split($1, arr, "-");                # 첫 번째 필드에서 '-' 기준으로 분리
group_num = arr[2];                 # GOLDILOCKS-X 에서 X 추출
used_pct = $2;                      # 두 번째 필드에서 Percentage 추출
print group_num, used_pct;          # Group number 및 Used Percentage 출력
}'
set timing off
set heading off
SELECT origin_member_name AS CLUSTER_NAME
, MAX(TRUNC(used_data_ext_count / total_ext_count * 100, 0)) AS USED_PERCENTAGE
FROM gv\$tablespace_stat@GLOBAL[IGNORE_INACTIVE_MEMBER]
WHERE 1 = 1
AND tbs_name NOT IN ('DICTIONARY_TBS','MEM_UNDO_TBS','DISK_DATA_TBS','MEM_AUX_TBS')
GROUP BY origin_member_name
ORDER BY origin_member_name desc
LIMIT 1;
EOF
)
read group_num used_pct <<< "$result"
}

doIt() {
for ((i=0;i<$gLoopCount;i++))
do
if [ -e "$PCT_FILE" ]; then
    echo "file exist."
else
    exCheckTBS

    add_group_num=$((group_num+1))
    add2_group_num=$((group_num+2))

    echo ""
    echo "======================"
    echo "Group : $add_group_num"
    echo "USED_PCT : $used_pct"
    echo "======================"
    echo ""

    if [ "$used_pct" -ge "$gMaxPercentage" ]; then
        echo "Max percentage reached. Creating file."
        echo ""
        touch "$PCT_FILE"
        echo "$group_num" > $PCT_FILE
    else
        echo "Max percentage not reached."
        echo ""
    fi

fi
sleep $gSleepTime
done
}

doIt 
