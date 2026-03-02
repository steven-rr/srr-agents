#!/usr/bin/env bash
set -euo pipefail

# ╔══════════════════════════════════════════════════════════════════════╗
# ║  SRR-AGENTS — Setup Script                                         ║
# ║  Sets up the agent empire in Docker with OpenClaw                   ║
# ╚══════════════════════════════════════════════════════════════════════╝

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}"
echo "  ╔═══════════════════════════════════════╗"
echo "  ║       SRR-AGENTS Empire Setup         ║"
echo "  ║    Orchestrator + Builder + Scout +    ║"
echo "  ║              Intel                     ║"
echo "  ╚═══════════════════════════════════════╝"
echo -e "${NC}"

# ── Pre-flight checks ───────────────────────────────────────────────
echo -e "${YELLOW}[1/5] Pre-flight checks...${NC}"

if ! command -v docker &>/dev/null; then
  echo -e "${RED}Error: Docker is not installed. Install Docker Desktop first.${NC}"
  echo "  → https://docs.docker.com/desktop/install/mac-install/"
  exit 1
fi

if ! docker info &>/dev/null; then
  echo -e "${RED}Error: Docker daemon is not running. Start Docker Desktop.${NC}"
  exit 1
fi

if ! command -v docker compose &>/dev/null && ! docker compose version &>/dev/null 2>&1; then
  echo -e "${RED}Error: Docker Compose is not available.${NC}"
  exit 1
fi

echo -e "${GREEN}  Docker and Compose are ready.${NC}"

# ── Environment setup ───────────────────────────────────────────────
echo -e "${YELLOW}[2/5] Environment configuration...${NC}"

if [ ! -f .env ]; then
  cp .env.example .env
  echo -e "${CYAN}  Created .env from .env.example${NC}"
  echo -e "${RED}  ⚠ You MUST edit .env and add your API keys before starting!${NC}"
  echo ""
  echo "  Required keys:"
  echo "    ANTHROPIC_API_KEY  — Get from https://console.anthropic.com/"
  echo "    GITHUB_TOKEN       — Get from https://github.com/settings/tokens"
  echo ""
  read -p "  Would you like to edit .env now? (y/n) " -n 1 -r
  echo ""
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    ${EDITOR:-nano} .env
  fi
else
  echo -e "${GREEN}  .env already exists.${NC}"
fi

# Validate required keys
source .env 2>/dev/null || true
if [ -z "${ANTHROPIC_API_KEY:-}" ] || [ "${ANTHROPIC_API_KEY}" = "sk-ant-xxxxx" ]; then
  echo -e "${RED}  ⚠ ANTHROPIC_API_KEY is not set. Edit .env before running 'docker compose up'.${NC}"
fi

# ── Create workspace directories ────────────────────────────────────
echo -e "${YELLOW}[3/5] Creating workspace directories...${NC}"

mkdir -p workspace/{repos,reports/{builder,scout},digests,docs}
echo -e "${GREEN}  workspace/repos/       — cloned repositories${NC}"
echo -e "${GREEN}  workspace/reports/     — agent reports${NC}"
echo -e "${GREEN}  workspace/digests/     — daily intel digests${NC}"
echo -e "${GREEN}  workspace/docs/        — generated documentation${NC}"

# ── Build the image ─────────────────────────────────────────────────
echo -e "${YELLOW}[4/5] Building Docker image...${NC}"

docker compose build srr-gateway
echo -e "${GREEN}  Image built successfully.${NC}"

# ── Onboard and start ───────────────────────────────────────────────
echo -e "${YELLOW}[5/5] Starting SRR-AGENTS...${NC}"

echo ""
echo -e "${GREEN}Setup complete! To start the empire:${NC}"
echo ""
echo "  # Start the gateway (background)"
echo "  docker compose up -d srr-gateway"
echo ""
echo "  # Interact via CLI"
echo "  docker compose run --rm srr-cli chat"
echo ""
echo "  # Check agent health"
echo "  curl -s http://localhost:18789/healthz"
echo ""
echo "  # View logs"
echo "  docker compose logs -f srr-gateway"
echo ""
echo "  # Stop everything"
echo "  docker compose down"
echo ""
echo -e "${CYAN}Agent Empire Structure:${NC}"
echo "  Orchestrator (central command)"
echo "    ├── Builder  (code review, GitHub, docs)"
echo "    ├── Scout    (job market intelligence)"
echo "    └── Intel    (AI & aerospace news)"
echo ""
echo -e "${YELLOW}Scheduled tasks:${NC}"
echo "  Daily  7:00 AM — Intel morning digest"
echo "  Monday 7:00 AM — Scout weekly job pulse"
echo "  Monday 9:00 AM — Builder weekly code review"
echo ""
