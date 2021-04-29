# hbase

A docker image for [Apache HBase](https://hbase.apache.org/).

## Configuration

Apache HBase is usually configured using a XML configuration files:

* [hbase-site.xml](https://raw.githubusercontent.com/apache/hbase/master/hbase-common/src/main/resources/hbase-default.xml)

Mounting this into a container is tedious. Therefore we exclusively use environment variables to configure Apache HBase
in this container.

If you want to set, for example, `hbase.rootdir` in `hbase-site.xml` you would set the environment variable
`HBASE_ROOTDIR` instead.

## Testing

To test your changes, run

```
docker compose build
docker compose run sut
```
