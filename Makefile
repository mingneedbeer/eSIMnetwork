.PHONY: all init keys deploy start stop logs status clean

# ─── Colors ──────────────────────────────────────────
GREEN := \033[0;32m
BLUE := \033[0;34m
NC := \033[0m

all: init

## init       - Full initialization (keys → deploy → start)
init:
	@echo "$(BLUE)>>> Initializing eSIM Network...$(NC)"
	@bash scripts/init.sh

## keys       - Generate fresh keys and .env file
keys:
	@echo "$(BLUE)>>> Generating keys...$(NC)"
	@bash scripts/keys.sh
	@echo "$(GREEN)Done! Edit .env with your L1_RPC_URL.$(NC)"

## deploy     - Deploy L1 contracts and generate rollup config
deploy:
	@echo "$(BLUE)>>> Deploying L1 contracts...$(NC)"
	@bash scripts/deploy.sh
	@echo "$(GREEN)Deployment complete!$(NC)"

## start      - Start all rollup services (op-geth, op-node, op-batcher, op-proposer, op-challenger)
start:
	@echo "$(BLUE)>>> Starting eSIM Network rollup...$(NC)"
	@docker compose -f docker/docker-compose.yml up -d
	@echo "$(GREEN)Rollup started! L2 RPC: http://localhost:8545$(NC)"

## stop       - Stop all rollup services
stop:
	@echo "$(BLUE)>>> Stopping eSIM Network rollup...$(NC)"
	@docker compose -f docker/docker-compose.yml down
	@echo "$(GREEN)Rollup stopped.$(NC)"

## logs       - Tail logs from all services
logs:
	@docker compose -f docker/docker-compose.yml logs -f

## status     - Health check
status:
	@bash scripts/check.sh

## clean      - Remove all data and reset
clean:
	@echo "$(BLUE)>>> Cleaning up...$(NC)"
	@docker compose -f docker/docker-compose.yml down -v 2>/dev/null || true
	@rm -rf data/ config/jwt.txt config/genesis.json config/rollup.json config/*/deployments.json
	@echo "$(GREEN)Clean complete.$(NC)"

## help       - Show this help
help:
	@grep -E '^## ' $(MAKEFILE_LIST) | sed 's/## /  /'
