import json
import os
import signal
import time
import httpx
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
from random_words import RandomWords
import sys
sys.path.append('')

from utils.file_operation import create_file

port = 8983
HOST = "http://localhost:{}".format(port)
indices = "news"
for i in range(50):
    indices += ",test{}".format(i)

query = {
    "query": {
        "bool": {
            "should": [
            ],
            "must": [
                
            ],
            "must_not": [
                
            ]
        }
    }
}

word_creator = RandomWords()
for _ in range(100000):
    query["query"]["bool"]["should"].append({"lucene": {"df": "content", "query": word_creator.random_word()}})

file_name = "boolean_search.json"
f = open(os.path.join(os.getcwd(), "query", file_name), "w")
json.dump(query, f, indent=4)
f.close()
