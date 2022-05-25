#!/bin/bash
# @file deploy.sh
# @brief Deploy the docs-website image to DockerHub and update the website om DigitalOcean.
#
# @description The script deploys the docs-website image to DockerHub. The local image ``pegasus/docs-website:dev`` gets
# re-tagged as ``sommerfeldio/docs-website:latest`` and is deployed to link:https://hub.docker.com/r/sommerfeldio/docs-website/[DockerHub].
#
# After deploying to DockerHub, the script deletes the local image ``sommerfeldio/docs-website:latest`` and pulls the
# image from DockerHub to check whether the deployment worked.
#
# Lastly the script triggers a re-deployment of the DigitalOcean app to ensure the wenbsite is updated to the latest
# image version from DockerHub.
#
# IMPORTANT: This is just a temporary script which will be replaced by a CICD pipeline sometime in the future.
#
# ==== Arguments
#
# The script does not accept any parameters.


DOCKER_SRC_IMAGE="pegasus/docs-website:dev"
DOCKER_TARGET_IMAGE="sommerfeldio/docs-website"
#DO_TARGET_APP_NAME="sommerfeldio-docs-website"
DO_SECRETS_FILE="resources/.secrets/digitalocean.token"


echo -e "$LOG_INFO Read DigitalOcean token from '$DO_SECRETS_FILE'"
#DO_API_TOKEN=$(cat "$DO_SECRETS_FILE")

echo -e "$LOG_INFO Deploy image $DOCKER_TARGET_IMAGE to DockerHub"

echo -e "$LOG_INFO Login to remote container registry"
docker login -u=sommerfeldio

echo -e "$LOG_INFO Re-tag image"
docker tag "$DOCKER_SRC_IMAGE" "$DOCKER_TARGET_IMAGE:stable"
docker tag "$DOCKER_SRC_IMAGE" "$DOCKER_TARGET_IMAGE:latest"

echo -e "$LOG_INFO Push image to remote container registry"
docker push "$DOCKER_TARGET_IMAGE:stable"
docker push "$DOCKER_TARGET_IMAGE:latest"

echo -e "$LOG_INFO Remove local version of $DOCKER_TARGET_IMAGE"
docker image rm "$DOCKER_TARGET_IMAGE:stable"
docker image rm "$DOCKER_TARGET_IMAGE:latest"

echo -e "$LOG_INFO Pull $DOCKER_TARGET_IMAGE from remote container registry"
docker pull "$DOCKER_TARGET_IMAGE:stable"
docker pull "$DOCKER_TARGET_IMAGE:latest"

echo -e "$LOG_DONE Finished deployment of $DOCKER_TARGET_IMAGE to DockerHub"

#echo -e "$LOG_INFO Deploy latest image to DigitalOcean"
#
#echo -e "$LOG_INFO Read all apps with name and id from DigitalOcean"
#apps=$(docker run --rm -it --env=DIGITALOCEAN_ACCESS_TOKEN="$DO_API_TOKEN" digitalocean/doctl:latest apps list --format ID,Spec.Name --no-header)
#
#echo -e "$LOG_INFO Update DigitalOcean app '$DO_TARGET_APP_NAME' (deploy latest version from DockerHub)"
#echo -e "$LOG_INFO Iterate apps"
#while IFS= read -r line
#do
#  if [[ "$line" == *"$DO_TARGET_APP_NAME"* ]]; then
#    id="${line:0:36}"
#    echo -e "$LOG_INFO     Found target app '$DO_TARGET_APP_NAME'"
#    echo -e "$LOG_INFO     Deployment = $line"
#    echo -e "$LOG_INFO         App ID = $id"
#    docker run --rm -i --env=DIGITALOCEAN_ACCESS_TOKEN="$DO_API_TOKEN" digitalocean/doctl:latest apps create-deployment "$id" --force-rebuild --wait
#  fi
#done < <(printf '%s\n' "$apps")
#
#echo -e "$LOG_DONE Updated DigitalOcean app '$DO_TARGET_APP_NAME' (deploy latest version from DockerHub)"
