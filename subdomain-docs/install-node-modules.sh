#!/bin/bash
# @file install-node-modules.sh
# @brief Install all needed node modules.
#
# @description The script installs all node modules needed to build the Antora website and run a local webserver.
#
# ==== Arguments
#
# The script does not accept any parameters.

echo -e "$LOG_INFO Clean node modules"
rm -rf node_modules

# install modules to build docs
echo -e "$LOG_INFO Install node modules"
npm install
npm install mkdirp@latest
npm install antora-site-generator-lunr
echo -e "$LOG_DONE All node modules installed"

echo -e "$LOG_INFO Address vulnerabilities"
npm audit fix

echo -e "$LOG_DONE Finished node modules setup"
