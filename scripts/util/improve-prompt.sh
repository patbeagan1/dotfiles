#!/bin/zsh

# Check if the number of iterations and the prompt are provided
if [[ -z "$1" ]] || [[ -z "$2" ]]; then
  echo "Usage: $0 <number_of_iterations> \"<prompt_to_improve>\""
  exit 1
fi

iterations=$1
prompt_to_improve=$2

# The system prompt tells Ollama how to behave.
system_prompt="You are an expert prompt engineer. Your task is to take a given prompt and improve it for better results with large language models. You will be given the original prompt, and the latest prompt. The latest prompt should be improved while adhering to the intent of the original prompt. The improved prompt should be more detailed, specific, and provide clearer instructions. Your response should only contain the improved prompt, with no additional conversational text."

echo "Initial prompt: $prompt_to_improve"
echo "---"

# Loop to iteratively improve the prompt


current_prompt=$prompt_to_improve
for i in $(seq 1 $iterations); do
  # Use Ollama to improve the current prompt
  request="$system_prompt

Original Prompt: \"\"\"$prompt_to_improve\"\"\"

Latest Prompt: \"\"\"$current_prompt\"\"\""
  echo "$request"

  improved_prompt=$(ollama run "gemma" "$request")
  
  # Print the new prompt and update the current_prompt variable for the next iteration
  echo "Iteration $i:"
  echo "$improved_prompt"
  echo "---"
  current_prompt=$improved_prompt
done

echo "Final improved prompt after $iterations iterations:"
echo "$current_prompt"
