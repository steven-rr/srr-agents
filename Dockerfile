FROM ghcr.io/openclaw/openclaw:latest

# ── Additional packages for agent capabilities ──────────────────────────
# git: Builder agent needs full git operations
# gh:  GitHub CLI for PR creation, repo crawling
# jq:  JSON processing for API responses
# curl: HTTP requests for news feeds, job APIs
# python3 + pip: scripting for data processing
USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    jq \
    curl \
    python3 \
    python3-pip \
    python3-venv \
    && rm -rf /var/lib/apt/lists/*

# Install GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update && apt-get install -y gh \
    && rm -rf /var/lib/apt/lists/*

# Install Python packages for news/job scraping
RUN python3 -m venv /opt/srr-venv && \
    /opt/srr-venv/bin/pip install --no-cache-dir \
    arxiv \
    requests \
    beautifulsoup4 \
    feedparser \
    pyyaml

ENV PATH="/opt/srr-venv/bin:$PATH"

USER node

# Copy skills and config into the image
COPY --chown=node:node config/openclaw.json /home/node/.openclaw/openclaw.json
COPY --chown=node:node skills/ /home/node/.openclaw/skills/
