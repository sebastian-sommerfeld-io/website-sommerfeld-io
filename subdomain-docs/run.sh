#!/bin/bash
# @file run.sh
# @brief Build Docker image containing the docs-website and run in container.
#
# @description The script builds a Docker image containing the whole website inside an Apache httpd webserver and runs
# the image in a container. The base image is the link:https://hub.docker.com/_/httpd[official Apache httpd image].
#
# The script generates all assets for the antora pages as defined in ``playbook-*-local.yml`` files before the Docker
# build.
#
# | What                                                                                  | Port | Protocol |
# | ----------------------------------------------------------------------------------–-- | ---- | -------- |
# | ``pegasus/docs-website:dev``                                                          | 7888 | http     |
# | ``yuzutech/kroki:latest`` (started for antora builds, stopped and removed afterwards) | 7001 | http     |
#
# The image is intended for local testing purposes. Container is started in foreground.
#
# For production use, take a look at link:https://hub.docker.com/r/sommerfeldio/docs-website[``sommerfeldio/docs-website:latest`` on Dockerhub].
#
# ==== Arguments
#
# The script does not accept any parameters.


DOCKER_IMAGE="pegasus/docs-website:dev"
TARGET="target"


# @description Build antora docs for given playbook
#
# @arg $1 string The playbook filename
function buildAntoraDocs() {
  echo -e "$LOG_INFO Antora docs build for $1"
  #docker run -it --rm --volume "$(pwd):$(pwd)" --workdir "$(pwd)" pegasus/adoc-antora:latest antora generate "$1" --stacktrace --clean --fetch
  DOCSEARCH_ENABLED=true DOCSEARCH_ENGINE=lunr antora generate "$1" --stacktrace --generator antora-site-generator-lunr --clean --fetch
  echo -e "$LOG_DONE Antora docs build for $1 finished"
}


echo -e "$LOG_INFO Start local kroki"
kroki=$(docker run -it -d --rm -p 7001:8000 yuzutech/kroki:latest)
echo "$kroki"

echo -e "$LOG_INFO Cleanup target directory"
rm -rf "$TARGET"
mkdir "$TARGET"


buildAntoraDocs playbook-docs-local.yml
buildAntoraDocs playbook-deprecated-docs-local.yml

echo -e "$LOG_INFO Stop local kroki"
docker stop "$kroki"

echo -e "$LOG_INFO Remove old versions of $DOCKER_IMAGE"
docker image rm "$DOCKER_IMAGE"

echo -e "$LOG_INFO Build Docker image $DOCKER_IMAGE"
docker build -t "$DOCKER_IMAGE" .

echo -e "$LOG_INFO Run Docker image"
docker run --rm mwendler/figlet "    7888"
docker run --rm -p 7888:80 "$DOCKER_IMAGE"
