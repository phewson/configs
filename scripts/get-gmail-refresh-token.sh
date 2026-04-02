#!/bin/bash
# Use the refresh token from GPG to get a fresh access token
get_authinfo () {
  local machine="$1"
  local login="$2"

  gpg -q --no-tty -d ~/.authinfo.gpg \
    | awk -v m="$machine" -v l="$login" '
        $1=="machine" && $2==m {
          for (i=1;i<=NF;i++) {
            if ($i=="login" && $(i+1)==l) {
              for (j=1;j<=NF;j++) {
                if ($j=="password") {
                  print $(j+1)
                }
              }
            }
          }
        }
      '
}

REFRESH_TOKEN=$(get_authinfo "imap.gmail.com" "texhewson@gmail.com")
CLIENT_ID=$(get_authinfo "oauth.gmail.com" "client_id")
CLIENT_SECRET=$(get_authinfo "oauth.gmail.com" "client_secret")

curl -s -f -X POST \
  --data "client_id=$CLIENT_ID" \
  --data "client_secret=$CLIENT_SECRET" \
  --data "refresh_token=$REFRESH_TOKEN" \
  --data "grant_type=refresh_token" \
  https://oauth2.googleapis.com/token | /usr/bin/jq -r .access_token
