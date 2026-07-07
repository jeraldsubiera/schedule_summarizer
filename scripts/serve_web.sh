#!/usr/bin/env bash
set -euo pipefail

echo "Building Flutter web..."
flutter build web

PORT=8080
DIR="build/web"

if [ ! -d "$DIR" ]; then
  echo "Error: $DIR not found. Did the build fail?"
  exit 1
fi

echo "Serving $DIR at http://localhost:$PORT"
python3 -m http.server --directory "$DIR" $PORT
