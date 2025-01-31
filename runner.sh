#!/bin/bash
while true
do
   sh /home/sunje/shell/2_scale_out.sh
   sh /home/sunje/shell/3_split_shard.sh
   sleep 2 
done

