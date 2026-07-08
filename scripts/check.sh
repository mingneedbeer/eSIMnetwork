#!/usr/bin/env bash
set -euo pipefail

# Health check script for eSIM Network L2

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "=== eSIM Network: Health Check ==="
echo ""

# Check Docker containers
echo "Docker Containers:"
docker ps --filter "name=esim-*" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo "  No containers running"
echo ""

# Check L2 RPC
echo "L2 RPC (localhost:8545):"
if curl -s -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"eth_blockNumber","params":[]}' > /dev/null 2>&1; then
  BLOCK_NUM=$(curl -s -X POST http://localhost:8545 \
    -H "Content-Type: application/json" \
    -d '{"jsonrpc":"2.0","id":1,"method":"eth_blockNumber","params":[]}' | \
    python3 -c "import sys,json; print(int(json.load(sys.stdin)['result'],16))" 2>/dev/null || echo "parsing failed")
  echo "  Status: RUNNING"
  echo "  Latest Block: ${BLOCK_NUM:-checking...}"
else
  echo "  Status: NOT RESPONDING"
fi
echo ""

# Check Chain ID
echo "L2 Chain ID:"
CHAIN_ID=$(curl -s -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"eth_chainId","params":[]}' | \
  python3 -c "import sys,json; print(int(json.load(sys.stdin)['result'],16))" 2>/dev/null || echo "unknown")
echo "  $CHAIN_ID"
echo ""

# Check syncing
echo "Sync Status:"
SYNCING=$(curl -s -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"eth_syncing","params":[]}' | \
  python3 -c "import sys,json; s=json.load(sys.stdin)['result']; print(s if s!=False else 'Synced')" 2>/dev/null || echo "unknown")
echo "  $SYNCING"
echo ""

echo "=== Done ==="
