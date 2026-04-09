#!/bin/bash

get_authinfo () {
  local machine="$1"
  local login="$2"

  # Improved awk: finds machine and login anywhere in the line, then grabs password
  gpg -q --no-tty -d ~/.authinfo.gpg 2>/dev/null | awk -v m="$machine" -v l="$login" '
    $0 ~ "machine "m && $0 ~ "login "l {
      for (i=1; i<=NF; i++) {
        if ($i == "password") print $(i+1)
      }
    }'
}

# Fetching credentials
REFRESH_TOKEN=$(get_authinfo "imap.gmail.com" "texhewson@gmail.com")
CLIENT_ID=$(get_authinfo "oauth.gmail.com" "client_id")
CLIENT_SECRET=$(get_authinfo "oauth.gmail.com" "client_secret")

# Debug: Check if variables are empty
if [[ -z "$REFRESH_TOKEN" || -z "$CLIENT_ID" || -z "$CLIENT_SECRET" ]]; then
    echo "Error: One or more credentials could not be retrieved from GPG." >&2
    exit 1
fi

# Execute curl
# Removed -f temporarily so you can see the actual error from Google if it fails
RESPONSE=$(curl -s -X POST \
  --data "client_id=$CLIENT_ID" \
  --data "client_secret=$CLIENT_SECRET" \
  --data "refresh_token=$REFRESH_TOKEN" \
  --data "grant_type=refresh_token" \
  https://oauth2.googleapis.com/token)

#echo -n "$REFRESH_TOKEN" | cat -A
#echo "Raw Response: $RESPONSE"
# Parse output
echo "$RESPONSE" | jq -r .access_token
