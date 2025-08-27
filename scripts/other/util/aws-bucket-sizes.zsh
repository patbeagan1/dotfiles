#!/bin/bash

# Get a list of all bucket names
buckets=$(aws s3 ls | awk '{print $3}')

# Loop through each bucket
for bucket in $buckets
do
  echo "Getting size for bucket: $bucket"
  
  # Use --summarize and --human-readable to get the total size
  aws s3 ls s3://$bucket --recursive --human-readable --summarize
  echo "------------------------------"
done
