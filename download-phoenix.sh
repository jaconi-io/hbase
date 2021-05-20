#!/usr/bin/env sh

# Determine Apache Phoenix version compatible to the selected HBase version.
case "$HBASE_VERSION" in
  1*)
    PHOENIX_VERSION="4.16.0"
  ;;
  2*)
    PHOENIX_VERSION="5.1.1"
  ;;
  *)
    echo "No Apache Phoenix version is compatible to HBase $HBASE_VERSION"
    exit 1
  ;;
esac

# Determine "short" HBase version (for example, '2.4' instead of '2.4.2').
HBASE_VERSION_SHORT=$(echo "$HBASE_VERSION" | cut -d "." -f 1-2)

# Download Apache Phoenix from the closest mirror.
curl --location --output "phoenix-hbase-${HBASE_VERSION_SHORT}-${PHOENIX_VERSION}-bin.tar.gz" "http://www.apache.org/dyn/closer.lua/phoenix/phoenix-${PHOENIX_VERSION}/phoenix-hbase-${HBASE_VERSION_SHORT}-${PHOENIX_VERSION}-bin.tar.gz?action=download"

# Download signature and keys.
curl --remote-name "https://downloads.apache.org/phoenix/phoenix-${PHOENIX_VERSION}/phoenix-hbase-${HBASE_VERSION_SHORT}-${PHOENIX_VERSION}-bin.tar.gz.asc"
curl --remote-name "https://downloads.apache.org/phoenix/KEYS"

# Verify download.
gpg --import KEYS
gpg --verify "phoenix-hbase-${HBASE_VERSION_SHORT}-${PHOENIX_VERSION}-bin.tar.gz.asc" "phoenix-hbase-${HBASE_VERSION_SHORT}-${PHOENIX_VERSION}-bin.tar.gz"

# Extract archive and move to destination.
tar --extract --gzip --file "phoenix-hbase-${HBASE_VERSION_SHORT}-${PHOENIX_VERSION}-bin.tar.gz"
mv "phoenix-hbase-${HBASE_VERSION_SHORT}-${PHOENIX_VERSION}-bin" "phoenix"

# Cleanup.
rm "phoenix-hbase-${HBASE_VERSION_SHORT}-${PHOENIX_VERSION}-bin.tar.gz"
rm "phoenix-hbase-${HBASE_VERSION_SHORT}-${PHOENIX_VERSION}-bin.tar.gz.asc"
rm "KEYS"
