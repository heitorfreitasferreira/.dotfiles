---
name: docker-best-practices
description: Comprehensive Docker best practices for images, containers, and production deployments
---

## 🚨 CRITICAL GUIDELINES

### Windows File Path Requirements

**MANDATORY: Always Use Backslashes on Windows for File Paths**

When using Edit or Write tools on Windows, you MUST use backslashes (`\`) in file paths, NOT forward slashes (`/`).

**Examples:**

- ❌ WRONG: `D:/repos/project/file.tsx`
- ✅ CORRECT: `D:\repos\project\file.tsx`

This applies to:

- Edit tool file_path parameter
- Write tool file_path parameter
- All file operations on Windows systems

### Documentation Guidelines

**NEVER create new documentation files unless explicitly requested by the user.**

- **Priority**: Update existing README.md files rather than creating new documentation
- **Repository cleanliness**: Keep repository root clean - only README.md unless user requests otherwise
- **Style**: Documentation should be concise, direct, and professional - avoid AI-generated tone
- **User preference**: Only create additional .md files when user specifically asks for documentation

---

# Docker Best Practices

This skill provides current Docker best practices across all aspects of container development, deployment, and operation.

## When Invoked

1. If the issue requires expertise outside Docker, recommend the right domain expert and stop.
2. Analyze the project's container setup first (Dockerfile(s), Compose files, .dockerignore, current runtime config).
3. Identify the problem category (build, runtime, security, networking, orchestration, dev workflow, performance).
4. Apply the minimal change that fixes the issue while preserving existing conventions.
5. Validate (build, run, health checks, and compose config) and report results.

### Quick Diagnostics

Prefer repository tools (`Read`, `Grep`, `Glob`) for inspecting files; use shell commands only when runtime state is relevant.

```bash
# Docker environment detection
docker --version 2>/dev/null || echo "No Docker installed"
docker info 2>/dev/null | grep -E "Server Version|Storage Driver|Container Runtime" || true
docker context ls 2>/dev/null | head -3 || true

# Container status if running
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}" 2>/dev/null | head -10 || true
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" 2>/dev/null | head -10 || true
```

Validation commands:

```bash
# Build and basic inspection
docker build --no-cache -t test-build .
docker history test-build --no-trunc | head -5

