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

FEED=docs/feeds/main.sfd;
MAX_LINES=5;

TMP_DIR=$(mktemp -d -p ./tmp)
TMP_FEED=$(mktemp -p ${TMP_DIR});

[[ -f ${FEED} ]] && cat ${FEED} > ${TMP_FEED};

for FILE in $@; do {

	echo ${FILE} | grep '\/\.' && continue;

	[[ $(wc -l < ${TMP_FEED} || echo '0') -gt ${MAX_LINES} ]] && {
		FEED_DIR=docs/feeds/`date +%Y/%m/%d`;
		NOW=$(echo `date '+%s'`);

		mkdir -p $FEED_DIR;

		cp ${TMP_FEED} ${FEED_DIR}/$(basename ${FEED%.sfd})-${NOW}.sfd;

		echo -e P"\t"${NOW}"\t"${FEED_DIR#docs/}/$(basename ${FEED%.sfd})-${NOW}.sfd > ${TMP_FEED};

		sleep 1;
	}

	echo -e M"\t"$(stat -c %Z ${FILE})"\t"${FILE#docs/} >> ${TMP_FEED};

};done;

cat ${TMP_FEED} >> ${FEED};

rm ${TMP_FEED};
rmdir ${TMP_DIR};
