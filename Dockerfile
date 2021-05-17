FROM openjdk:8-jre AS builder

ARG HBASE_VERSION=2.4.2
ENV DOCKERIZE_VERSION v0.6.1
ENV DEBIAN_FRONTEND noninteractive

COPY generate.sh generate.sh

# Install security updates and build dependencies.
RUN apt-get update \
 && apt-get --assume-yes upgrade \
 && apt-get --assume-yes install --no-install-recommends xmlstarlet \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Download Apache HBase from the closest mirror and verify the download. Download dockerize. Download the Google Cloud
# Storage-Connector (see https://cloud.google.com/dataproc/docs/concepts/connectors/cloud-storage). Generate templates.
RUN curl --remote-name --location "https://www.apache.org/dyn/mirrors/mirrors.cgi?action=download&filename=hbase/${HBASE_VERSION}/hbase-${HBASE_VERSION}-bin.tar.gz" \
    && curl --remote-name "https://downloads.apache.org/hbase/${HBASE_VERSION}/hbase-${HBASE_VERSION}-bin.tar.gz.asc" \
    && curl --remote-name "https://downloads.apache.org/hbase/KEYS" \
    && gpg --import KEYS \
    && gpg --verify "hbase-${HBASE_VERSION}-bin.tar.gz.asc" "hbase-${HBASE_VERSION}-bin.tar.gz" \
    && tar --extract --gzip --file "hbase-${HBASE_VERSION}-bin.tar.gz" \
    && mv "hbase-${HBASE_VERSION}" "hbase" \
    && curl --remote-name --location "https://github.com/jwilder/dockerize/releases/download/${DOCKERIZE_VERSION}/dockerize-linux-amd64-${DOCKERIZE_VERSION}.tar.gz" \
    && tar --extract --gzip --file "dockerize-linux-amd64-${DOCKERIZE_VERSION}.tar.gz" \
    && curl --remote-name https://storage.googleapis.com/hadoop-lib/gcs/gcs-connector-hadoop3-latest.jar \
    && ./generate.sh

FROM openjdk:8-jre

ENV PATH /opt/hbase/bin:$PATH

COPY --from=builder /dockerize /usr/local/bin/dockerize
COPY --from=builder /hbase /opt/hbase
COPY --from=builder /hbase-site.xml.tmpl /opt/hbase/conf/hbase-site.xml.tmpl
COPY --from=builder /core-site.xml.tmpl /opt/hbase/conf/core-site.xml.tmpl
COPY --from=builder /hdfs-site.xml.tmpl /opt/hbase/conf/hdfs-site.xml.tmpl
COPY --from=builder /gcs-connector-hadoop3-latest.jar /opt/hbase/lib/gcs-connector-hadoop3-latest.jar

ENTRYPOINT [ "dockerize", \
  "-template", "/opt/hbase/conf/hbase-site.xml.tmpl:/opt/hbase/conf/hbase-site.xml", \
  "-template", "/opt/hbase/conf/core-site.xml.tmpl:/opt/hbase/conf/core-site.xml", \
  "-template", "/opt/hbase/conf/hdfs-site.xml.tmpl:/opt/hbase/conf/hdfs-site.xml" ]
CMD [ "hbase", "--help" ]
