# Chrome MCP Docker Container

A Docker container that provides a web-based desktop environment with Playwright MCP (Model Context Protocol) server for browser automation.

## Overview

This container combines:
- **KasmVNC**: Web-accessible Linux desktop environment
- **Playwright MCP Server**: Browser automation through Model Context Protocol
- **Chrome Browser**: For automation and manual use, with the debugging port exposed

## Features

- **x86_64 Architecture**: Built for amd64/x86_64 platforms (Chrome requirement)
- **Web-based desktop**: Accessible through any browser to see Chrome sessions
- **Playwright MCP server**: Running on port 3002
- **Chrome CDP**: Running on port 9222
- **PDF and vision capabilities**: Built-in support
- **Structured browser automation**: Without screenshots
- **Output directory**: For saving results

## Quick Start

### Pull Pre-built Container (Recommended)

The container is automatically built for x86_64 architecture and published to GitHub Container Registry:

```bash
docker pull ghcr.io/nicolasguilloux/docker-chrome-mcp:latest
```

### Run the COntainer

```bash
docker run -d \
  --name docker-chrome-mcp \
  -p 3000:3000 \
  -p 3001:3001 \
  -p 3002:3002 \
  -p 9222:9222 \
  -v $(pwd)/chrome-data:/config/chrome-data \
  ghcr.io/bradsjm/chrome-mcp:latest
```

### Build Locally (Optional)

```bash
docker build -t chrome-mcp .
```

## Usage

1. Access the web desktop at `http://localhost:3000` or `https://localhost:3001`
2. Configure your MCP client to connect to the server (see above)
3. Use browser automation through your preferred MCP client
4. Use the 9222 port to access directly the debugging websocket
5. Outputs are saved to the mounted output directory

### MCP Server

The Playwright MCP server is available at `http://localhost:3002` and automatically starts when the container launches. It supports both SSE and streaming HTTP protocols.

For most MCP clients, add this configuration to connect to the containerized server:

- SSE: `http://localhost:3002/sse`
- Streaming HTTP: `http://localhost:3002/mcp`

### Chrome DevTools Protocol (CDP) Support

Chrome automatically starts with CDP enabled on port 9222. The MCP server connects to this CDP endpoint, allowing for:

- Direct browser automation via CDP
- Integration with external tools that support CDP
- Enhanced debugging capabilities

The CDP endpoint is accessible at `http://localhost:9222` when the container is running.

## Configuration

The MCP server configuration is located at `/config/config.json`:

- **Port**: 3002
- **Browser**: Chrome (non-headless)
- **Capabilities**: PDF and vision support
- **Output Directory**: `/config/output`

## Architecture

- **Base Image**: `ghcr.io/linuxserver/baseimage-kasmvnc:debianbookworm`
- **MCP Server**: `@playwright/mcp@latest`
- **Browser**: Chrome with Playwright

## Development

The container includes:
- Playwright browsers installed with dependencies
- MCP server auto-start configuration
- Chrome browser started at the beginning with CDP support

## Container Registry

Pre-built container images are available at:
- **Registry**: `ghcr.io/nicolasguilloux/docker-chrome-mcp`
- **Supported Architecture**: linux/amd64 (x86_64 only - Chrome requirement)
- **Tags**: `latest`, `main`, version tags

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
