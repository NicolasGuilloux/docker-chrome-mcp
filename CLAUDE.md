# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Docker-based browser automation platform combining:
- **KasmVNC**: Web-based desktop (ports 3000/3001)
- **Playwright MCP Server**: MCP server for AI-driven browser automation (port 3002)
- **Google Chrome**: With CDP enabled (port 9222)

There is no Node.js application or build system — all work involves Docker, shell scripts, and config files.

## Build & Run

```bash
# Build the image
docker build -t chrome-mcp .

# Run with Compose
docker compose up -d
docker compose down
```

## Architecture

**Startup sequence:**
1. KasmVNC base image initializes the desktop environment
2. `root/defaults/chrome-start` launches Chrome with CDP on internal port 9223
3. `socat` tunnels port 9222 → 9223
4. `root/defaults/autostart` starts the Playwright MCP server via `npx @playwright/mcp`
5. MCP server connects to Chrome via `http://localhost:9222`

**Port mapping:**
| Port | Service |
|------|---------|
| 3000/3001 | KasmVNC web desktop |
| 3002 | Playwright MCP server (HTTP/SSE) |
| 9222 | Chrome CDP (exposed via socat) |

**Volume mount:** `/config` on host maps to `/config` in container, providing:
- `config.json` — MCP server configuration
- `output/` — automation results
- `chrome-data/` — Chrome user profile

## Key Files

- `Dockerfile` — builds from `ghcr.io/linuxserver/baseimage-kasmvnc:debianbookworm`, installs Node 20, Playwright, Chrome, and `@playwright/mcp`
- `docker-compose.yml` — includes GPU device passthrough (`/dev/dri`) and NVIDIA capabilities
- `root/defaults/chrome-start` — Chrome startup script; conditionally applies GPU flags based on `DISABLE_GPU_ACCELERATION` env var
- `root/defaults/autostart` — KasmVNC autostart; launches MCP server
- `root/config/config.json` — MCP server config (browser CDP endpoint, server host/port, capabilities, output dir)

## GPU Acceleration

GPU is enabled by default using `--use-gl=angle --use-angle=gl-egl`. Set `DISABLE_GPU_ACCELERATION=true` to disable. The compose file maps `/dev/dri` and declares NVIDIA capabilities.

