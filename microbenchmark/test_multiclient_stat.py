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

throughput = 0
def signal_handler(signalnum, frame):
    global throughput
    output_file = open(file_name, 'a')
    output_file.write(str(throughput) + "\n")
    output_file.close()
    throughput = 0
    
signal.signal(signal.SIGUSR1, signal_handler)

url = "{}/solr/{}/query?q=*:*&rows=0&stats=true&stats.field={}".format(HOST, indices, field)

with httpx.Client(timeout=300) as client:
    while True:
        try:
            response = client.post(url, headers={"Content-Type": "application/json"})
            throughput += 1
        except KeyboardInterrupt:
            print("Recieve keyboard interrupt from user, break")
            break
        except KeyError:
            print("A keyerror occured!")
            continue
