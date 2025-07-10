#!/bin/zsh

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
for file in $(echo "$changed_files"); do
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

# 4. Construct and run the gradlew command
gradle_test_command="./gradlew --configure-on-demand "

for module in "${(@k)changed_modules}"; do
  gradle_test_command+="${module}:testAlphaDebugUnitTest ${module}:detekt "
done

echo "Running tests for the following modules:"
for module in "${(@k)changed_modules}"; do
  echo "- $module"
done

echo
echo "Executing command: $gradle_test_command"
echo

eval "$gradle_test_command"
