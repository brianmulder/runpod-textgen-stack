SHELL := /usr/bin/env bash


.PHONY: lint deps shellcheck shfmt markdownlint jq schema

lint: deps shellcheck shfmt markdownlint jq schema

deps:
	sudo apt-get update -y >/dev/null
	command -v shellcheck >/dev/null || sudo apt-get install -y shellcheck
	command -v shfmt >/dev/null || sudo apt-get install -y shfmt
	command -v npm >/dev/null || sudo apt-get install -y npm
	command -v markdownlint >/dev/null || npm install -g markdownlint-cli
	command -v jq >/dev/null || sudo apt-get install -y jq
	command -v jsonschema >/dev/null || sudo apt-get install -y python3-jsonschema

shellcheck:
	shellcheck bin/*.sh

shfmt:
	shfmt -i 4 -s -d bin/*.sh

markdownlint:
	markdownlint **/*.md

jq:
	jq . runpod/pod-spec.json > /dev/null

schema:
	jsonschema -i runpod/pod-spec.json runpod/pod-spec.schema.json

