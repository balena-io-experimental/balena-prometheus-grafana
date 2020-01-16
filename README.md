balenaCloud Prometheus and Grafana
===================================

### Introduction
This project creates an application running Prometheus, Grafana and Node Exporter and can self-monitor. To add additional node targets, simply add the _node_exporter_ folder to any other project and update its _docker-compose.yml_ file and add the target to the _prometheus.yml_ file, as shown below.

```
/balena-grafana/
├── node_exporter
│   ├── Dockerfile.template
├── prometheus
│   ├── Dockerfile.template
│   └── prometheus.yml
├── docker-compose.yml
├── README.md
```

In order to work properly, Prometheus needs at least a minimal _prometheus.yml_ file with basic _global_ and _scrape_config_ entries. The following is used in this project:

```
global:
  scrape_interval: 15s
  evaluation_interval: 15s
  scrape_timeout: 10s

scrape_configs:
  - job_name: prometheus
    honor_timestamps: true
    scrape_interval: 15s
    scrape_timeout: 10s
    metrics_path: /metrics
    scheme: http
    static_configs:
    - targets:
      - prometheus:9090
  - job_name: node_exporter
    honor_timestamps: true
    scrape_interval: 15s
    scrape_timeout: 10s
    metrics_path: /metrics
    scheme: http
    static_configs:
    - targets:
      - node_exporter:9100
      - 10.128.1.134:9100
      - 10.128.1.211:9100
```      

Two networks are used. The _frontend_ network enables external connections to ports 3000, 9090 and 9100 on the Prometheus service to enable requests to and from Grafana (3000), Prometheus (9090) and Node Exporter (9100). The _backend_ network enables the local name resolution of _node_exporter_. However, all networks could be set as _network_mode: host_ for simplicity, and on other devices that aren't resolvable on the Prometheus/Grafana node.

Note that the architecture of Prometheus and Node Exporter are set as an "ARCH" argument defined in each _Dockerfile.template_. This should be updated with the appropriate version for your architecture. RPi 3 requires _armv7_. Pi4 and NUC devices should use _arm64_. 

In order to add monitoring of other devices, add the following to its separate _docker-compose.yml_ file:

```
# Add Node Exporter to this app    
  node_exporter:
    build: ./node_exporter
    ports:
      - "9100:9100"
    network_mode: host
    container_name: node_exporter
```
Secondly, add the ./node_exporter folder to that application, with a Dockerfile.template that looks like this:

```
FROM balenalib/%%BALENA_MACHINE_NAME%%-debian:stretch

ARG ARCH="armv7"

RUN install_packages apt-utils wget tar gzip

RUN export DEBIAN_FRONTEND=noninteractive && \
    wget -qO - https://github.com/prometheus/node_exporter/releases/download/v0.18.1/node_exporter-0.18.1.linux-${ARCH}.tar.gz > node_exporter.tar.gz && \
    tar zxf node_exporter.tar.gz && \
    mv node_exporter-* node_exporter && \
    cp node_exporter/node_exporter /bin 

EXPOSE      9100

CMD  [ "/bin/node_exporter" ]
```
Be sure to adjust the _armv7_ ARG to suit your device.

### Deploy
Clone this repository, change into the balenaLamp directory and push to your application:

```
 $ git clone git@github.com:jtonello/balena-dashboard.git
 $ cd balena-dashboard
 $ balena push <appname>
```


