#!/usr/bin/env bash
set -euxo pipefail;

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

cat << EOF
<?xml version="1.0" encoding="UTF-8" ?>
<rss version="2.0">
<channel>
	<title>${AUTHOR}</title>
	<icon>${TEMPLATE_ORIGIN}/favicon.ico</icon>
	<link>${TEMPLATE_ORIGIN}</link>
	<description>Sycamore origin for ${AUTHOR}</description>
EOF

MESSAGES=$(find messages -type f -printf "%T@\t%Tc\t%p\n" | grep -v '\/\.' | sort -n | cut -f 3);

for MESSAGE in ${MESSAGES}; do {

	MIME=$(mimetype ${MESSAGE} | cut -d ' ' -f 2 | cut -c1-4 );

	[ $MIME = text ] && {
		cat << EOF
	<entry>
		<title>$( cat ${MESSAGE} | cut -c1-140 )</title>
		<author>
			<name>${AUTHOR}</name>
		</author>
		<icon>${TEMPLATE_ORIGIN}/favicon.ico</icon>
		<link>${TEMPLATE_ORIGIN}/${MESSAGE}.smsg</link>
		<guid>${TEMPLATE_ORIGIN}/${MESSAGE}.smsg</guid>
	</entry>
EOF
	}

	[ $MIME = imag ] && {
		cat << EOF
	<entry>
		<title>${MESSAGE}</title>
		<media:thumbnail xmlns:media="http://search.yahoo.com/mrss/" url="${DATABASE_ORIGIN}/${MESSAGE}" />
		<author>
			<name>${AUTHOR}</name>
		</author>
		<icon>${TEMPLATE_ORIGIN}/favicon.ico</icon>
		<link>${TEMPLATE_ORIGIN}/${MESSAGE}.smsg</link>
		<guid>${TEMPLATE_ORIGIN}/${MESSAGE}.smsg</guid>
	</entry>
EOF
	}

} done;

cat << EOF
</channel>
</rss>
EOF
