import httpx
import json
import sys
sys.path.append('')

from utils.file_operation import create_file
from create_rubbish_in_es import create_rubbishes, create_a_rubbish
from create_index import create_index, index_exists

if __name__ == "__main__":
    f = create_file("response", "w")
    client = httpx.Client()
    HOST = "http://localhost:8983"
    
    indexes = ["big"]
    for index in indexes:
        if not index_exists(index):
            create_index(index)
        create_rubbishes(f, client, HOST, index, create_rubbish_num=10000, refresh="false", creator=create_a_rubbish)
    
    client.close()
    f.close()
    