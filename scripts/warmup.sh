#!/bin/bash

set -m
client_num=5
exp_duration=30
indices=big

curl -X GET "http://localhost:8983/solr/admin/info/logging?set=root:WARN" | tail -n 20

for i in $(seq 1 1 $client_num); do
    python microbenchmark/test_multiclient_search.py /dev/null $indices /dev/null &
    sleep 0.1
done

sleep 10

for j in $(seq 1 1 $exp_duration); do
    kill -10 $(ps | grep python | awk '{print $1}')
    sleep 1
done

kill -2 $(ps | grep python | awk '{print $1}')
