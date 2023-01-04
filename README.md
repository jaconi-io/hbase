**This project is unmaintained!**

# hbase

A docker image for [Apache HBase](https://hbase.apache.org/).

Included:
* [Apache Phoenix](https://phoenix.apache.org/)
* [dockerize](https://github.com/jwilder/dockerize)
* [Google Cloud Storage connector](https://cloud.google.com/dataproc/docs/concepts/connectors/cloud-storage)

## Configuration

Apache HBase is usually configured using a XML configuration files:

* [hbase-site.xml](https://raw.githubusercontent.com/apache/hbase/master/hbase-common/src/main/resources/hbase-default.xml)

Mounting this into a container is tedious. Therefore we exclusively use environment variables to configure Apache HBase
in this container.

If you want to set, for example, `hbase.rootdir` in `hbase-site.xml` you would set the environment variable
`HBASE_ROOTDIR` instead.
