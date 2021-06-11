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

# cat ${OUTPUT} | base64 -w0 | curl 'https://backend.warehouse.seanmorr.is/publish/sycamore.seanmorr.is::posts' \
#   -H 'origin: https://warehouse.seanmorr.is' \
#   -H 'content-type: undefined' \
#   -X POST --data-binary @-
