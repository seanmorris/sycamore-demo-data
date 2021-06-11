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

INPUT=$1;

[[ -f ${INPUT} ]] || exit;

PUBLIC_KEY_URL=${DATABASE_ORIGIN}/public-key;
BASE_INPUT=${1#messages/};
USER_ID=$(shasum -a256 .ssh/public-key.pem | cut -d " " -f 1);
TYPE=$(file -ib --mime-type ${INPUT});
NOW=$(date +%s);

ASSERTS=post

[[ $# -gt 1 ]] && {
	ASSERTS=$2;
}

test -f $INPUT || exit 1;

>&2 echo "Generating the header.";

TEMP_DIR=$(mktemp -d -p ./tmp)
OUTPUT=$(mktemp -p ${TEMP_DIR});
HEADER_FILE=$(mktemp -p ${TEMP_DIR});
SIGNATURE_FILE=$(mktemp -p ${TEMP_DIR});

cat << EOF > ${HEADER_FILE}
{
	"authority": "${DATABASE_ORIGIN}"
	, "author":  "${AUTHOR}"
	, "asserts": "${ASSERTS}"
	, "respond": null
	, "name":    "${BASE_INPUT#docs/}"
	, "key":     "${PUBLIC_KEY_URL}"
	, "uid":     "${USER_ID}"
	, "mime":    "${TYPE}"
	, "issued":  ${NOW}
	, "topics:": []
}
EOF

printf '🍁\n' > ${OUTPUT};

>&2 echo "Measure and append the header...";

(wc -c  < ${HEADER_FILE} | perl -lpe '$_=pack "L",$_') >> ${OUTPUT};

cat ${HEADER_FILE} >> ${OUTPUT};

>&2 echo "Measure and append the original message...";

(wc -c  < ${INPUT} | perl -lpe '$_=pack "L",$_') >> ${OUTPUT};

cat ${INPUT} >> ${OUTPUT};

>&2 echo "Generate the signature.";

echo '-----BEGIN RSA SIGNATURE-----' > ${SIGNATURE_FILE};

openssl dgst -sha1 -sign .ssh/private-key.pem ${OUTPUT} \
	| openssl base64 \
	>> ${SIGNATURE_FILE};

echo '-----END RSA SIGNATURE-----' >> ${SIGNATURE_FILE};

>&2 echo "Measure and append the signature...";

(wc -c  < ${SIGNATURE_FILE} | perl -lpe '$_=pack "L",$_') >> ${OUTPUT};

cat ${SIGNATURE_FILE} >> ${OUTPUT};

>&2 echo "Cleaning up...";# 

cat ${OUTPUT};

rm ${HEADER_FILE} ${SIGNATURE_FILE} ${OUTPUT};

rmdir ${TEMP_DIR};

>&2 echo "Done.";# 
