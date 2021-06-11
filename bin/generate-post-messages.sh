#!/usr/bin/env bash
set -euo pipefail;

test -f .env && {
	set -a;
	. .env;
	set +a;
} \
|| {
	>&2 echo "Notice: .env file not found.";
}

[[ ${DEBUG:-0} -eq 1 ]] && {
	set -x;
}

HOUR=$(echo '60*60' | bc);
NOW=$(echo `date '+%s'`/${HOUR}*${HOUR} | bc);

FEED_DIR=docs/feeds/`date +%Y-%m`/`date +%d`;

mkdir -p $FEED_DIR;

git diff HEAD~1 --name-only messages/ | while read NAME; do {
	DATABASE_ORIGIN=${DATABASE_ORIGIN} \
	TEMPLATE_ORIGIN=${TEMPLATE_ORIGIN} \
		bash bin/generate-post-message.sh ${NAME};
}; done;
