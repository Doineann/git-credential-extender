#!/bin/bash
# git-credential-extender.sh
#
# Usage:
#   1. Save this script somewhere on your system, e.g.:
#         /path/to/git-credential-key-extender.sh
#   2. Make sure it is executable:
#         chmod +x /path/to/git-credential-key-extender.sh
#   3. Configure Git:
#         git config --global credential.helper /path/to/git-credential-key-extender.sh
#   4. Perform Git operations (e.g., clone, push, pull) and verify that credentials are
#      stored/retrieved on a per-repository basis by using the full repository URL.
#

declare -A creds
while IFS='=' read -r key value || [ -n "$key" ]; do
  [[ -z "$key" ]] && break
  creds["$key"]="$value"
done

# Extend "path" if it is missing or equals "/"
if [[ -z "${creds[path]}" || "${creds[path]}" == "/" ]]; then
  if [[ -n "$GIT_DIR" ]]; then
    remote_url=$(git --git-dir="$GIT_DIR" config --get remote.origin.url)
    if [[ -n "$remote_url" ]]; then
      prefix="${creds[protocol]}://${creds[host]}"
      if [[ "$remote_url" == "$prefix"* ]]; then
        path_extension="${remote_url#$prefix/}"
        creds[path]="$path_extension"
        echo "Extending credential key to: ${creds[protocol]}://${creds[host]}/${creds[path]}" >&2
      fi
    fi
  fi
fi

# Output the updated key/value pairs
for field in protocol host path action username password; do
  if [[ -n "${creds[$field]}" ]]; then
    printf "%s=%s\n" "$field" "${creds[$field]}"
  fi
done
