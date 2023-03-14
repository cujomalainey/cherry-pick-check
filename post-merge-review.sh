#!/bin/bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'
REGEX_REF='^\(cherry picked from commit ([a-f0-9]{40})\)$'

do_reference_check() {
  if ! [[ $(git log --format=%B "$line^!" | grep -E "$REGEX_REF") =~ $REGEX_REF ]]; then
    echo -e "${RED}FAIL${NC}" >> "$GITHUB_OUTPUT"
    dirty=1
    echo "  Cannot find reference in commit message" >> "$GITHUB_OUTPUT"
    echo "  Hint: use -x with git cherry-pick" >> "$GITHUB_OUTPUT"
    return;
  fi

  if ! eval "$(git branch --contains "${BASH_REMATCH[1]}" "$check_branch" 2>/dev/null)"; then
    echo -e "${RED}FAIL${NC}" >> "$GITHUB_OUTPUT"
    dirty=1
    echo "  Cannot find ${BASH_REMATCH[1]} from $line in $check_branch" >> "$GITHUB_OUTPUT"
    return;
  fi
  echo -e "${GREEN}OK${NC}" >> "$GITHUB_OUTPUT"
}

do_subject_check() {
  summary=$(git log --format=%s "$line^!")
  if (($(git log --format=%s "$check_branch" | grep -Fxc "$summary") == 0)); then
    echo -e "${RED}FAIL${NC}" >> "$GITHUB_OUTPUT"
    dirty=1
    echo "  Cannot find $summary in $check_branch" >> "$GITHUB_OUTPUT"
    return;
  fi
  echo -e "${GREEN}OK${NC}" >> "$GITHUB_OUTPUT"
}

main() {
  if [[ -z "${GITHUB_HEAD_REF}" ]]; then
    echo "Must be run on pull_request or pull_request_target triggers only!" >> "$GITHUB_OUTPUT"
    exit 1
  fi

  if [ "$GITHUB_BASE_REF" = "$2" ]; then
    echo "Check cannot run against defined main branch!" >> "$GITHUB_OUTPUT"
    exit 1
  fi

  commit_range="$(git merge-base "$GITHUB_BASE_REF" "$GITHUB_HEAD_REF")..$GITHUB_HEAD_REF"
  echo "Checking range $commit_range which contains $(git log --oneline "$commit_range" | wc -l) commits" >> "$GITHUB_OUTPUT"
  commits=$(git log --format=format:%H "$commit_range")

  dirty=0
  check_branch=$2

  for line in $commits; do
    echo -n "$(git log --format=format:"Checking %h %s..." "$line^!")" >> "$GITHUB_OUTPUT"
    if [ "$1" = "true" ]; then
      do_reference_check
    else
      do_subject_check
    fi
  done

  exit $dirty
}

main "$@"
