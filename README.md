# SRR-AGENTS

An autonomous agent empire powered by [OpenClaw](https://openclaw.ai/) and Claude, running safely in Docker.

## Architecture

```
┌─────────────────────────────────────────────┐
│              Docker Container               │
│                                             │
│  ┌───────────────────────────────────────┐  │
│  │          SRR Orchestrator             │  │
│  │      (routes + coordinates)           │  │
│  └──────┬──────────┬──────────┬──────────┘  │
│         │          │          │              │
│  ┌──────▼──┐ ┌─────▼────┐ ┌──▼───────┐     │
│  │ Builder │ │  Scout   │ │  Intel   │     │
│  │         │ │          │ │          │     │
│  │ Code    │ │ Jobs &   │ │ arXiv    │     │
│  │ Review  │ │ Career   │ │ HN       │     │
│  │ GitHub  │ │ Aero +   │ │ GitHub   │     │
│  │ Docs    │ │ Software │ │ News     │     │
│  │ Vulns   │ │ Trends   │ │ Digest   │     │
│  └─────────┘ └──────────┘ └──────────┘     │
│                                             │
│  ┌───────────────────────────────────────┐  │
│  │  ./workspace (mounted volume)         │  │
│  │  Only host directory agents can touch │  │
│  └───────────────────────────────────────┘  │
└─────────────────────────────────────────────┘
```

## Quick Start

```bash
# 1. Run setup
./setup.sh

# 2. Edit .env with your API keys
nano .env

# 3. Start the empire
docker compose up -d srr-gateway

# 4. Chat with the orchestrator
docker compose run --rm srr-cli chat
```

## Agents

| Agent | Purpose | Schedule |
|-------|---------|----------|
| **Orchestrator** | Routes tasks, coordinates agents, synthesizes results | Always on |
| **Builder** | Code review, GitHub ops, README generation, dependency scanning | Weekly (Monday 9AM) |
| **Scout** | Aerospace + software job search, career trajectory analysis | Weekly (Monday 7AM) |
| **Intel** | AI & aerospace news from arXiv, HN, GitHub trending | Daily (7AM) |

## Usage Examples

```
# Morning briefing
"What's new today?"

# Code review
"Review my GitHub repos for issues"

# Job search
"What aerospace software jobs are out there?"

# Career advice
"Compare aerospace vs software career paths for me"

# Full status
"Give me a full status report from all agents"
```

## Project Structure

```
srr-agents/
├── docker-compose.yml      # Container orchestration
├── Dockerfile              # Image with git, gh, python, etc.
├── setup.sh                # One-command setup
├── .env                    # API keys (git-ignored)
├── config/
│   └── openclaw.json       # Agent definitions + scheduling
├── skills/
│   ├── orchestrator/       # Task routing + coordination
│   ├── builder/            # Code review workflows
│   ├── scout/              # Job market intelligence
│   └── intel/              # News monitoring + digests
└── workspace/              # Mounted volume (agent output)
    ├── repos/              # Cloned repositories
    ├── reports/            # Agent reports
    ├── digests/            # Daily intel digests
    └── docs/               # Generated documentation
```

## Adding New Agents

1. Create a skill directory: `skills/<agent-name>/SKILL.md`
2. Add the agent definition in `config/openclaw.json` under `agents.agents`
3. Update the orchestrator's routing rules in `skills/orchestrator/SKILL.md`
4. Restart: `docker compose restart srr-gateway`

## Safety

- All agents run inside Docker — no host filesystem access except `./workspace`
- Builder agent never pushes to `main` — only creates `srr-builder/*` branches
- API keys stay in `.env` (git-ignored)
- Agent memory persists in a named Docker volume (`srr-agents-home`)
