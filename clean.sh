#!/bin/sh

set -e

SCRIPT_DIR=$(cd "$(dirname $0)" ; pwd -P)

rm -rf "$SCRIPT_DIR/main.db.meta.json"
rm -rf "$SCRIPT_DIR/scan-logs"
rm -rf "$SCRIPT_DIR/main.db"
rm -rf "$SCRIPT_DIR/staging"