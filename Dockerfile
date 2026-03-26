FROM ghcr.io/linuxserver/baseimage-kasmvnc:debianbookworm

RUN apt update && \
    apt install -y \
        socat \
        libdrm2 \
        libdrm-amdgpu1 \
        libdrm-intel1 \
        libdrm-nouveau2 \
        libdrm-radeon1 \
        libgbm1 \
        libegl1 \
        libegl-mesa0 \
        libgl1-mesa-dri \
        mesa-utils \
        mesa-vulkan-drivers \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Configure KASM VNC
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV TITLE=Playwright
ENV START_DOCKER=false
ENV NO_DECOR=true

# Suppress Chrome/DBus errors
ENV CHROME_DEVEL_SANDBOX=/usr/local/sbin/chrome-devel-sandbox
ENV DISPLAY=:1

# Use ARGs for versions to make updates easy and explicit
ARG UV_VERSION=0.8.3
ARG NODE_VERSION=20.x
ARG DEBIAN_FRONTEND=noninteractive
ENV PLAYWRIGHT_BROWSERS_PATH=/app/playwright-browsers

# Disable NPM update check
RUN npm config set update-notifier false > /dev/null

# Install playright and browser dependencies in one layer
RUN npx playwright install --with-deps chrome && \
    npm cache clean --force 

# Install MCP support
RUN npm install -g @playwright/mcp@latest && \
    npm cache clean --force 


# Grant the abc user (uid 911) access to DRI devices at runtime via video/render groups
RUN groupadd -f --gid 44 video2 || true && \
    groupadd -f --gid 104 render || true && \
    usermod -aG video,render abc 2>/dev/null || true

# Copy files
COPY /src/playwright-config.json /config/config.json
COPY /src/openbox /defaults

# Ensure abc owns its runtime directories
RUN mkdir -p /config/{chrome-data,output} && \
    chown -R 911:911 /config

# Fix ownership of Chrome dirs at container startup, after PUID/PGID are resolved
RUN mkdir -p /custom-cont-init.d && \
    printf '#!/bin/bash\nchown -R abc:abc /config/chrome-data /config/output\n' \
    > /custom-cont-init.d/10-chrome-perms && \
    chmod +x /custom-cont-init.d/10-chrome-perms

EXPOSE 3002 9222
