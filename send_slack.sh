#!/bin/bash
SLACK_URL=https://hooks.slack.com/services/${SLACK_HOOK}
SLACK_MSG="Build $2: ${CF_PAGES_BRANCH} branch of $1"

curl \
	-X POST \
	-H 'Content-type: application/json' \
	--data '{"text":"'"${SLACK_MSG}"'"}' \
	${SLACK_URL}
