#!/usr/bin/env zsh

# Check if the API key is set
if [[ -z "$OPENAI_API_KEY" ]]; then
    echo "Error: OPENAI_API_KEY environment variable is not set." >&2
    exit 1
fi

# Default values
MODEL="text-davinci-003"
MAX_TOKENS=100

# Usage message
usage() {
    echo "Usage: $0 -p <prompt> [-m <model>] [-t <max_tokens>]" >&2
}

# Parse command-line options
while getopts ":p:m:t:" opt; do
    case "$opt" in
        p) PROMPT=$OPTARG ;;
        m) MODEL=$OPTARG ;;
        t) MAX_TOKENS=$OPTARG ;;
        \?) echo "Invalid option: -$OPTARG" >&2
            usage
            exit 1 ;;
        :)  echo "Option -$OPTARG requires an argument." >&2
            usage
            exit 1 ;;
    esac
done

# Check if prompt is provided
if [[ -z "$PROMPT" ]]; then
    echo "Error: Prompt is required." >&2
    usage
    exit 1
fi

# Send request to OpenAI API
RESPONSE=$(curl -s -X POST "https://api.openai.com/v1/engines/$MODEL/completions" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -d "{\"prompt\": \"$PROMPT\", \"max_tokens\": $MAX_TOKENS}")

# Check for curl errors
if [[ $? -ne 0 ]]; then
    echo "Error: Failed to connect to OpenAI API." >&2
    exit 1
fi

# Extract and print the response text
echo $RESPONSE | jq -r '.choices[0].text' || {
    echo "Error: Failed to parse response." >&2
    exit 1
}

