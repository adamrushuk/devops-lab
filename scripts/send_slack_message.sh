#! /usr/bin/env bash
#
# Posts a message to a Slack channel
#
# Usage:
#   export SLACK_CHANNEL_ID="<MY_SLACK_CHANNEL_ID>"
#   export SLACK_BOT_TOKEN="<MY_SLACK_BOT_TOKEN>"
#   ./send_slack_message.sh "This is a test message"
#
# Configure Bot User OAuth Access Token here:
# https://api.slack.com/apps/<APP_ID>/oauth?

# Ensure strict mode and predictable pipeline failure
set -euo pipefail
trap "echo 'error: Script failed: see failed command above'" ERR

# Check vars
if test -z "$SLACK_CHANNEL_ID"; then
    echo "SLACK_CHANNEL_ID variable is missing, please set and try again."
    exit 1
fi

if test -z "$SLACK_BOT_TOKEN"; then
    echo "SLACK_BOT_TOKEN variable is missing, please set and try again."
    exit 1
fi

if test -z "$1" ; then
    echo "No argument supplied for Slack message"
fi

# Set message JSON data
http_post_data="{\"channel\":\"$SLACK_CHANNEL_ID\",\"text\":\"$1\"}"

# Send message to Slack API
curl --request POST \
     --header "Content-type: application/json" \
     --header "Authorization: Bearer $SLACK_BOT_TOKEN" \
     --data "$http_post_data" \
     --silent --output /dev/null --show-error --fail \
     https://slack.com/api/chat.postMessage
