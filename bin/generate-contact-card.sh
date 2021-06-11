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

USER_ID=$(shasum -a256 .ssh/public-key.pem  | cut -d " " -f 1);

cat << EOF > docs/contact-card.json
{
	"name":     "${AUTHOR}"
	, "issued": "$(date +%s)"
	, "about":  "Tantus labor non sit casus."
	, "uid":    "${USER_ID}"
	, "url":    "${TEMPLATE_ORIGIN}"
	, "img":    "${TEMPLATE_ORIGIN}/avatar.jpg"
	, "key":    "${DATABASE_ORIGIN}/public-key.pem"
	, "hub":    "${HUB_ORIGIN}"
}
EOF
