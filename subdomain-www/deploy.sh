#!/bin/bash
# @file deploy.sh
# @brief Deploy the website image to DockerHub.
#
# @description The script deploys the website image to DockerHub. The local image ``pegasus/website:dev`` gets
# re-tagged as ``sommerfeldio/website:latest`` and is deployed to link:https://hub.docker.com/r/sommerfeldio/website/[DockerHub].
#
# After deploying to DockerHub, the script deletes the local image ``sommerfeldio/website:latest`` and pulls the
# image from DockerHub to check whether the deployment worked.
#
# IMPORTANT: This is just a temporary script which will be replaced by a CICD pipeline sometime in the future.
#
# ==== Arguments
#
# The script does not accept any parameters.


SRC_DOCKER_IMAGE="pegasus/website:dev"
TARGET_DOCKER_IMAGE="sommerfeldio/website"

echo -e "$LOG_INFO Deploy image $TARGET_DOCKER_IMAGE to DockerHub"

echo -e "$LOG_INFO Login to remote container registry"
docker login -u=sommerfeldio

echo -e "$LOG_INFO Re-tag image"
docker tag "$SRC_DOCKER_IMAGE" "$TARGET_DOCKER_IMAGE:stable"
docker tag "$SRC_DOCKER_IMAGE" "$TARGET_DOCKER_IMAGE:latest"

echo -e "$LOG_INFO Push image to remote container registry"
docker push "$TARGET_DOCKER_IMAGE:stable"
docker push "$TARGET_DOCKER_IMAGE:latest"

echo -e "$LOG_INFO Remove local version of $TARGET_DOCKER_IMAGE"
docker image rm "$TARGET_DOCKER_IMAGE:stable"
docker image rm "$TARGET_DOCKER_IMAGE:latest"

echo -e "$LOG_INFO Pull $TARGET_DOCKER_IMAGE from remote container registry"
docker pull "$TARGET_DOCKER_IMAGE:stable"
docker pull "$TARGET_DOCKER_IMAGE:latest"

echo -e "$LOG_DONE Finished deployment of $TARGET_DOCKER_IMAGE"

# todo ... ftp upload ... similar to other static websites
