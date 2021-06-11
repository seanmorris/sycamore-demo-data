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

openssl rsa -in .ssh/private-key.pem -pubout > docs/public-key.test.pem;

touch .ssh/public-key.pem;

cmp .ssh/public-key.pem .ssh/public-key.test.pem && {

	rm .ssh/public-key.test.pem;

} || {

	test -s .ssh/public-key.pem && {
		echo "was not empty";
		MOVE_KEY=public-key-$(date +%s).pem;
		echo ${MOVE_KEY} >> docs/old-keys.list;

		cp .ssh/public-key.pem docs/old-keys/${MOVE_KEY};
		cp .ssh/public-key.pem docs/public-key.pem;

	} || {
		echo "was empty";
		mv docs/public-key.test.pem docs/public-key.pem;
	}

}
