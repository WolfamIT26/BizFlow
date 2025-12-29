#!/usr/bin/env bash
set -euo pipefail

# Simple login test comparing Gateway vs direct Backend
# Usage:
#   USERNAME=admin PASSWORD=your_password bash scripts/login_test.sh

USERNAME="${USERNAME:-}"
PASSWORD="${PASSWORD:-}"

if [[ -z "$USERNAME" || -z "$PASSWORD" ]]; then
  echo "Usage: USERNAME=<user> PASSWORD=<pass> bash scripts/login_test.sh"
  exit 1
fi

JSON_PAYLOAD=$(jq -nc --arg u "$USERNAME" --arg p "$PASSWORD" '{username:$u, password:$p}')

echo "\nTesting via Gateway (http://localhost:8000/api/auth/login)"
HTTP_CODE_GW=$(curl -s -o /tmp/gateway_body.json -w "%{http_code}" -H "Content-Type: application/json" -d "$JSON_PAYLOAD" http://localhost:8000/api/auth/login)
HEADERS_GW=$(curl -s -D - -o /dev/null -H "Content-Type: application/json" -d "$JSON_PAYLOAD" http://localhost:8000/api/auth/login | tr -d '\r')

echo "Status: $HTTP_CODE_GW"
echo "Key headers (Gateway):"
printf "%s\n" "$HEADERS_GW" | grep -E '(^HTTP/|^server:|^via:|^access-control-allow-origin:|^date:)' || true

echo "\nTesting direct Backend (http://localhost:8080/api/auth/login)"
HTTP_CODE_BE=$(curl -s -o /tmp/backend_body.json -w "%{http_code}" -H "Content-Type: application/json" -d "$JSON_PAYLOAD" http://localhost:8080/api/auth/login)
HEADERS_BE=$(curl -s -D - -o /dev/null -H "Content-Type: application/json" -d "$JSON_PAYLOAD" http://localhost:8080/api/auth/login | tr -d '\r')

echo "Status: $HTTP_CODE_BE"
echo "Key headers (Backend):"
printf "%s\n" "$HEADERS_BE" | grep -E '(^HTTP/|^server:|^via:|^access-control-allow-origin:|^date:)' || true

echo "\nDifferences:" 
if [[ "$HTTP_CODE_GW" != "$HTTP_CODE_BE" ]]; then
  echo "- Different status codes: Gateway=$HTTP_CODE_GW, Backend=$HTTP_CODE_BE"
fi
# Show if CORS headers differ
GW_CORS=$(printf "%s\n" "$HEADERS_GW" | grep -i '^access-control-allow-origin:' | awk '{print $2}')
BE_CORS=$(printf "%s\n" "$HEADERS_BE" | grep -i '^access-control-allow-origin:' | awk '{print $2}')
if [[ "$GW_CORS" != "$BE_CORS" ]]; then
  echo "- CORS header differs: Gateway=$GW_CORS, Backend=$BE_CORS"
fi
# Presence of Via header (often set by proxies)
if printf "%s\n" "$HEADERS_GW" | grep -qi '^via:'; then
  echo "- 'Via' header present via Gateway (request passed through proxy)"
fi

echo "\nBodies saved to:"
echo "- /tmp/gateway_body.json"
echo "- /tmp/backend_body.json"

echo "\nTip: In another terminal, run:"
echo "  docker logs bizflow-gateway -f"
echo "  docker logs bizflow-backend -f"
