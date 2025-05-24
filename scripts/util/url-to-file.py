#!/usr/bin/env python3

import sys
import re
import os

def sanitize_filename(url: str) -> str:
    # Remove the scheme (http, https) and replace non-filename characters with '__'
    sanitized = re.sub(r'[^a-zA-Z0-9.-]', '__', url.replace('https://', '').replace('http://', ''))
    return sanitized + ".html"

def generate_meta_redirect(url: str):
    meta_tag = f'<meta http-equiv="Refresh" content="0; url=\'{url}\'" />\n'
    filename = sanitize_filename(url)
    
    with open(filename, 'w') as f:
        f.write(meta_tag)
    
    print(f"Meta redirect written to {filename}")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python3 script.py <URL>")
        sys.exit(1)
    
    url = sys.argv[1]
    generate_meta_redirect(url)

