#!/usr/bin/env bash
set -euo pipefail

# Initialize the eSIM Network L2 rollup from scratch
# Full setup: keys -> config -> deploy -> start

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo "╔══════════════════════════════════════════════╗"
echo "║    eSIM Network L2 Rollup - Initialization   ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# Step 1: Generate keys
echo ">>> Step 1/5: Generating keys..."
bash "$SCRIPT_DIR/keys.sh"
echo ""

# Prompt user to edit .env
echo ">>> Step 2/5: Configure environment..."
echo "Please edit .env to set your L1_RPC_URL and fund the admin address."
echo ""
read -rp "Press Enter after you've configured .env and funded the admin address..."
echo ""

# Step 3: Build Docker images
echo ">>> Step 3/5: Building Docker images..."
docker compose -f "$PROJECT_DIR/docker/docker-compose.yml" build
echo ""

# Step 4: Deploy L1 contracts
echo ">>> Step 4/5: Deploying L1 contracts..."
bash "$SCRIPT_DIR/deploy.sh"
echo ""

# Step 5: Start the rollup
echo ">>> Step 5/5: Starting the rollup..."
docker compose -f "$PROJECT_DIR/docker/docker-compose.yml" up -d
echo ""

echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║       eSIM Network is now running!           ║"
echo "╚══════════════════════════════════════════════╝"
echo ""
echo "  L2 RPC:       http://localhost:8545"
echo "  L2 Chain ID:  ${L2_CHAIN_ID:-12345}"
echo "  L1 Network:   ${DEPLOYMENT_ENV:-sepolia}"
echo ""
echo "View logs:    docker compose -f docker/docker-compose.yml logs -f"
echo "Stop:         docker compose -f docker/docker-compose.yml down"
echo ""
