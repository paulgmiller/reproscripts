#!/usr/bin/env bash
TARGET_DIGEST="sha256:$2"
REPO="mcr.microsoft.com/containernetworking/$1"
echo $REPO
#curl -s "https://$REPO/v2/myrepo/tags/list"

# Get all tags
ALL_TAGS=$(curl -s -H "Accept: application/json" "https://$REPO/v2/myrepo/tags/list" | jq -r '.tags[]')

for tag in $ALL_TAGS; do
  # Get manifest digest (header approach)
  DIGEST=$(curl -I -s \
    -H "Accept: application/vnd.docker.distribution.manifest.v2+json" \
    "https://$REPO/v2/myrepo/manifests/$tag" \
    | grep Docker-Content-Digest \
    | awk '{print $2}' \
    | tr -d $'\r')
  
  # Compare
  if [ "$DIGEST" == "$TARGET_DIGEST" ]; then
    echo "Tag '$tag' references digest '$TARGET_DIGEST'"
  fi
