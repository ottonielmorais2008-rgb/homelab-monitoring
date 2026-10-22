#!/usr/bin/env bash
# Copy the Uptime Kuma data volume to backups/uptime-kuma-<timestamp>.tar.gz.
# The service is stopped for the copy so the SQLite database is not mid-write,
# then started again. The volume name matches docker-compose.yml.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT}"

VOLUME_NAME="homelab-monitoring-data"
IMAGE="louislam/uptime-kuma:2"
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
OUT_DIR="${ROOT}/backups"
ARCHIVE_NAME="uptime-kuma-${STAMP}.tar.gz"

if ! command -v docker >/dev/null 2>&1; then
  echo "docker is required." >&2
  exit 1
fi

if ! docker info >/dev/null 2>&1; then
  echo "Docker is installed but the daemon is not running." >&2
  exit 1
fi

if ! docker volume inspect "${VOLUME_NAME}" >/dev/null 2>&1; then
  echo "Volume ${VOLUME_NAME} does not exist. Start the stack with: docker compose up -d" >&2
  exit 1
fi

restart=0
if [[ -n "$(docker compose ps --status running -q uptime-kuma)" ]]; then
  restart=1
  docker compose stop uptime-kuma
fi

cleanup() {
  status=$?
  trap - EXIT
  if [[ "${restart}" -eq 1 ]]; then
    docker compose start uptime-kuma || status=1
  fi
  exit "${status}"
}
trap cleanup EXIT

mkdir -p "${OUT_DIR}"

docker run --rm \
  --entrypoint tar \
  -v "${VOLUME_NAME}:/data:ro" \
  -v "${OUT_DIR}:/backup" \
  "${IMAGE}" \
  -czf "/backup/${ARCHIVE_NAME}" -C /data .

echo "Backup written to ${OUT_DIR}/${ARCHIVE_NAME}"
