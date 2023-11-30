#!/bin/bash

set -m
client_num=$1
exp_duration=60
burst_time_1=10
burst_time_2=15

query_id_1=1
query_id_2=2

file_name=tmp_$(date +%Y%m%d%H%M%S)
touch $file_name

indices=big

curl -X GET "http://localhost:8983/solr/admin/info/logging?set=root:WARN" | tail -n 20

for i in $(seq 1 1 $client_num); do
    python microbenchmark/test_multiclient_search.py $PWD/$file_name $indices $PWD/${file_name}_${i} &
    sleep 0.1
done

sleep 50
kill -10 $(ps | grep python | awk '{print $1}')

for j in $(seq 1 1 $exp_duration); do
    if [[ "$3" != "normal" ]]; then
        if [[ "$j" == "$burst_time_1" ]]; then
            echo $j
            curl -X GET -H "Content-Type: application/json" -d @query/boolean_search_2.json "http://localhost:8983/solr/$indices/query?canCancel=true&queryUUID=$query_id_1&queryID=$query_id_1" | grep numFound &
        fi
        if [[ "$j" == "$burst_time_2" ]]; then
            echo $j
            # curl -X GET -H "Content-Type: application/json" -d @query/boolean_search_2.json "http://localhost:8983/solr/$indices/query?canCancel=true&queryUUID=$query_id_2&queryID=$query_id_2" | grep numFound &
        fi
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

python utils/data_read_and_draw.py $PWD/$file_name $client_num $PWD/${2}_throughput
echo Latency > $PWD/${2}_latency
for i in $(seq 1 1 $client_num); do
    cat $PWD/${file_name}_${i} >> $PWD/${2}_latency
done

rm -f ${file_name}*
