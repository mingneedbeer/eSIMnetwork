#!/usr/bin/env bash
set -euo pipefail

# Generate all required keys for the L2 rollup
# Outputs to .env file

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
ENV_FILE="$PROJECT_DIR/.env"

echo "=== eSIM Network: Key Generation ==="

# Generate admin key (for L1 contract deployment)
echo "Generating admin key..."
ADMIN_KEY=$(openssl rand -hex 32)
ADMIN_ADDR=$(cast wallet addr --private-key "0x$ADMIN_KEY" 2>/dev/null || echo "REQUIRES_FOUNDRY")

# Generate sequencer key
echo "Generating sequencer key..."
SEQ_KEY=$(openssl rand -hex 32)

# Generate batcher key
echo "Generating batcher key..."
BATCH_KEY=$(openssl rand -hex 32)

# Generate proposer key
echo "Generating proposer key..."
PROP_KEY=$(openssl rand -hex 32)

# Generate challenger key
echo "Generating challenger key..."
CHAL_KEY=$(openssl rand -hex 32)

# Generate P2P node key
echo "Generating P2P node key..."
P2P_KEY=$(openssl rand -hex 32)

cat > "$ENV_FILE" << EOF
# eSIM Network - Generated Keys
# Created: $(date)
# WARNING: These keys are for development only!

# Deployment Environment
DEPLOYMENT_ENV=sepolia

# L1 RPC (Sepolia testnet)
L1_RPC_URL=https://sepolia.infura.io/v3/YOUR_INFURA_KEY

# Generated Private Keys
GS_ADMIN_PRIVATE_KEY=0x$ADMIN_KEY
# Admin Address: $ADMIN_ADDR

SEQUENCER_PRIVATE_KEY=0x$SEQ_KEY
BATCHER_PRIVATE_KEY=0x$BATCH_KEY
PROPOSER_PRIVATE_KEY=0x$PROP_KEY
CHALLENGER_PRIVATE_KEY=0x$CHAL_KEY

# Chain Configuration
L2_CHAIN_ID=12345
L2_BLOCK_TIME=2
L2_CHAIN_NAME=eSIM Network

# Deployment salt - CHANGE for redeployments
IMPL_SALT=0x$(openssl rand -hex 32)
EOF

# Save P2P key separately
echo "$P2P_KEY" > "$PROJECT_DIR/config/p2p-node-key.txt"

echo ""
echo "Keys generated and saved to .env"
echo ""
echo "NEXT STEPS:"
echo "  1. Edit .env and set L1_RPC_URL with your Infura/Alchemy URL"
echo "  2. Fund the admin address: $ADMIN_ADDR"
echo "     with ~2-3 Sepolia ETH from a faucet"
echo "  3. Run: make deploy"
echo ""
