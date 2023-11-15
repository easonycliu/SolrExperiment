import json
import httpx

port = 8983
HOST = "http://localhost:{}".format(port)

index_info = {
    "name": "",
    "numShards": 1,
    "replicationFactor": 1
}

field_info = {
    "add-field": [
            {"name": "title", "type": "text_general", "multiValued": "false"},
            {"name": "content", "type": "text_general", "multiValued": "false"},
            {"name": "url", "type": "string", "multiValued": "true"},
            {"name": "content_char_num", "type": "pint"},
            {"name": "create_date", "type": "pdate"}
    ]
}

def create_index(name):
    index_info["name"] = name
    with httpx.Client(timeout=300) as client:
        response = client.post("{}/solr/admin/collections?action=CREATE&name={}&numShards=1&replicationFactor=1".format(HOST, name), headers={"Content-Type": "application/json"})
        print(response.json())
        response = client.post("{}/api/collections/{}/schema".format(HOST, name), content=json.dumps(field_info) + "\n", headers={"Content-Type": "application/json"})
        print(response.json())
        
def index_exists(name):
    with httpx.Client(timeout=300) as client:
        response = client.get("{}/api/collections".format(HOST))
        return name in response.json()["collections"]
        