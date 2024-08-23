#!/usr/bin/env bash
# missing todo's
# indepdentent locater, as people might use different working directories

set -e

SCRIPTPATH=$(realpath "$0")
SCRIPTDIR=$(dirname "$SCRIPTPATH")
AQUA_PKC_DIR=$(dirname "$SCRIPTDIR")
AQUA_DIR=$(dirname "$AQUA_PKC_DIR")

# Nuke all
(cd "$AQUA_PKC_DIR" && ./pkc nuke)

# update aqua-PKC with docker compose pull
echo 'This needs to be run in aqua-PKC/scripts' after ./pkc nuke
(cd "$AQUA_PKC_DIR" && echo 'Checking for updates on aqua-PKC' && git pull && echo 'Checking for new version of containers' && docker compose pull)
(cd "$AQUA_DIR"/DataAccounting && echo 'Checking for updates on DataAccounting' && git pull)
(cd "$AQUA_DIR"/data-accounting-external-verifier && echo 'Checking for updates on data-accounting-external-verifier' && git pull)
(cd "$AQUA_DIR"/VerifyPage && echo 'Checking for updates on VerifyPage an rebuilding it' && git pull && npm ci && npm run build)
echo 'Done!!! You should be up to date and ready to go!'
echo 'Run the ./pkc setup again.'

