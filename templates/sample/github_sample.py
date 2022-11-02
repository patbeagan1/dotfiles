#!/usr/bin/env python3

import requests
from pprint import pprint

# github username
username = "patbeagan1"
# url to request
url = f"https://api.github.com/users/{username}"
# make the request and return the json
user_data = requests.get(url).json()
# pretty print JSON data
pprint(user_data)
