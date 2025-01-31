#!/bin/bash

GSQLNET="gsqlnet sys gliese --no-prompt"


get_instance_count() {
count=$(
$GSQLNET << EOF | awk 'NF && $1 ~ /^[0-9]+$/ {print $1; exit}'
SET TIMING OFF
SET HEADING OFF
SELECT COUNT(*) FROM x\$instance@global[IGNORE_INACTIVE_MEMBER];
EOF
)
echo $count
}

instance_count=$(get_instance_count)

if [[ $instance_count -ge 1 ]]; then
    query=""
    for ((i=1; i<=instance_count; i++)); do
        if [[ $i -eq 1 ]]; then
            query="SELECT CLUSTER_MEMBER_NAME, COUNT(*) FROM t1@g$i GROUP BY CLUSTER_MEMBER_NAME"
        else
            query="$query UNION ALL SELECT CLUSTER_MEMBER_NAME, COUNT(*) FROM t1@g$i GROUP BY CLUSTER_MEMBER_NAME"
        fi
    done
    query="$query;"
$GSQLNET << EOF
SET TIMING OFF
$query
EOF
else
    exit 1
fi
