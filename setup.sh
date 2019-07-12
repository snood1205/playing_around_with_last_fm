#!/usr/local/bin/bash
set -euo pipefail
IFS=$'\n\t'

touch .env

printf 'Input your last.fm username: '
read name
echo "USERNAME=$name" >> .env

printf 'Input your last.fm api key: '
read key
echo "API_KEY=$key" >> .env
