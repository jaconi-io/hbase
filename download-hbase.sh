#!/usr/bin/env sh

# Download Apache HBase from the closest mirror.
curl --remote-name --location "https://www.apache.org/dyn/mirrors/mirrors.cgi?action=download&filename=hbase/${HBASE_VERSION}/hbase-${HBASE_VERSION}-bin.tar.gz"

# Download signature and keys.
curl --remote-name "https://downloads.apache.org/hbase/${HBASE_VERSION}/hbase-${HBASE_VERSION}-bin.tar.gz.asc"
curl --remote-name "https://downloads.apache.org/hbase/KEYS"

# Verify download.
gpg --import KEYS
gpg --verify "hbase-${HBASE_VERSION}-bin.tar.gz.asc" "hbase-${HBASE_VERSION}-bin.tar.gz"

# Extract archive and move to destination.
tar --extract --gzip --file "hbase-${HBASE_VERSION}-bin.tar.gz"
mv "hbase-${HBASE_VERSION}" "hbase"

# Cleanup.
rm "hbase-${HBASE_VERSION}-bin.tar.gz"
rm "hbase-${HBASE_VERSION}-bin.tar.gz.asc"
rm "KEYS"
