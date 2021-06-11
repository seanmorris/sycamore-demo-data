#!/usr/bin/env make

.PHONY: all clean sign-messages factory-reset

MESSAGE_SOURCES=$(shell find ./messages/ -type f | grep -v '\/\.')
MESSAGE_TARGETS=${MESSAGE_SOURCES:./messages/%=./docs/messages/%.smsg}

all: docs/public-key.pem docs/contact-card.json docs/contact-card.json.smsg sign-messages

sign-messages: ${MESSAGE_TARGETS}

docs/contact-card.json: docs/public-key.pem
	bin/generate-contact-card.sh

docs/contact-card.json.smsg: docs/contact-card.json
	bin/sign.sh docs/contact-card.json > docs/contact-card.json.smsg

docs/messages/%.smsg: messages/% docs/public-key.pem docs/contact-card.json docs/contact-card.json.smsg
	mkdir -p ./docs/messages
	bin/sign.sh $< > $@;

docs/public-key.pem: .ssh/private-key.pem
	bin/generate-public-key.sh

docs/index.html: .ssh/private-key.pem
	bin/generate-index-page.sh

docs/feeds/main.sfd: ${MESSAGE_TARGETS}
	bin/index-messages.sh $?

clean:
	rm -rf \
		./docs/feeds/* \
		./tmp/*
	rm -f \
		./docs/messages/*.smsg \
		./docs/contact-card.json \
		./docs/contact-card.json.smsg \
		./docs/public-key.pem \
		./docs/index.html

factory-reset: clean
	rm -f \
		./docs/old-keys/*.pem \
		./.ssh/public-key.pem \
		./docs/old-keys.list