# Compose validation
docker compose config
```

## Image Best Practices

### Base Image Selection

**2025 Recommended Hierarchy:**

1. **Wolfi/Chainguard** (`cgr.dev/chainguard/*`) - Zero-CVE goal, SBOM included
2. **Alpine** (`alpine:3.19`) - ~7MB, minimal attack surface
3. **Distroless** (`gcr.io/distroless/*`) - ~2MB, no shell
4. **Slim variants** (`node:20-slim`) - ~70MB, balanced

**Key rules:**

- Always specify exact version tags: `node:20.11.0-alpine3.19`
- Never use `latest` (unpredictable, breaks reproducibility)
- Use official images from trusted registries
- Match base image to actual needs

### Dockerfile Structure

**Optimal layer ordering** (least to most frequently changing):

```dockerfile
1. Base image and system dependencies
2. Application dependencies (package.json, requirements.txt, etc.)
3. Application code
4. Configuration and metadata
```

**Rationale:** Docker caches layers. If code changes but dependencies don't, cached dependency layers are reused, speeding up builds.

**Example:**

```dockerfile
FROM python:3.12-slim

# 1. System packages (rarely change)
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# 2. Dependencies (change occasionally)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 3. Application code (changes frequently)
COPY . /app
WORKDIR /app

ENTRYPOINT ["python"]
CMD ["app.py"]
```

### Multi-Stage Builds

Use multi-stage builds to separate build dependencies from runtime:

```dockerfile
# Build stage
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Production stage
FROM node:20-alpine AS runtime
WORKDIR /app
# Only copy what's needed for runtime
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
USER node
ENTRYPOINT ["node"]
CMD ["dist/server.js"]
```

For larger apps, prefer a `deps` stage to maximize caching:

```dockerfile
FROM node:20-alpine AS deps
WORKDIR /app
COPY package*.json ./
RUN --mount=type=cache,target=/root/.npm npm ci

FROM node:20-alpine AS build
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npm run build

FROM node:20-alpine AS runtime
WORKDIR /app
RUN addgroup -g 1001 -S app && adduser -S app -u 1001 -G app
COPY --from=deps /app/node_modules ./node_modules
COPY --from=build /app/dist ./dist
USER 1001
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD wget -qO- http://localhost:3000/health >/dev/null 2>&1 || exit 1
ENTRYPOINT ["node"]
CMD ["dist/index.js"]
```

**Benefits:**

- Smaller final images (no build tools)
- Better security (fewer attack vectors)
- Faster deployment (smaller upload/download)

### Layer Optimization

**Combine commands** to reduce layers and image size:

```dockerfile
# Bad - 3 layers, cleanup doesn't reduce size
RUN apt-get update
RUN apt-get install -y curl
RUN rm -rf /var/lib/apt/lists/*

# Good - 1 layer, cleanup effective
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    rm -rf /var/lib/apt/lists/*
```

### ENTRYPOINT and CMD

ENTRYPOINT and CMD define the command that runs when the container starts. They serve distinct semantic roles:

- **ENTRYPOINT** sets the main executable process that always runs
- **CMD** provides default arguments to the ENTRYPOINT process

**Key rules:**

- Always use exec form (`["executable", "arg"]`) — shell form spawns a subprocess (`/bin/sh -c`), breaking PID 1 signal handling and adding overhead
- Override CMD by appending arguments to `docker run`; override ENTRYPOINT via `--entrypoint`
- Without ENTRYPOINT, Docker defaults to `/bin/sh -c`, making it impossible to pass arguments directly to your binary

**Recommended pattern — use both together:**

```dockerfile
ENTRYPOINT ["executable"]
CMD ["default-arg1", "default-arg2"]
```

This lets users run `docker run my-image custom-arg` instead of needing to know the binary path.

**Example:**

```dockerfile
ENTRYPOINT ["python"]
CMD ["app.py"]
```

- `docker run my-image` → `python app.py`
- `docker run my-image other.py` → `python other.py`

**When CMD is used alone (no ENTRYPOINT):**

```dockerfile
CMD ["python", "app.py"]
```

Docker wraps this as `/bin/sh -c "python app.py"`. Users cannot pass arguments directly — `docker run my-image other.py` fails. Always set ENTRYPOINT to your binary and CMD to its default arguments.

### .dockerignore

Always create `.dockerignore` to exclude unnecessary files:

```text
# Version control
.git
.gitignore

# Dependencies
node_modules
__pycache__
*.pyc

# IDE
.vscode
.idea

# OS
.DS_Store
Thumbs.db

# Logs
*.log
logs/

# Testing
coverage/
.nyc_output
*.test.js

# Documentation
README.md
docs/

# Environment
.env
.env.local
*.local
```

## Container Runtime Best Practices

### Security

```bash
docker run \
  # Run as non-root
  --user 1000:1000 \
  # Drop all capabilities, add only needed ones
  --cap-drop=ALL \
  --cap-add=NET_BIND_SERVICE \
  # Read-only filesystem
  --read-only \
  # Temporary writable filesystems
  --tmpfs /tmp:noexec,nosuid \
  # No new privileges
  --security-opt="no-new-privileges:true" \
  # Resource limits
  --memory="512m" \
  --cpus="1.0" \
  my-image
```

### Resource Management

Always set resource limits in production:

```yaml
# docker-compose.yml
services:
  app:
    deploy:
      resources:
        limits:
          cpus: '2.0'
          memory: 1G
        reservations:
          cpus: '1.0'
          memory: 512M
```

### Health Checks

Implement health checks for all long-running containers:

```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --retries=3 --start-period=40s \
  CMD curl -f http://localhost:3000/health || exit 1
```

Or in compose:

```yaml
services:
  app:
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/health"]
      interval: 30s
      timeout: 3s
      retries: 3
      start_period: 40s
```

### Logging

Configure proper logging to prevent disk fill-up:

```yaml
services:
  app:
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

Or system-wide in `/etc/docker/daemon.json`:

```json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
```

### Restart Policies

```yaml
services:
  app:
    # For development
    restart: "no"

    # For production
    restart: unless-stopped

    # Or with fine-grained control (Swarm mode)
    deploy:
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3
        window: 120s
```

## Docker Compose Best Practices

### File Structure

```yaml
# No version field needed (Compose v2.40.3+)

services:
  # Service definitions
  web:
    # ...
  api:
    # ...
  database:
    # ...

networks:
  # Custom networks (preferred)
  frontend:
  backend:
    internal: true

volumes:
  # Named volumes (preferred for persistence)
  db-data:
  app-data:

configs:
  # Configuration files (Swarm mode)
  app-config:
    file: ./config/app.conf

secrets:
  # Secrets (Swarm mode)
  db-password:
    file: ./secrets/db_pass.txt
```

### Network Isolation

```yaml
networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
    internal: true  # No external access

services:
  web:
    networks:
      - frontend

  api:
    networks:
      - frontend
      - backend

  database:
    networks:
      - backend  # Not accessible from frontend
```

### Environment Variables

```yaml
services:
  app:
    # Load from file (preferred for non-secrets)
    env_file:
      - .env

    # Inline for service-specific vars
    environment:
      - NODE_ENV=production
      - LOG_LEVEL=info

    # For Swarm mode secrets
    secrets:
      - db_password
```

**Important:**

- Add `.env` to `.gitignore`
- Provide `.env.example` as template
- Never commit secrets to version control

### Dependency Management

```yaml
services:
  api:
    depends_on:
      database:
        condition: service_healthy  # Wait for health check
      redis:
        condition: service_started   # Just wait for start
```

## Production Best Practices

### Image Tagging Strategy

```bash
# Use semantic versioning
my-app:1.2.3
my-app:1.2
my-app:1
my-app:latest

# Include git commit for traceability
my-app:1.2.3-abc123f

# Environment tags
my-app:1.2.3-production
my-app:1.2.3-staging
```

### Secrets Management

**Never do this:**

```dockerfile
# BAD - secret in layer history
ENV API_KEY=secret123
RUN echo "password" > /app/config
```

**Do this:**

```bash
# Use Docker secrets (Swarm) or external secret management
docker secret create db_password ./password.txt

# Or mount secrets at runtime
docker run -v /secure/secrets:/run/secrets:ro my-app

# Or use environment files (not in image)
docker run --env-file /secure/.env my-app
```

### Monitoring & Observability

```yaml
services:
  app:
    # Health checks
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/health"]
      interval: 30s

    # Labels for monitoring tools
    labels:
      - "prometheus.io/scrape=true"
      - "prometheus.io/port=9090"
      - "com.company.team=backend"
      - "com.company.version=1.2.3"

    # Logging
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

### Backup Strategy

```bash
# Backup named volume
docker run --rm \
  -v VOLUME_NAME:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/backup-$(date +%Y%m%d).tar.gz -C /data .

# Restore volume
docker run --rm \
  -v VOLUME_NAME:/data \
  -v $(pwd):/backup \
  alpine tar xzf /backup/backup.tar.gz -C /data
```

### Update Strategy

```yaml
services:
  app:
    # For Swarm mode - rolling updates
    deploy:
      replicas: 3
      update_config:
        parallelism: 1        # Update 1 at a time
        delay: 10s            # Wait 10s between updates
        failure_action: rollback
        monitor: 60s
      rollback_config:
        parallelism: 1
        delay: 5s
```

## Advanced Patterns

### Cross-Platform Builds (multi-arch)

```bash
docker buildx create --name multiarch-builder --use
docker buildx build --platform linux/amd64,linux/arm64 -t myapp:latest --push .
```

### Distroless Runtime

Use distroless when you can (no shell, smaller attack surface). Ensure your app does not rely on shell utilities at runtime.

```dockerfile
FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build && npm prune --production

FROM gcr.io/distroless/nodejs20-debian12
WORKDIR /app
COPY --from=build /app/dist ./dist
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/package.json ./package.json
EXPOSE 3000
CMD ["dist/index.js"]
```

## Platform-Specific Best Practices

### Linux

- Use user namespace remapping for added security
- Leverage native performance advantages
- Use Alpine for smallest images
- Configure SELinux/AppArmor profiles
- Use systemd for Docker daemon management

```json
// /etc/docker/daemon.json
{
  "userns-remap": "default",
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "storage-driver": "overlay2",
  "live-restore": true
}
```

### macOS

- Allocate sufficient resources in Docker Desktop
- Use `:delegated` or `:cached` for bind mounts
- Consider multi-platform builds for ARM (M1/M2)
- Limit file sharing to necessary directories

```yaml
# Better volume performance on macOS
volumes:
  - ./src:/app/src:delegated  # Host writes are delayed
  - ./build:/app/build:cached  # Container writes are cached
```

### Windows

- Choose container type: Windows or Linux
- For agent file operations (Edit/Write), use backslashes in Windows paths.
- For Compose volume paths on Windows, prefer forward slashes (`C:/...`) to avoid YAML escaping issues.
- Ensure drives are shared in Docker Desktop
- Be aware of line ending differences (CRLF vs LF)
- Consider WSL2 backend for better performance

```yaml
# Windows-compatible paths
volumes:
  - C:/Users/name/app:/app  # Forward slashes work
  # or
  - C:\Users\name\app:/app  # Backslashes need escaping in YAML
```

## Code Review Checklist

- Dependency install layers come before copying the full source tree (cache-friendly ordering)
- Multi-stage builds separate build tools from runtime
- Final stage copies only required artifacts (avoid shipping source/tests/dev tools)
- `.dockerignore` keeps secrets, VCS, and build outputs out of the context
- Image tags are pinned (no `latest` in production)
- Container runs as non-root (`USER` with explicit UID/GID where possible)
- Secrets are not baked into images or set via `ENV` in Dockerfile
- Health checks exist for long-running services
- Resource limits and restart policies are defined where appropriate
- Networks are segmented (backend internal networks when applicable)
- Logs have rotation configured (`json-file` options or centralized logging)

## Common Issue Diagnostics

### Build Performance

- Symptoms: slow builds, cache misses on small code changes
- Usual causes: poor layer ordering, large build context, missing `.dockerignore`
- Fixes: reorder layers, add `.dockerignore`, split `deps` and `build` stages, use BuildKit cache mounts

### Image Too Large

- Symptoms: 1GB+ images, slow deploys
- Usual causes: build tools in runtime, copying entire repo, not pruning deps
- Fixes: multi-stage builds, `npm prune --production` (or equivalent), distroless/smaller base, selective `COPY`

### Networking/Service Discovery

- Symptoms: services can't reach each other, DNS issues, flaky startup
- Usual causes: missing shared network, wrong hostnames (should be service names), missing health checks
- Fixes: explicit networks, `depends_on` with `service_healthy`, correct internal URLs

## Performance Best Practices

### Build Performance

```bash
# Use BuildKit (faster, better caching)
export DOCKER_BUILDKIT=1

# Use cache mounts
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install -r requirements.txt

# Use bind mounts for dependencies
RUN --mount=type=bind,source=package.json,target=package.json \
    --mount=type=bind,source=package-lock.json,target=package-lock.json \
    --mount=type=cache,target=/root/.npm \
    npm ci
```

### Image Size

- Use multi-stage builds
- Choose minimal base images
- Clean up in the same layer
- Use .dockerignore
- Remove build dependencies

```dockerfile
# Install and cleanup in one layer
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    package1 \
    package2 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
```

### Runtime Performance

```dockerfile
# Use exec form (no shell overhead, proper PID 1 signal handling)
ENTRYPOINT ["node"]
CMD ["server.js"]
# vs
# Shell form (spawns /bin/sh -c, breaks signal forwarding)
CMD node server.js

# Optimize signals
STOPSIGNAL SIGTERM

# Run as non-root (slightly faster, much more secure)
USER appuser
```

## Security Best Practices Summary

**Image Security:**

- Use official, minimal base images
- Scan for vulnerabilities (Docker Scout, Trivy)
- Don't include secrets in layers
- Run as non-root user
- Keep images updated

**Runtime Security:**

- Drop capabilities
- Use read-only filesystem
- Set resource limits
- Enable security options
- Isolate networks
- Use secrets management

**Compliance:**

- Follow CIS Docker Benchmark
- Implement container scanning in CI/CD
- Use signed images (Docker Content Trust)
- Maintain audit logs
- Regular security reviews

## Common Anti-Patterns to Avoid

❌ **Don't:**

- Run as root
- Use `--privileged`
- Mount Docker socket
- Use `latest` tag
- Hardcode secrets
- Skip health checks
- Ignore resource limits
- Use huge base images
- Skip vulnerability scanning
- Expose unnecessary ports
- Use inefficient layer caching
- Commit secrets to Git

✅ **Do:**

- Run as non-root
- Use minimal capabilities
- Isolate containers
- Tag with versions
- Use secrets management
- Implement health checks
- Set resource limits
- Use minimal images
- Scan regularly
- Apply least privilege
- Optimize build cache
- Use .env.example templates

## Checklist for Production-Ready Images

- Based on official, versioned, minimal image
- Multi-stage build (if applicable)
- Runs as non-root user
- No secrets in layers
- .dockerignore configured
- Vulnerability scan passed
- Health check implemented
- Proper labeling (version, description, etc.)
- Efficient layer caching
- Resource limits defined
- Logging configured
- Signals handled correctly
- Security options set
- Documentation complete
- Tested on target platform(s)

This skill represents current Docker best practices. Always verify against official documentation for the latest recommendations, as Docker evolves continuously.
