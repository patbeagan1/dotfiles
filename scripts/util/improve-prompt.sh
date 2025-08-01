#!/bin/zsh

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;37m'
BOLD='\033[1m'
UNDERLINE='\033[4m'
RESET='\033[0m'

# Check if the number of iterations and the prompt are provided
if [[ -z "$1" ]] || [[ -z "$2" ]]; then
  echo -e "${RED}${BOLD}Error:${RESET} Missing required arguments"
  echo -e "${YELLOW}Usage:${RESET} $0 <number_of_iterations> \"<prompt_to_improve>\""
  echo -e "${GRAY}Example:${RESET} $0 3 \"Write a story about a cat\""
  exit 1
fi

iterations=$1
prompt_to_improve=$2

# Validate iterations is a positive integer
if ! [[ "$iterations" =~ ^[1-9][0-9]*$ ]]; then
  echo -e "${RED}${BOLD}Error:${RESET} Number of iterations must be a positive integer"
  exit 1
fi

# The system prompt tells Ollama how to behave.
system_prompt="You are an expert prompt engineer. Your task is to take a given prompt and improve it for better results with large language models. You will be given the original prompt, and the latest prompt. The latest prompt should be improved while adhering to the intent of the original prompt. The improved prompt should be more detailed, specific, and provide clearer instructions. Your response should only contain the improved prompt, with no additional conversational text."

echo -e "${CYAN}${BOLD}🤖 Prompt Improvement Tool${RESET}"
echo -e "${GRAY}================================${RESET}"
echo -e "${YELLOW}${BOLD}Original Prompt:${RESET}"
echo -e "${WHITE}$prompt_to_improve${RESET}"
echo -e "${GRAY}================================${RESET}"
echo ""

# Loop to iteratively improve the prompt
current_prompt=$prompt_to_improve
for i in $(seq 1 $iterations); do
  echo -e "${BLUE}${BOLD}🔄 Iteration $i/$iterations${RESET}"
  echo -e "${GRAY}Processing...${RESET}"
  
  # Use Ollama to improve the current prompt
  request="$system_prompt

Original Prompt: \"\"\"$prompt_to_improve\"\"\"

Latest Prompt: \"\"\"$current_prompt\"\"\""
  
  # Show what's being sent to the model (in plaintext)
  echo -e "${MAGENTA}${BOLD}📤 Request to Model:${RESET}"
  echo -e "${GRAY}$request${RESET}"
  echo ""

  improved_prompt=$(ollama run "gemma" "$request")
  
  # Print the improved prompt with clear formatting
  echo -e "${GREEN}${BOLD}📥 Improved Prompt:${RESET}"
  echo -e "${WHITE}$improved_prompt${RESET}"
  echo -e "${GRAY}================================${RESET}"
  echo ""
  
  current_prompt=$improved_prompt
done

echo -e "${GREEN}${BOLD}✅ Final Result${RESET}"
echo -e "${GRAY}================================${RESET}"
echo -e "${WHITE}${BOLD}Final improved prompt after $iterations iterations:${RESET}"
echo -e "${WHITE}$current_prompt${RESET}"
echo -e "${GRAY}================================${RESET}"
