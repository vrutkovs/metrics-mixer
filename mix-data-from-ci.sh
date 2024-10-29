#!/bin/bash -eux

# METRICS_TAR_URL="https://gcsweb-ci.apps.ci.l2s4.p1.openshiftapps.com/gcs/test-platform-results/logs/periodic-ci-openshift-release-master-nightly-4.17-e2e-aws-ovn-serial/1849892511611359232/artifacts/e2e-aws-ovn-serial/gather-extra/artifacts/metrics/prometheus.tar"
# EXTRALABEL="4.17.0-0.nightly-2024-10-25-190949"
METRICS_TAR_URL="${1}"
EXTRALABEL="${2}"
if [[ -z ${METRICS_TAR_URL} || -z ${EXTRALABEL} ]]; then
  echo "Usage: ./mix-data-from-ci.sh <url to metrics.tar> <prowjob label value>"
  exit 1
fi

# cleanup
podman rm -f prometheus || true
git clean -xf prom/

# copy files to prom here
curl -o /tmp/prom_dump.tar.gz ${METRICS_TAR_URL}
tar -xzf /tmp/prom_dump.tar.gz -C prom

podman run --rm -d -v $(pwd)/prom:/prometheus:Z --name prometheus --user=0 --network=host docker.io/prom/prometheus:main --config.file=/prometheus/prometheus.yaml --storage.tsdb.path=/prometheus --storage.tsdb.retention.time=1000d --web.enable-admin-api
until curl -XPOST localhost:9090/api/v1/admin/tsdb/snapshot; do
    printf '.'
    sleep 5
done
podman rm -f prometheus

# Find snapshot name
SNAPSHOT_NAME=$(/bin/ls prom/snapshots)
vmctl prometheus --verbose \
  --prom-snapshot=prom/snapshots/${SNAPSHOT_NAME} \
  --vm-concurrency=10 \
  --vm-batch-size=200000 \
  --prom-concurrency=10 \
  --vm-extra-label prowjob=${EXTRALABEL}

echo "Grafana running on http://localhost:3000, login as admin/admin"
