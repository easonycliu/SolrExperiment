import json
import os
import signal
import time
import random
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

file_name = sys.argv[1]
indices = sys.argv[2]

throughput = 0
def signal_handler(signalnum, frame):
    global throughput
    output_file = open(file_name, 'a')
    output_file.write(str(throughput) + "\n")
    output_file.close()
    throughput = 0
    
signal.signal(signal.SIGUSR1, signal_handler)

word_creator = RandomWords()

latency_list = []
with httpx.Client(timeout=300) as client:
    while True:
        try:
            url = "{}/solr/{}/query?q=content:{}&canCancel=true".format(HOST, indices, word_creator.random_word())
            start = time.time_ns()
            response = client.post(url, headers={"Content-Type": "application/json"})
            latency_list.append(time.time_ns() - start)
            throughput += 1
        except KeyboardInterrupt:
            print("Recieve keyboard interrupt from user, break")
            latency_file = open(sys.argv[3], "w")
            for latency in latency_list[1:]:
                latency_file.write(str(latency) + "\n")
            latency_file.close()
            break
        except KeyError:
            print("A keyerror occured!")
            continue
