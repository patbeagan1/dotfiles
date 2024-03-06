#!/usr/bin/env python3

import argparse
import os
import sys
from openai import OpenAI
import datetime

def main():
    """
    A command-line tool to forward a request to OpenAI and display the results in real-time.
    
    Usage:
        python openai_cli.py --prompt "Hello, world!"
    """
    # Set up argument parser
    parser = argparse.ArgumentParser(description='Forward a request to OpenAI and display the results in real-time.')
    parser.add_argument('--prompt', help='The prompt to send to OpenAI', required=True)
    parser.add_argument('--model', help='The model to use (e.g., gpt-3.5-turbo)', default="gpt-3.5-turbo")
    parser.add_argument('--max_tokens', help='The maximum number of tokens to generate', type=int, default=100)
    args = parser.parse_args()

    # Check for API key in environment
    api_key = os.getenv('OPENAI_API_KEY')
    if not api_key:
        print("Error: OPENAI_API_KEY environment variable is not set.", file=sys.stderr)
        sys.exit(1)

    # Set API key
    OpenAI.api_key = api_key
    client = OpenAI()

    # Send request and print response
    try:
        response = client.chat.completions.create(
          model=args.model,
          messages=[
            {"role": "user", "content": args.prompt},
          ]
        )

        with open("/tmp/ai_completions.txt", mode='a') as file:
            file.write("\n" + str(datetime.datetime.now()) + "\n")
            file.write(str(response))

        print(response.choices[0].message.content)
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)

if __name__ == '__main__':
    main()

