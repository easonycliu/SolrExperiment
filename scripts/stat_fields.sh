#!/bin/bash

set -m
client_num=8
exp_duration=60
burst_time_1=10

cancel_time=15

query_id=6

curr_time=$(date +%Y%m%d%H%M%S)
file_name=tmp_$curr_time
req_file_name=req_$curr_time
touch file_name

indices=field-10000
field_num=10000

url="http://localhost:8983/solr/$indices/query?q=*:*&rows=0&canCancel=true&queryUUID=$query_id&queryID=$query_id"
echo "&stats=true" > $req_file_name
for i in $(seq 0 1 $(($field_num - 1))); do
    echo "&stats.field=test$i" >> $req_file_name
done

for i in $(seq 1 1 $client_num); do
    python microbenchmark/test_multiclient_stat.py $PWD/$file_name $indices test0 &
    sleep 0.1
done

sleep 50

for j in $(seq 1 1 $exp_duration); do
    if [[ "$j" == "$burst_time_1" ]]; then
        echo $j
        curl -d POST -d @$req_file_name "$url" | tail -n 10 &
    fi
    # if [[ "$j" == "$cancel_time" ]]; then
    #     echo $j
    #     curl -X GET "http://localhost:8983/solr/$indices/tasks/list"
    #     echo "cancel task uuid $query_id"
    #     curl -X GET "http://localhost:8983/solr/$indices/tasks/cancel?queryUUID=$query_id"
    # fi
    kill -10 $(ps | grep python | awk '{print $1}')
    sleep 1
done

kill -2 $(ps | grep python | awk '{print $1}')

python utils/data_read_and_draw.py $PWD/$file_name $client_num

rm -f $req_file_name
rm -f $file_name
