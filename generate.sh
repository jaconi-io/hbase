#!/usr/bin/env sh

###
# Generate teamplates that make HBase configurable via environment variables.
###

generate() {
  echo "<?xml version=\"1.0\"?>"
  echo "<?xml-stylesheet type=\"text/xsl\" href=\"configuration.xsl\"?>"

  echo "<configuration>"
  for property in $(xmlstarlet select --template --match "/configuration/property/name" --value-of "." --output " " $1); do
    ENV=$(echo $property | tr "a-z" "A-Z" | tr "." "_" | tr "-" "_" | tr "[" "_" | tr "]" "_" )
    echo "{{- if .Env.$ENV }}"
    echo "  <property>"
    echo "    <name>$property</name>"
    echo "    <value>{{ .Env.$ENV }}</value>"
    echo "  </property>"
    echo "{{- end }}"
  done
  echo "</configuration>"
}

curl "https://raw.githubusercontent.com/apache/hbase/rel/${HBASE_VERSION}/hbase-common/src/main/resources/hbase-default.xml" --output "hbase-default.xml"
generate "hbase-default.xml" > hbase-site.xml.tmpl
