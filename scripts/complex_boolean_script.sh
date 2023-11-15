set -m
client_num=2
exp_duration=60
burst_time=10

cancel_time=15

query_id=9

file_name=tmp_$(date +%Y%m%d%H%M%S)
touch file_name

indices=big

for i in $(seq 1 1 $client_num); do
    python microbenchmark/test_multiclient_search.py $PWD/$file_name $indices &
    sleep 0.1
done

sleep 50

for j in $(seq 1 1 $exp_duration); do
    if [[ "$j" == "$burst_time" ]]; then
        echo $j
        curl -X GET -H "Content-Type: application/json" -d @query/boolean_search.json "http://localhost:8983/solr/$indices/query?canCancel=true&queryUUID=$query_id&queryID=$query_id" | grep numFound &
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

rm -f $file_name
