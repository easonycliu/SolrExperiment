import httpx
import json
import os
import time
import random
import sys
sys.path.append('')
sys.setrecursionlimit(3000)

from utils.file_operation import create_file

HOST = "http://localhost:8983"

q = {
    "query": "*:*",
    "facet": {
    }
}
nest_facet = q["facet"]
for i in range(12):
    nest_facet["range_by_create_date_{}".format(i)] = {
        "type": "range",
        "field": "create_date",
        "start": "2010-1-1T0:0:0Z",
        "end": "NOW",
        "gap": "+{}DAYS".format(random.randint(56, 112)),
        "facet": {}
    }
    nest_facet = nest_facet["range_by_create_date_{}".format(i)]["facet"]

nest_facet["stats_char_num"] = {
    "type": "func",
    "func": "avg(content_char_num)"
}

file_name = "nest_facet_2.json"
f = open(os.path.join(os.getcwd(), "query", file_name), "w")
json.dump(q, f, indent=4)
f.close()
    