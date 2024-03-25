#!/bin/bash

set -m
client_num=$1
exp_duration=60
burst_time_1=10
interfere_time=15

query_id_1=1
query_id_2=2

curl -X GET "http://localhost:8983/solr/admin/info/logging?set=root:WARN" | tail -n 20

curr_time=$(date +%Y%m%d%H%M%S)
file_name=tmp_$curr_time
req_file_name=req_$curr_time
touch $file_name

indices=field-1000
field_num=1000

url="http://localhost:8983/solr/$indices/query?q=*:*&rows=0&canCancel=true&queryUUID=$query_id_1&queryID=$query_id_1"
echo "&stats=true" > $req_file_name
for i in $(seq 0 1 $(($field_num - 1))); do
    echo "&stats.field=test$i" >> $req_file_name
done

for i in $(seq 1 1 $client_num); do
    python microbenchmark/test_multiclient_stat.py $PWD/$file_name $indices test0 $PWD/${file_name}_${i} &
    sleep 0.1
done

sleep 10
kill -10 $(ps | grep python | awk '{print $1}')

for j in $(seq 1 1 $exp_duration); do
    if [[ "$3" != "normal" ]]; then
        if [[ "$j" == "$burst_time_1" ]]; then
            echo $j
            curl -d POST -d @$req_file_name "$url" | tail -n 20 &
        fi
        if [[ "$j" == "$interfere_time" ]]; then
            echo $j
            curl -X GET -H "Content-Type: application/json" -d @query/boolean_search_interfere.json "http://localhost:8983/solr/big/query?canCancel=true&queryUUID=$query_id_2&queryID=$query_id_2" | grep numFound &
        fi
    fi
    kill -10 $(ps | grep python | awk '{print $1}')
    sleep 1
done

kill -2 $(ps | grep python | awk '{print $1}')

python utils/data_read_and_draw.py $PWD/$file_name $client_num $PWD/${2}_throughput
echo Latency > $PWD/${2}_latency
for i in $(seq 1 1 $client_num); do
    cat $PWD/${file_name}_${i} >> $PWD/${2}_latency
done

rm -f $req_file_name
rm -f $file_name

sleep 120
