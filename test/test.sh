#!/usr/bin/env sh

# Exit on error.
set -e

# Wait for Hadoop and ZooKeeper to become available.
dockerize -wait tcp://namenode:9000 -timeout 30s
dockerize -wait tcp://zoo1:2181 -wait tcp://zoo2:2181 -wait tcp://zoo3:2181 -timeout 30s

# Wait for HBase master to become available.
retries=0
until echo "list" | hbase shell --noninteractive || [ $retries -ge 15 ]; do
  retries=$((retries+1))
  echo "Waiting for HBase master to become available..."
  sleep 2
done

# Insert test data.
echo """create 'TestTable', 'Test Data'
put 'TestTable', 'row1', 'Test Data:col1', 'Test Value 1.1.1'
put 'TestTable', 'row1', 'Test Data:col1', 'Test Value 1.1.2'
put 'TestTable', 'row1', 'Test Data:col2', 'Test Value 1.2.1'
put 'TestTable', 'row1', 'Test Data:col2', 'Test Value 1.2.2'
put 'TestTable', 'row2', 'Test Data:col1', 'Test Value 2.1.1'
put 'TestTable', 'row2', 'Test Data:col1', 'Test Value 2.1.2'
put 'TestTable', 'row2', 'Test Data:col2', 'Test Value 2.2.1'
put 'TestTable', 'row2', 'Test Data:col2', 'Test Value 2.2.2'""" | hbase shell --noninteractive

# Make sure data can be read.
EXPECTED="""ROW  COLUMN\+CELL
 row1 column=Test Data:col1, timestamp=[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[0-9][0-9]:[0-9][0-9]:[0-9][0-9].[0-9][0-9][0-9], value=Test Value 1.1.2
 row1 column=Test Data:col2, timestamp=[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[0-9][0-9]:[0-9][0-9]:[0-9][0-9].[0-9][0-9][0-9], value=Test Value 1.2.2
 row2 column=Test Data:col1, timestamp=[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[0-9][0-9]:[0-9][0-9]:[0-9][0-9].[0-9][0-9][0-9], value=Test Value 2.1.2
 row2 column=Test Data:col2, timestamp=[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[0-9][0-9]:[0-9][0-9]:[0-9][0-9].[0-9][0-9][0-9], value=Test Value 2.2.2"""
DATA=$(echo "scan 'TestTable'" | hbase shell --noninteractive)
if [ expr "$DATA" : "$EXPETED" ]; then
  echo "Mismatch between expected and actual data in HBase:"
  echo "Expected:\n$EXPECTED"
  echo "Actual:\n$DATA"
  exit 1
fi

# Cleanup test data.
echo """disable 'TestTable'
drop 'TestTable'""" | hbase shell --noninteractive
