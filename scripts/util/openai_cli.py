#!/usr/bin/env python3

import argparse
import openai
import os
import sys

def main():
    """
    A command-line tool to forward a request to OpenAI and display the results in real-time.
    
    Usage:
        python openai_cli.py --prompt "Hello, world!"
    """
    # Set up argument parser
    parser = argparse.ArgumentParser(description='Forward a request to OpenAI and display the results in real-time.')
    parser.add_argument('--prompt', help='The prompt to send to OpenAI', required=True)
    parser.add_argument('--model', help='The model to use (e.g., text-davinci-003)', default='gpt-3.5-turbo-0125')
    parser.add_argument('--max_tokens', help='The maximum number of tokens to generate', type=int, default=100)
    args = parser.parse_args()

    # Check for API key in environment
    api_key = os.getenv('OPENAI_API_KEY')
    if not api_key:
        print("Error: OPENAI_API_KEY environment variable is not set.", file=sys.stderr)
        sys.exit(1)

    # Set API key
    openai.api_key = api_key

    # Send request and print response
    try:
        response = openai.Completion.create(
            model=args.model,
            prompt=args.prompt,
            max_tokens=args.max_tokens,
            stream=False
        )

        for message in response:
            if 'data' in message and 'choices' in message['data']:
                choices = message['data']['choices']
                if choices:
                    print(choices[0]['text'], end='', flush=True)
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)

if __name__ == '__main__':
    main()

