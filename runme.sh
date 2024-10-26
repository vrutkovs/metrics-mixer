#!/bin/bash
podman run -d --name=metrics --rm \
  -p 8428:8428 \
  -v $(pwd)/data:/storage
  -ti dockervictoriametrics/victoria-metrics:v1.105.0

echo "Open https://localhost:8428/ui"
