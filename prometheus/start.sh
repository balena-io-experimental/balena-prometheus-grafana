#!/bin/bash

echo $TARGETS > targets
sed -i "s/ //g" targets
sed -ie "s/^/\\\'/g" targets
sed -ie "s/$/\\\'/g" targets
sed -ie "s/,/\\\',\\\'/g" targets

sed -ie "s/\['node_exporter:9100'\]/TARGETS/g" /etc/prometheus/prometheus.yml

sed -ie "s/TARGETS/\['node_exporter:9100',$(cat targets)\]/g" /etc/prometheus/prometheus.yml

./prometheus/prometheus --config.file=/etc/prometheus/prometheus.yml