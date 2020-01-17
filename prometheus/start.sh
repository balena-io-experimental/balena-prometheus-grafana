#!/bin/bash

# Copy the environment variable to a file
echo $TARGETS > targets

# Clean up the entries to parse correctly
sed -i "s/ //g" targets
sed -ie "s/^/\\\'/g" targets
sed -ie "s/$/\\\'/g" targets
sed -ie "s/,/\\\',\\\'/g" targets

# Replace the default node_exporter entry with all the targets
sed -ie "s/\['node_exporter:9100'\]/TARGETS/g" /etc/prometheus/prometheus.yml
sed -ie "s/TARGETS/\['node_exporter:9100',$(cat targets)\]/g" /etc/prometheus/prometheus.yml

# Start Prometheus with the updated config file
./prometheus/prometheus --config.file=/etc/prometheus/prometheus.yml