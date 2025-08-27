#!/bin/bash

curl --verbose \
  --get \
  --data-urlencode "pid=10047" \
  --data-urlencode "issuetype=10004" \
  --data-urlencode "components=10013" \
  --data-urlencode "priority=3" \
  --data-urlencode "customfield_10133=10197" \
  --data-urlencode "assignee=ug%3A03682da5-16e1-4bbe-a74c-1c2d69a71c10" \
  --data-urlencode "summary=$1" \
  "https://alltrails.atlassian.net/secure/CreateIssueDetails!init.jspa"
