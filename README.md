# eSIM Network L2 Rollup

A custom Ethereum Layer 2 rollup built with the **OP Stack**, inspired by [Abstract Network](https://abs.xyz).

| Network | L1 | Chain ID | Status |
|---------|----|----------|--------|
| eSIM Testnet | Sepolia | 12345 | Testnet |
| eSIM Mainnet | Ethereum | TBD | Planned |

## Architecture

The eSIM Network is an **OP Stack rollup** — an EVM-equivalent L2 that batches transactions and posts them to L1 (Ethereum/Sepolia), inheriting Ethereum's security.

```
                    ┌──────────────────────┐
                    │     Ethereum L1       │
                    │  (Mainnet / Sepolia)  │
                    └────┬─────────────┬────┘
                         │             │
                    ┌────▼──┐    ┌─────▼─────┐
                    │Bridge │    │Batch Data  │
                    │Contracts│   │(calldata) │
                    └────┬──┘    └─────┬─────┘
                         │             │
              ┌──────────┴─────────────┴──────────┐
              │         OP Stack Layer 2          │
              │  ┌─────────┐  ┌────────────────┐  │
              │  │op-geth  │  │   op-node      │  │
              │  │(Exec)   │◄─┤ (Consensus)    │  │
              │  └────┬────┘  └───────┬────────┘  │
              │       │               │           │
              │  ┌────▼────┐   ┌──────▼────────┐  │
              │  │op-batcher│   │ op-proposer   │  │
              │  └─────────┘   └───────────────┘  │
              │  ┌──────────────────────────────┐ │
              │  │      op-challenger           │ │
              │  └──────────────────────────────┘ │
              └──────────────────────────────────┘
```

### Components

| Component | Role |
|-----------|------|
| **op-geth** | Execution client — processes L2 transactions, runs EVM |
| **op-node** | Consensus client — derives L2 blocks from L1 data |
| **op-batcher** | Publishes L2 batch data to L1 for data availability |
| **op-proposer** | Submits L2 state roots to L1 (L2OutputOracle) |
| **op-challenger** | Monitors fault proofs and challenges invalid outputs |

### How It Works

1. Users submit transactions to the **Sequencer** (op-node + op-geth)
2. The Sequencer produces L2 blocks every **2 seconds**
3. **op-batcher** compresses blocks and posts them to L1 as calldata
4. **op-proposer** periodically submits the L2 state root to L1
5. Users withdraw funds via the **L1 OptimismPortal** (after the 7-day challenge window on mainnet, instant on testnet)

## Prerequisites

- **Docker** & **Docker Compose** (v2+)
- **Go 1.22+** (for building OP Stack binaries)
- **Foundry** (`cast`, `forge`) — `curl -L https://foundry.paradigm.xyz | sh`
- **Sepolia ETH** (~2-3 ETH from [faucet](https://sepoliafaucet.com/))
- **L1 RPC URL** from [Alchemy](https://alchemy.com), [Infura](https://infura.io), or [QuickNode](https://quicknode.com)

## Quick Start

### 1. Generate Keys

```bash
make keys
```

This creates `.env` with all required private keys and saves the P2P node key.

### 2. Configure Environment

Edit `.env`:

```bash
# Required: set your L1 RPC endpoint
L1_RPC_URL=https://sepolia.infura.io/v3/YOUR_KEY_HERE
```

Fund the admin address (shown after `make keys`) with ~2-3 Sepolia ETH.

### 3. Deploy & Start

```bash
# Deploy L1 contracts and start the rollup
make deploy
make start
```

Or all in one:

```bash
make init
```

### 4. Verify

```bash
make status
```

Check the L2 is running:

```bash
curl http://localhost:8545 -X POST \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"eth_chainId","params":[]}'
# Expected: {"jsonrpc":"2.0","id":1,"result":"0x3039"} (chain ID 12345)
```

## Usage

### Bridge ETH to L2

```bash
# Send ETH from L1 to L2 via the OptimismPortal
cast send $PORTAL_ADDRESS \
  --value 0.1ether \
  --rpc-url $L1_RPC_URL \
  --private-key $GS_ADMIN_PRIVATE_KEY
```

The bridged ETH will appear on L2 automatically.

### Deploy a Contract on L2

```bash
# Using forge to deploy to the L2
forge create Counter \
  --rpc-url http://localhost:8545 \
  --private-key $SEQUENCER_PRIVATE_KEY
```

### Withdraw from L2 to L1

Withdrawals use the standard OP Stack bridge flow:

1. Initiate withdrawal on L2
2. Wait for the output root to be proposed (~30 min on testnet, ~7 days on mainnet)
3. Prove the withdrawal on L1
4. Finalize the withdrawal

## Configuration

### Chain Parameters

| Parameter | Testnet | Mainnet | Description |
|-----------|---------|---------|-------------|
| L1 Network | Sepolia | Ethereum | Underlying L1 |
| L1 Chain ID | 11155111 | 1 | Ethereum chain ID |
| L2 Chain ID | 12345 | TBD | eSIM Network chain ID |
| Block Time | 2s | 2s | L2 block production |
| Batch Submission | ~1 min | ~1 min | Frequency of L1 batch posts |
| Output Submission | ~30 min | ~30 min | Frequency of L2 state roots |
| Withdrawal Delay | ~30 min* | 7 days | Challenge period |

*\*On testnet, the withdrawal delay is configurable — set `finalizationPeriodSeconds` in the deploy config.*

### Deploy Config

Edit `config/testnet/deploy-config.json` (or `config/mainnet/`) to customize:

- **`l2BlockTime`** — L2 block interval (default: 2s)
- **`l2GenesisBlockGasLimit`** — Initial gas limit
- **`finalizationPeriodSeconds`** — Challenge window for withdrawals
- **`l2OutputOracleSubmissionInterval`** — How often state roots are submitted

## Directory Structure

```
esim-network/
├── config/
│   ├── testnet/            # Sepolia deployment config
│   ├── mainnet/            # Ethereum mainnet config
│   ├── genesis.json        # L2 genesis state (generated)
│   ├── rollup.json         # Rollup config (generated)
│   └── jwt.txt             # Auth token (generated)
├── contracts/
│   └── src/                # L1 bridge contracts
├── docker/
│   ├── docker-compose.yml  # Service orchestration
│   ├── op-geth/            # Execution client
│   ├── op-node/            # Consensus client
│   ├── op-batcher/         # Batch submitter
│   ├── op-proposer/        # State proposer
│   └── op-challenger/      # Fault challenger
├── scripts/
│   ├── init.sh             # Full setup
│   ├── deploy.sh           # L1 contract deployment
│   ├── keys.sh             # Key generation
│   └── check.sh            # Health check
├── Makefile                # Command shortcuts
└── .env                    # Configuration (gitignored)
```

## Production Considerations

For mainnet deployment, additional hardening is required:

1. **Key Management** — Use HSM or MPC-based key management for admin keys
2. **Monitoring** — Set up alerting for batcher/proposer failures
3. **Dispute Monitor** — Ensure the challenger is always running
4. **Multi-sig** — Use a Gnosis Safe for proxy admin ownership
5. **Audits** — Full security audit before mainnet launch
6. **Decentralized Sequencing** — Consider shared sequencing for liveness

## Comparison: eSIM Network vs Abstract Network

| Feature | Abstract Network | eSIM Network |
|---------|-----------------|-------------|
| Stack | ZK Stack (ZKsync) | OP Stack (Optimism) |
| Proof System | Zero-Knowledge (ZK) | Optimistic (Fault Proofs) |
| L1 Mainnet | Ethereum | Ethereum |
| L1 Testnet | Sepolia | Sepolia |
| Withdrawal Speed | ~1 hour | ~30 min (testnet) / 7 days (mainnet) |
| EVM Compatibility | Full | Full |
| Consumer Focus | Yes | Configurable |

The eSIM Network chooses the **OP Stack** for its maturity, battle-tested codebase, and ecosystem compatibility (same stack as Base, OP Mainnet, Zora, and Mode).

## License

MIT
