#!/usr/bin/env sh

# Download dockerize.
curl --remote-name --location "https://github.com/jwilder/dockerize/releases/download/${DOCKERIZE_VERSION}/dockerize-linux-amd64-${DOCKERIZE_VERSION}.tar.gz"

# Extract archive.
tar --extract --gzip --file "dockerize-linux-amd64-${DOCKERIZE_VERSION}.tar.gz"

# Cleanup.
rm "dockerize-linux-amd64-${DOCKERIZE_VERSION}.tar.gz"
