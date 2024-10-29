#!/bin/bash
podman run -d --name=metrics --rm \
  -p 8428:8428 \
  -v $(pwd)/data:/storage:z \
  -ti docker.io/victoriametrics/victoria-metrics:v1.105.0 \
  --storageDataPath=/storage \
  --httpListenAddr=:8428

echo "VictoriaMetrics listening at http://localhost:8428/vmui"

podman run -d --name grafana --user=0 --rm -p 3000:3000 \
  -e GF_INSTALL_PLUGINS="https://github.com/VictoriaMetrics/victoriametrics-datasource/releases/download/v0.9.1/victoriametrics-datasource-v0.9.1.zip;victoriametrics-datasource" \
  -v $(pwd)/grafana/data:/var/lib/grafana:Z \
  -v $(pwd)/grafana/grafana.ini:/etc/grafana/grafana.ini:Z \
  -v $(pwd)/grafana/provisioning:/etc/grafana/provisioning:Z \
  -ti docker.io/grafana/grafana:latest
