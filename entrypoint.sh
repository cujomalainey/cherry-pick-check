#!/bin/bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'
REGEX_REF='^\(cherry picked from commit ([a-f0-9]{40})\)$'

die()
{
  printf '%s ERROR: ' "$0" >> "$GITHUB_OUTPUT"
  # We want die() to be usable exactly like printf
  # shellcheck disable=SC2059
  printf "$@" >> "$GITHUB_OUTPUT"
  exit 1
}

do_reference_check() {
  local commit=$1
  local check_branch=$2
  [[ $(git log --format=%B "$commit^!" | grep -E "$REGEX_REF") =~ $REGEX_REF ]] || {
    echo -e "${RED}FAIL${NC}" >> "$GITHUB_OUTPUT"
    printf "  Cannot find reference in commit messag\n  Hint: use -x with git cherry-pick\n" >> "$GITHUB_OUTPUT"
    echo 1;
    return;
  }

  # check reference sha actually exists in parent
  test -z $(git branch --contains "${BASH_REMATCH[1]}" "$check_branch" 2>/dev/null) || {
    echo -e "${RED}FAIL${NC}" >> "$GITHUB_OUTPUT"
    echo "  Cannot find ${BASH_REMATCH[1]} from $commit in $check_branch" >> "$GITHUB_OUTPUT"
    echo 1;
    return;
  }
  echo -e "${GREEN}OK${NC}" >> "$GITHUB_OUTPUT"
  echo 0;
}

do_subject_check() {
  local commit=$1
  local check_branch=$2
  summary=$(git log --format=%s "$commit^!")
  if (($(git log --format=%s "$check_branch" | grep -Fxc "$summary") == 0)); then
    echo -e "${RED}FAIL${NC}" >> "$GITHUB_OUTPUT"
    echo "  Cannot find $summary in $check_branch" >> "$GITHUB_OUTPUT"
    echo 1;
    return;
  fi
  echo -e "${GREEN}OK${NC}" >> "$GITHUB_OUTPUT"
  echo 0;
}

main() {
  local DIRTY_PR=0
  local check_branch=$2
  local ret=0
  local ref_check=$1

  [[ -n "${GITHUB_HEAD_REF}" ]] || die "Must be run on pull_request or pull_request_target triggers only!"

  [ ! "$GITHUB_BASE_REF" = "$2" ] || die "Check cannot run against defined main branch!"

  commit_range="$GITHUB_BASE_REF".."$GITHUB_HEAD_REF"
  echo "Checking range $commit_range which contains $(git log --oneline "$commit_range" | wc -l) commits" >> "$GITHUB_OUTPUT"

  git log --format=format:%H "$commit_range" | while read -r line; do
    echo -n "$(git log --format=format:"Checking %h %s..." "$line^!")" >> "$GITHUB_OUTPUT"
    if [ "$ref_check" = "true" ]; then
      ret=$( do_reference_check "$line" "$check_branch" )
    else
      ret=$( do_subject_check "$line" "$check_branch" )
    fi
    DIRTY_PR=$(( ret + DIRTY_PR ))
  done

  [ $DIRTY_PR = 0 ] || exit 1;
}

main "$@"
