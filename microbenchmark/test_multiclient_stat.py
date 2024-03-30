import json
import os
import signal
import time
import random
import httpx
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
import sys
sys.path.append('')

from utils.file_operation import create_file

port = 8983
HOST = "http://localhost:{}".format(port)

file_name = sys.argv[1]
indices = sys.argv[2]
field = sys.argv[3]

log_for_parties = None
if len(sys.argv) > 5:
    log_for_parties = sys.argv[5]

throughput = 0
def signal_handler(signalnum, frame):
    global throughput
    output_file = open(file_name, 'a')
    output_file.write(str(throughput) + "\n")
    output_file.close()
    throughput = 0
    
signal.signal(signal.SIGUSR1, signal_handler)

url = "{}/solr/{}/query?q=*:*&rows=0&stats=true&stats.field={}".format(HOST, indices, field)

latency_list = []
with httpx.Client(timeout=300) as client:
    while True:
        try:
            start = time.time_ns()
            start_us = int(start / 1000)
            response = client.post(url, headers={"Content-Type": "application/json"})
            end = time.time_ns()
            end_us = int(end / 1000)
            latency_list.append(end - start)
            if log_for_parties is not None:
                with open(log_for_parties, "a") as f:
                    f.write("{}".format(end_us - start_us))
            throughput += 1
        except KeyboardInterrupt:
            print("Recieve keyboard interrupt from user, break")
            latency_file = open(sys.argv[4], "w")
            for latency in latency_list[1:]:
                latency_file.write(str(latency) + "\n")
            latency_file.close()
            break
        except KeyError:
            print("A keyerror occured!")
            continue
