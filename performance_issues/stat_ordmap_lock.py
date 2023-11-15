import json
import httpx
import random
import string
import os
import sys

port = 8983
HOST = "http://localhost:{}".format(port)
field_number = 10000
name = "field-{}".format(field_number)

def create_index_with_many_fields():
    field_info = {
        "add-field": [
        ]
    }

    with httpx.Client(timeout=300) as client:
        response = client.post("{}/solr/admin/collections?action=CREATE&name={}&numShards=1&replicationFactor=1".format(HOST, name), headers={"Content-Type": "application/json"})
        for i in range(10000):
            field_info["add-field"].append({"name": "test{}".format(i), "type": "string", "multiValued": "true"})
        response = client.post("{}/api/collections/{}/schema".format(HOST, name), content=json.dumps(field_info) + "\n", headers={"Content-Type": "application/json"})
        
def create_document_in_index(count):
    with httpx.Client(timeout=300) as client:
        for _ in range(count):
            data = {"test{}".format(i): "".join(random.choices(string.ascii_letters + string.digits, k=random.randint(100, 1000))) for i in range(field_number)}
            response = client.post("{}/api/collections/{}/update?commit={}".format(HOST, name, "true"),
                                    content=json.dumps(data) + "\n",
                                    headers={"Content-Type": "application/json"})

def query_stats_in_index(count):
    query = {
        "query": "*:*",
        "params": {
            "stats": "true",
            "stats.field": ["test{}".format(i) for i in range(count)]
        }
    }
    file_name = "stat_fields.json"
    f = open(os.path.join(os.getcwd(), "query", file_name), "w")
    json.dump(query, f, indent=4)
    f.close()

if __name__ == "__main__":
    mode = sys.argv[1]
    if mode == "index":
        create_index_with_many_fields()
    elif mode == "document":
        create_document_in_index(1000)
    elif mode == "query":
        query_stats_in_index(1000)
