#!/bin/bash

# Send notifications about changelists to a Slack webhook.

# Installation
# Open your Helix Core triggers file with:
#     p4 triggers
# Add a line with this info:
#     slackNotifier change-commit //<depot_path_to_notify_about>/... "/bin/bash <path_this_script_on_the_server> %changelist% <your_slack_webhook_to_notify>"

# The Linux user running the p4d process needs to have acess to this script
# And the p4 user (check `p4 set`) needs permission for describe
# (Usually you would have a super user as the main user on the server, so this is probably already true.)
# If the user's ticket is expired then this will fail until that is renewed. 
# Consider setting this user to have an unlimited timeout.

printf "--TRIGGER-- Running p4_slack_webhook.sh\n"

# Get the description of the changelist number passed in as arg $1
OUTPUT=$(p4 describe -s $1)

# Thanks to https://github.com/saadbruno/perforce-discord-webhook for these lines to parse the output!
DESC=$(echo "$OUTPUT" | awk '/^[[:blank:]]/' | sed s/[\'\"]/\\\'/g | awk '{printf "%s\\n", $0}' | tr -s [:space:] ' ')
USER=$(echo "$OUTPUT" | head -n 1 | cut -d" " -f4)

# Create our message
BLOCKS='{
	"blocks": [
		{
			"type": "section",
			"text": {
				"type": "mrkdwn",
				"text": "'"$USER"' submitted changelist '"$1"'"
			}
		},
		{
			"type": "section",
			"text": {
				"type": "mrkdwn",
				"text": "'"$DESC"'"
			}
		}
	]
}'


# sends it
printf "            Sending webhook...\n"
curl -H "Content-Type: application/json" \
-X POST \
-d "$BLOCKS" \
$2

printf "            DEBUG linux user: $(whoami) cl#: $1 
p4 describe output:
$OUTPUT

:: Linux path:
$(pwd)

:: user:
$USER
"