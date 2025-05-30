#!/bin/zsh

# Usage: ./double_revert.sh <commit_hash>

# Check for commit hash
if [ -z "$1" ]; then
  echo "Usage: $0 <commit_hash>"
  exit 1
fi

COMMIT_HASH=$1

# Revert the original commit
echo "Reverting commit: $COMMIT_HASH"
git revert --no-edit $COMMIT_HASH
if [ $? -ne 0 ]; then
  echo "Failed to revert $COMMIT_HASH"
  exit 1
fi

# Get the hash of the revert commit (the latest commit now)
REVERT_COMMIT=$(git rev-parse HEAD)

# Revert the revert commit
echo "Reverting the revert commit: $REVERT_COMMIT"
git revert --no-edit $REVERT_COMMIT
if [ $? -ne 0 ]; then
  echo "Failed to revert the revert commit $REVERT_COMMIT"
  exit 1
fi

echo "Done. Two commits created, no net changes."

