#!/bin/zsh

show_help() {
  cat <<EOF
Usage: $(basename "$0") [options]

Runs tests and/or detekt for modules changed compared to origin/develop.

Options:
  --test         Run unit tests for changed modules
  --detekt       Run detekt for changed modules
  -h, --help     Show this help message

If no options are provided, nothing will be run.
EOF
}

run_tests=0
run_detekt=0

# Parse CLI flags (additive)
for arg in "$@"; do
  case "$arg" in
    --test)
      run_tests=1
      ;;
    --detekt)
      run_detekt=1
      ;;
    -h|--help)
      show_help
      exit 0
      ;;
    *)
      echo "Unknown option: $arg"
      show_help
      exit 1
      ;;
  esac
done

if [[ $run_tests -eq 0 && $run_detekt -eq 0 ]]; then
  echo "Nothing to do: please specify --test and/or --detekt."
  show_help
  exit 0
fi

# Ensure you are in the root directory of your git repository
if [ ! -d ".git" ]; then
  echo "Error: Please run this script from the root of your git repository."
  exit 1
fi

# 1. Get a list of changed files compared to the develop branch
changed_files=$(git diff --name-only origin/develop)

if [ -z "$changed_files" ]; then
  echo "No changes detected compared to the develop branch."
  exit 0
fi

# An associative array to store the unique module paths
typeset -A changed_modules

# 2. For each changed file, find the corresponding module
for file in ${(f)changed_files}; do
  dir=$(dirname "$file")
  # Traverse up the directory tree to find the module root
  while [ "$dir" != "." ]; do
    if [ -f "$dir/build.gradle.kts" ] || [ -f "$dir/build.gradle" ]; then
      # Convert the directory path to a Gradle module path
      module_path=":${dir//\//:}"
      changed_modules[$module_path]=1
      break
    fi
    dir=$(dirname "$dir")
  done
done

# 3. Check if any modules were identified
if [ ${#changed_modules[@]} -eq 0 ]; then
  echo "No changed modules with a build.gradle[.kts] file found."
  exit 0
fi

# 4. Construct the gradlew command
gradle_cmd="./gradlew --configure-on-demand"
gradle_tasks=()

for module in "${(@k)changed_modules}"; do
  if [[ $run_tests -eq 1 ]]; then
    gradle_tasks+=("${module}:testAlphaDebugUnitTest")
  fi
  if [[ $run_detekt -eq 1 ]]; then
    gradle_tasks+=("${module}:detekt")
  fi
done

if [[ ${#gradle_tasks[@]} -eq 0 ]]; then
  echo "No tasks to run for the selected modules."
  exit 0
fi

echo "Running for the following modules:"
for module in "${(@k)changed_modules}"; do
  echo "- $module"
done

echo
echo "Executing command: $gradle_cmd ${gradle_tasks[*]}"
echo

eval "$gradle_cmd ${gradle_tasks[*]}"
