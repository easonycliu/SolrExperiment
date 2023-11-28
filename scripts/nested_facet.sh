#!/bin/bash

set -m
client_num=4
exp_duration=60
burst_time_1=10
burst_time_2=15

cancel_time=15

query_id_1=6
query_id_2=7

file_name=tmp_$(date +%Y%m%d%H%M%S)
touch file_name

indices=big

for i in $(seq 1 1 $client_num); do
    python microbenchmark/test_multiclient_search.py $PWD/$file_name $indices &
    sleep 0.1
done

sleep 50

for j in $(seq 1 1 $exp_duration); do
    if [[ "$j" == "$burst_time_1" ]]; then
        echo $j
        curl -X GET -H "Content-Type:application/json" --data-binary @${PWD}/query/nest_facet_1.json "http://localhost:8983/solr/$indices/query?canCancel=true&queryUUID=$query_id_1&queryID=$query_id_1" | tail -n 10 &
    fi
    if [[ "$j" == "$burst_time_2" ]]; then
        echo $j
        curl -X GET -H "Content-Type:application/json" --data-binary @${PWD}/query/nest_facet_2.json "http://localhost:8983/solr/$indices/query?canCancel=true&queryUUID=$query_id_2&queryID=$query_id_2" | tail -n 10 &
    fi
    # if [[ "$j" == "$cancel_time" ]]; then
    #     echo $j
    #     curl -X GET "http://localhost:8983/solr/$indices/tasks/list"
    #     echo "cancel task uuid $query_id_1"
    #     curl -X GET "http://localhost:8983/solr/$indices/tasks/cancel?queryUUID=$query_id_1"
    # fi
    kill -10 $(ps | grep python | awk '{print $1}')
    sleep 1
done

kill -2 $(ps | grep python | awk '{print $1}')

python utils/data_read_and_draw.py $PWD/$file_name $client_num

rm -f $file_name
