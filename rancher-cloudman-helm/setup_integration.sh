#!/bin/sh

# Abort if any command fails
set -e

# Reset admin password
RANDOM_PWD=$(kubectl -n cattle-system exec \
             $(kubectl -n cattle-system get pods \
             -l app=rancher | grep '1/1' | head -1 | awk '{ print $1 }') \
             -- reset-password | tail -n 1)

# Authenticate to get an auth token
LOGIN_TOKEN=`curl -s -k --data-binary '{"username":"admin","password":"'$RANDOM_PWD'","ttl":60000}' -H "Content-Type: application/json" https://rancher.local/v3-public/localProviders/local?action=login | jq -r .token`

# Set admin password
curl --insecure --silent "https://$RANCHER_HOSTNAME/v3/users?action=changepassword" -H 'Content-Type: application/json' -H "Authorization: Bearer $LOGIN_TOKEN" --data-binary '{"currentPassword":"'$RANDOM_PWD'", "newPassword":"'$PASSWORD'"}'
