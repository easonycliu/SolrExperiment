HOST=http://localhost:8983

collections=$1
if [ -z "$collections" ]; then
    collections=$(curl -s -X GET $HOST/api/collections | awk -F '[\[\]]' '{print $2}' | sed "s/\"//g")
fi
collections=$(echo "$collections" | tr "," " ")
collections=($collections)

echo -e "indice\t\tcount"
for collection in ${collections[*]}; do
    doc_count=$(curl -s -X GET "http://localhost:8983/solr/admin/collections?action=COLSTATUS&collection=$collection&fieldInfo=true&sizeInfo=true" | grep totalMaxDoc | awk -F '[:,]' '{print $2}')
    echo -e "$collection\t\t$doc_count"
done
