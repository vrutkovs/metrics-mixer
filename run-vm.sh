#!/bin/bash
podman run -d --name=metrics --rm \
  -p 8428:8428 \
  -v $(pwd)/data:/storage:z \
  -ti docker.io/victoriametrics/victoria-metrics:v1.105.0 \
  --storageDataPath=/storage \
  --httpListenAddr=:8428

echo "VictoriaMetrics listening at http://localhost:8428/vmui"
