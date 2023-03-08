#!/bin/sh -l

if [[ -z "${GITHUB_HEAD_REF}" ]]; then
  echo "Must be run on pull_request or pull_request_target triggers only!" >> $GITHUB_OUTPUT
  exit 1
fi

if [ "$GITHUB_BASE_REF" = "$2" ]; then
  echo "Check cannot run against defined main branch!" >> $GITHUB_OUTPUT
  exit 1
fi
