FROM openjdk:8-jre AS builder

ARG HADOOP_VERSION=3.3.0
ARG HBASE_VERSION=2.4.2
ENV DOCKERIZE_VERSION v0.6.1
ENV DEBIAN_FRONTEND noninteractive

COPY generate.sh generate.sh
COPY download-hadoop.sh download-hadoop.sh
COPY download-hbase.sh download-hbase.sh
COPY download-phoenix.sh download-phoenix.sh
COPY download-dockerize.sh download-dockerize.sh
COPY download-gcs-connector.sh download-gcs-connector.sh

# Install security updates and build dependencies.
RUN apt-get update \
 && apt-get --assume-yes upgrade \
 && apt-get --assume-yes install --no-install-recommends xmlstarlet \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Download Apache Hadoop, Apache HBase, Apache Phoenix, dockerize and Google Cloud Storage-Connector. Generate
# templates.
RUN ./download-hadoop.sh \
 && ./download-hbase.sh \
 && ./download-phoenix.sh \
 && ./download-dockerize.sh \
 && ./download-gcs-connector.sh \
 && ./generate.sh

FROM openjdk:8-jre

ENV PATH /opt/hbase/bin:$PATH
ENV LD_LIBRARY_PATH /opt/hadoop/lib/native

COPY --from=builder /dockerize /usr/local/bin/dockerize
COPY --from=builder /hadoop/lib/native /opt/hadoop/lib/native
COPY --from=builder /hbase /opt/hbase
COPY --from=builder /hbase-site.xml.tmpl /opt/hbase/conf/hbase-site.xml.tmpl
COPY --from=builder /core-site.xml.tmpl /opt/hbase/conf/core-site.xml.tmpl
COPY --from=builder /hdfs-site.xml.tmpl /opt/hbase/conf/hdfs-site.xml.tmpl
COPY --from=builder /gcs-connector-*.jar /opt/hbase/lib
COPY --from=builder /phoenix/phoenix-server-*.jar /opt/hbase/lib

# Install security updates and runtime dependencies.
RUN apt-get update \
 && apt-get --assume-yes upgrade \
 && apt-get --assume-yes install --no-install-recommends libsnappy1v5 \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Setup non-root user.
RUN addgroup --system --gid 10001 hbase \
 && adduser --system --uid 10001 --ingroup hbase hbase \
 && chown -R hbase:hbase /opt/hbase
USER hbase

ENTRYPOINT [ "dockerize", \
  "-template", "/opt/hbase/conf/hbase-site.xml.tmpl:/opt/hbase/conf/hbase-site.xml", \
  "-template", "/opt/hbase/conf/core-site.xml.tmpl:/opt/hbase/conf/core-site.xml", \
  "-template", "/opt/hbase/conf/hdfs-site.xml.tmpl:/opt/hbase/conf/hdfs-site.xml" ]
CMD [ "hbase", "--help" ]
