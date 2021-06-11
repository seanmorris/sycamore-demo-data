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

USER_ID=$(shasum -a256 .ssh/private-key.pem  | cut -d " " -f 1);

cat << EOF > docs/index.html
<head><style>
body {
	white-space:pre;
	line-height: 1.5em;
	padding:1rem;
}
h1 {
	display:inline;
	padding:0;
	margin:0;
}
</style></head>
<body><h1>${AUTHOR}</h1>
"Tantus labor non sit casus."
uid:${USER_ID}
<img src = "${TEMPLATE_ORIGIN}/avatar.jpg" />
$(date +%s)
<a href  = "${TEMPLATE_ORIGIN}">profile</a>
<a href  = "${DATABASE_ORIGIN}/public-key.pem">public-key</a>
<a href  = "${DATABASE_ORIGIN}/feeds/main.sfd">feed</a>
<a href  = "${DATABASE_ORIGIN}/rss.xml">feed</a>
<a href  = "${HUB_ORIGIN}">hub</a>
</body>
EOF
