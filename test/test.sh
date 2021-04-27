#!/usr/bin/env sh

# Wait for Hadoop to become available.
dockerize -wait tcp://namenode:9000 -timeout 30s

echo "TODO: Perform some actual testing..."
