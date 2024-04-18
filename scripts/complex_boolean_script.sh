#!/bin/bash

set -m
client_num=$1
exp_duration=70
burst_time_1=10
burst_time_2=15
abs_interval=30

query_id_1=1
query_id_2=2

file_name=tmp_$(date +%Y%m%d%H%M%S)
touch $file_name

indices=big

baseline=$(echo $4 | awk -F: '{print $1}')
baseline_info=($(echo $4 | awk -F: '{$1=""; print}'))
baseline_info_len=$(echo ${baseline_info[@]} | wc -w)
if [[ "$baseline_info_len" == "0" ]]; then
	baseline_info=("/dev/null")
fi

baseline_outputs=()
if [[ $baseline_info_len > 0 ]]; then
	for i in $(seq 1 1 $client_num); do
		baseline_outputs+=($PWD/${baseline_info[$(( (i - 1) % baseline_info_len ))]})
	done
fi

curl -X GET "http://localhost:8983/solr/admin/info/logging?set=root:WARN" | tail -n 20

for i in $(seq 1 1 $client_num); do
    python microbenchmark/test_multiclient_search.py $PWD/$file_name field-1000 $PWD/${file_name}_${i} ${baseline_outputs[$i]} &
    sleep 0.1
done

sleep 50
kill -10 $(ps | grep python | awk '{print $1}')

for j in $(seq 1 1 $exp_duration); do
    if [[ "$3" != "normal" ]]; then
		if [[ "$(((j - burst_time_1) % abs_interval))" == "0" ]]; then
            echo $j
			bash -c 'start_us=$(date +"%s%6N") && curl -X GET -H "Content-Type:application/json" --data-binary @'${PWD}'/query/boolean_search_1.json "http://localhost:8983/solr/'$indices'/query?canCancel=true&queryUUID='$query_id_1'&queryID='$query_id_1'" | tail -n 20 && end_us=$(date +"%s%6N") && echo $(( end_us - start_us )) >> '${baseline_info[0]}'' &
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

sleep 120
