#!/bin/bash
# @file run.sh
# @brief Build Docker image containing the website and run in container.
#
# @description The script builds a Docker image containing the website and runs the image in a container. The base image
# is ``wwwthoughtworks/build-your-own-radar`` (see https://github.com/thoughtworks/build-your-own-radar).
#
# | What                    | Port | Protocol |
# | ----------------------- | ---- | -------- |
# | ``pegasus/website:dev`` | 7888 | http     |
#
# The image is intended for local testing purposes. Container is started in foreground.
#
# For production use, take a look at link:https://hub.docker.com/r/sommerfeldio/website[``sommerfeldio/website:latest`` on Dockerhub].
#
# ==== Arguments
#
# The script does not accept any parameters.


DOCKER_IMAGE="pegasus/website:dev"

echo -e "$LOG_INFO Remove old versions of $DOCKER_IMAGE"
docker image rm "$DOCKER_IMAGE"

echo -e "$LOG_INFO Build Docker image $DOCKER_IMAGE"
docker build -t "$DOCKER_IMAGE" .

echo -e "$LOG_INFO Run Docker image"
docker run --rm mwendler/figlet "    7888"
docker run --rm -p 7888:80 "$DOCKER_IMAGE"
