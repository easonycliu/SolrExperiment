#!/usr/bin/python3

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

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: ./complex_boolean_operations.py NUM_OPS OUTPUT_NAME")
        exit()
        
    operation_num = int(sys.argv[1])
    file_name = sys.argv[2]
    port = 8983
    HOST = "http://localhost:{}".format(port)

    query = {
        "query": {
            "bool": {
                "should": [
                ],
            }
        }
    }

    word_creator = RandomWords()
    for _ in range(operation_num):
        query["query"]["bool"]["should"].append({"lucene": {"df": "content", "query": word_creator.random_word()}})

    f = open(os.path.join(os.getcwd(), "query", file_name), "w")
    json.dump(query, f, indent=4)
    f.close()
