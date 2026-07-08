#!/usr/bin/env bash
set -euo pipefail

# Deploy L1 smart contracts for the eSIM Network L2 rollup
# Uses op-deployer from the optimism monorepo

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Load environment
source "$PROJECT_DIR/.env" 2>/dev/null || {
  echo "ERROR: .env file not found. Run scripts/keys.sh first."
  exit 1
}

echo "=== eSIM Network: L1 Contract Deployment ==="
echo "Network: ${DEPLOYMENT_ENV:-sepolia}"
echo "L1 RPC: ${L1_RPC_URL}"
echo ""

# Check dependencies
command -v op-deployer >/dev/null 2>&1 || {
  echo "ERROR: op-deployer not found."
  echo "Install it from: https://github.com/ethereum-optimism/optimism"
  echo "Or run: go install github.com/ethereum-optimism/optimism/op-deployer/cmd/op-deployer@latest"
  exit 1
}

# Step 1: Deploy L1 contracts
echo "Step 1: Deploying L1 contracts..."

DEPLOY_DIR="$PROJECT_DIR/config/$DEPLOYMENT_ENV"

op-deployer deploy \
  --l1-rpc-url "$L1_RPC_URL" \
  --private-key "$GS_ADMIN_PRIVATE_KEY" \
  --deploy-config "$DEPLOY_DIR/deploy-config.json" \
  --outfile "$DEPLOY_DIR/deployments.json" \
  --salt "$IMPL_SALT"

echo "L1 contracts deployed successfully!"
echo ""

# Step 2: Generate rollup config
echo "Step 2: Generating rollup configuration..."

op-deployer genesis \
  --deploy-config "$DEPLOY_DIR/deploy-config.json" \
  --l1-deployments "$DEPLOY_DIR/deployments.json" \
  --outfile.l2 "$PROJECT_DIR/config/genesis.json" \
  --outfile.rollup "$PROJECT_DIR/config/rollup.json" \
  --l1-rpc "$L1_RPC_URL"

echo "Rollup configuration generated!"
echo ""

# Step 3: Generate JWT secret
echo "Step 3: Generating JWT authentication secret..."

if [ ! -f "$PROJECT_DIR/config/jwt.txt" ]; then
  openssl rand -hex 32 > "$PROJECT_DIR/config/jwt.txt"
  echo "JWT secret created at config/jwt.txt"
else
  echo "JWT secret already exists, skipping..."
fi

echo ""
echo "=== Deployment Complete ==="
echo ""
echo "Next steps:"
echo "  1. Review deployed contracts: cat $DEPLOY_DIR/deployments.json"
echo "  2. Start the rollup: docker compose -f docker/docker-compose.yml up -d"
echo "  3. Verify L2: curl http://localhost:8545 -X POST -H 'Content-Type: application/json' -d '{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"eth_chainId\",\"params\":[]}'"
echo ""
