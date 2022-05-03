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


case $HOSTNAME in
("pegasus") echo -e "$LOG_INFO Script running on expected machine $HOSTNAME";;
(*)         echo -e "$LOG_ERROR SCRIPT NOT RUNNING ON EXPECTED MACHINE !!!" && echo -e "$LOG_ERROR Exit" && exit 0;;
esac


SRC_DOCKER_IMAGE="pegasus/website:dev"
TARGET_DOCKER_IMAGE="sommerfeldio/website"

FTP_HOST="w00f8074.kasserver.com"
FTP_USER_FILE="resources/.secrets/ftp.user"
FTP_PASS_FILE="resources/.secrets/ftp.pass"
CONTENT_DIR="src/main"


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

echo -e "$LOG_INFO FTP upload"

echo -e "$LOG_INFO Read FTP user and password from $FTP_USER_FILE and $FTP_PASS_FILE"
FTP_USER=$(cat "$FTP_USER_FILE")
FTP_PASS=$(cat "$FTP_PASS_FILE")

if [[ ! -d "$CONTENT_DIR" ]]
then
  echo -e "$LOG_ERROR Directory '$CONTENT_DIR' missing -> No files to upload"
  echo -e "$LOG_ERROR exit"
  exit 0
fi

echo -e "$LOG_INFO Deploy files to webspace via FTP"
(
  cd "$CONTENT_DIR" || exit
  # shellcheck disable=SC2035
  docker run -it --rm --volume "$(pwd):$(pwd)" --workdir "$(pwd)" pegasus/ftp-client:latest ncftpput -R -v -u "$FTP_USER" -p "$FTP_PASS" "$FTP_HOST" / *
)

echo -e "$LOG_DONE FTP upload"
