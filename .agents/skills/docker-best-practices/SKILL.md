---
name: docker-best-practices
description: Comprehensive Docker best practices covering image building, container runtime, security, orchestration with Compose, and production deployments
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

This skill covers Docker across all domains: image building, container runtime, security hardening, Compose orchestration, and production operations.

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

**Recommended Hierarchy:**

1. **Wolfi/Chainguard** (`cgr.dev/chainguard/*`) — Zero-CVE goal, SBOM included, nightly patches
2. **Alpine** (`alpine:3.19`) — ~7MB, minimal attack surface
3. **Distroless** (`gcr.io/distroless/*`) — ~2MB, no shell
4. **Slim variants** (`node:20-slim`) — ~70MB, balanced

**Key rules:**

- Always specify exact version tags: `node:20.11.0-alpine3.19`
- Never use `latest` (unpredictable, breaks reproducibility)
- Use official images from trusted registries
- Match base image to actual needs

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

RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . /app
WORKDIR /app

ENTRYPOINT ["python"]
CMD ["app.py"]
```

### Multi-Stage Builds

Separate build dependencies from runtime:

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

### .dockerignore

Always create `.dockerignore` to exclude unnecessary files:

```text
# Secrets
.env
.env.local
*.key
*.pem
credentials.json
secrets/
.aws/
.gcloud/
.ssh/

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
```

### Vulnerability Scanning

**Tools:**

- **Docker Scout** (built-in): `docker scout cves IMAGE_NAME`
- **Trivy**: `trivy image IMAGE_NAME`
- **Grype**: `grype IMAGE_NAME`

**Process:**

```bash
# Docker Scout
docker scout cves IMAGE_NAME
docker scout recommendations IMAGE_NAME

# Trivy
trivy image --severity HIGH,CRITICAL IMAGE_NAME
trivy config Dockerfile
trivy fs --scanners secret .
```

**CI/CD Integration:**

```yaml
- name: Scan image
  run: |
    docker scout cves my-image:${{ github.sha }}
    trivy image --exit-code 1 --severity CRITICAL my-image:${{ github.sha }}
```

### Image Signing

Enable Docker Content Trust to ensure only signed images are pulled:

```bash
export DOCKER_CONTENT_TRUST=1
docker trust key generate my-key
docker trust signer add --key my-key.pub my-name my-image
docker push my-image:tag
```

## Build-Time Security

### Secrets Management with BuildKit

**Never do this:**

```dockerfile
# BAD - secret in layer history
ENV API_KEY=abc123
COPY .env /app/.env
```

**Use BuildKit secrets:**

```dockerfile
# syntax=docker/dockerfile:1

FROM alpine
RUN --mount=type=secret,id=github_token \
    git clone https://$(cat /run/secrets/github_token)@github.com/repo.git
```

```bash
docker build --secret id=github_token,src=./token.txt .
```

Secrets used in builds do NOT persist in the final image.

### BuildKit Frontend Security

BuildKit supports custom frontends via `# syntax=` directive. Untrusted frontends have FULL build-time code execution.

**Only use official Docker frontends:**

```dockerfile
# ✅ Safe - Official Docker frontend
# syntax=docker/dockerfile:1

# ✅ Safe - Pinned with digest
# syntax=docker/dockerfile:1@sha256:ac85f380a63b13dfcefa89046420e1781752bab202122f8f50032edf31be0021
```

```bash
# Audit all Dockerfiles for unsafe syntax directives
grep -r "^# syntax=" . --include="Dockerfile*"
grep -r "^# syntax=" . --include="Dockerfile*" | grep -v "docker/dockerfile"
```

### SBOM (Software Bill of Materials) Generation

Document all components for supply chain transparency:

```bash
# Generate SBOM with Docker Scout
docker scout sbom --format spdx IMAGE_NAME > sbom.spdx.json

# Or with Syft
syft my-image:latest -o spdx-json > sbom.spdx.json

# Include SBOM attestation during build
docker buildx build --sbom=true --provenance=true --tag my-image:latest .
```

**Note:** BuildKit attestations are NOT cryptographically signed. For production, use external signing (cosign) and Syft for SBOM generation.

## Docker Compose Orchestration

Docker Compose simplifies multi-container application management through declarative YAML configuration, automatic networking, and volume management.

### Compose File Structure

```yaml
services:       # Define containers
  service-name:
    # Service configuration

networks:       # Define custom networks
  network-name:

volumes:        # Define named volumes
  volume-name:

configs:        # Application configs (Swarm mode)
secrets:        # Sensitive data (Swarm mode)
```

The `version` field is no longer needed (Compose v2.40.3+).

### Service Definition Patterns

**Basic service:**

```yaml
services:
  web:
    image: nginx:alpine
    container_name: my-web
    restart: unless-stopped
    ports:
      - "80:80"
    environment:
      - NGINX_HOST=example.com
    volumes:
      - ./html:/usr/share/nginx/html
    networks:
      - frontend
```

**Build-based service:**

```yaml
services:
  app:
    build:
      context: ./app
      dockerfile: Dockerfile
      args:
        NODE_ENV: production
      target: runtime
    image: myapp:latest
    ports:
      - "3000:3000"
```

**Service with dependencies:**

```yaml
services:
  web:
    image: nginx
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_started

  db:
    image: postgres:15
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s
```

### Networking Strategies

**Custom bridge networks with isolation:**

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
      - backend  # Isolated from frontend
```

**Network aliases:**

```yaml
services:
  api:
    networks:
      backend:
        aliases:
          - api-server
          - api.internal
```

**Key rules:**

- Default bridge network is sufficient for simple cases
- Custom bridge networks provide DNS-based service discovery
- Use `internal: true` for backend/database networks
- Services communicate by service name across networks
- Host network mode (`network_mode: "host"`) bypasses Docker networking — use sparingly

### Volume Management

**Named volumes** (preferred for persistence):

```yaml
services:
  db:
    image: postgres:15
    volumes:
      - postgres-data:/var/lib/postgresql/data

volumes:
  postgres-data:
```

**Bind mounts** (development):

```yaml
services:
  app:
    volumes:
      - ./src:/app/src              # Source code (hot reload)
      - ./config:/app/config:ro     # Read-only config
      - /app/node_modules           # Preserve container deps
```

**tmpfs mounts** (in-memory, ephemeral):

```yaml
services:
  app:
    tmpfs:
      - /tmp:noexec,nosuid,size=64M
```

### Health Checks

Define health checks for all critical services:

```yaml
services:
  web:
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  postgres:
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 3s
      retries: 5
```

### Environment Configurations

**Base compose.yaml:**

```yaml
services:
  web:
    image: myapp:latest
    environment:
      - NODE_ENV=production
```

**Development override (compose.override.yaml — auto-merged):**

```yaml
services:
  web:
    build:
      target: development
    volumes:
      - ./src:/app/src
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=development
    command: npm run dev
```

**Production (compose.prod.yaml):**

```yaml
services:
  web:
    image: myapp:${VERSION:-latest}
    restart: always
    deploy:
      replicas: 3
      resources:
        limits:
          cpus: '2'
          memory: 2G
```

```bash
# Dev (auto-loads compose.override.yaml)
docker compose up

# Production
docker compose -f compose.yaml -f compose.prod.yaml up -d
```

### Essential Compose Commands

```bash
# Lifecycle
docker compose up -d              # Start background
docker compose down -v            # Stop + remove + volumes

# Build
docker compose build --no-cache   # Clean build
docker compose build --pull       # Pull latest base images

# Debug
docker compose logs -f web        # Follow service logs
docker compose exec web sh        # Interactive shell
docker compose run --rm web test  # One-off command

# Config
docker compose config             # Validate and view merged config
docker compose config --services  # List service names
```

## Container Runtime Best Practices

### Secure Run Command

```bash
docker run \
  --user 1000:1000 \
  --cap-drop=ALL \
  --cap-add=NET_BIND_SERVICE \
  --read-only \
  --tmpfs /tmp:noexec,nosuid,size=64M \
  --security-opt="no-new-privileges:true" \
  --security-opt="seccomp=default" \
  --memory="512m" \
  --cpus="1.0" \
  --pids-limit=100 \
  --restart unless-stopped \
  my-image
```

### User Privileges

Always run as non-root. Create a dedicated user in the Dockerfile:

```dockerfile
RUN addgroup -g 1001 appuser && \
    adduser -S appuser -u 1001 -G appuser
USER appuser
WORKDIR /home/appuser/app
COPY --chown=appuser:appuser . .
```

**Verification:**

```bash
docker exec container-name whoami  # Should not be root
docker exec container-name id       # Check UID/GID
```

### Capabilities

Drop all capabilities, add only what's needed. Default capabilities include CHOWN, DAC_OVERRIDE, NET_RAW, SYS_CHROOT, etc.

```bash
docker run --cap-drop=ALL --cap-add=NET_BIND_SERVICE my-image
```

```yaml
services:
  app:
    cap_drop:
      - ALL
    cap_add:
      - NET_BIND_SERVICE
```

**Common needed capabilities:**

- `NET_BIND_SERVICE`: Bind to ports < 1024
- `NET_ADMIN`: Network configuration
- `SYS_TIME`: Set system time

### Read-Only Filesystem

Prevents container modification and malware persistence:

```bash
docker run --read-only --tmpfs /tmp:noexec,nosuid,size=64M my-image
```

```yaml
services:
  app:
    read_only: true
    tmpfs:
      - /tmp:noexec,nosuid,size=64M
```

### Security Options

**no-new-privileges:** Prevents privilege escalation via setuid/setgid binaries:

```bash
docker run --security-opt="no-new-privileges:true" my-image
```

**Seccomp (syscall filtering):**

```bash
docker run --security-opt="seccomp=default" my-image

# Or custom profile
docker run --security-opt="seccomp=./seccomp-profile.json" my-image
```

**AppArmor (Linux):**

```bash
docker run --security-opt="apparmor=docker-default" my-image
```

### Resource Management

Always set resource limits in production:

```yaml
services:
  app:
    deploy:
      resources:
        limits:
          cpus: '2.0'
          memory: 1G
          pids: 100
        reservations:
          cpus: '1.0'
          memory: 512M
    ulimits:
      nofile:
        soft: 1024
        hard: 1024
```

### Logging

Prevent disk fill-up:

```yaml
services:
  app:
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

Or system-wide:

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
    restart: "no"                # Development
    restart: unless-stopped      # Production
    restart: always              # Critical services
```

## Network Security

### Network Isolation

Segment networks to prevent lateral movement:

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
      - backend  # Isolated from frontend
```

### Port Exposure

**Bind to localhost only** to avoid exposing services to the network:

```bash
docker run -p 127.0.0.1:8080:8080 my-image
```

```yaml
services:
  app:
    ports:
      - "127.0.0.1:8080:8080"
```

### Inter-Container Communication

Disable default inter-container communication in daemon.json:

```json
{
  "icc": false
}
```

Then explicitly allow via custom networks.

## Secrets Management

**Never do this:**

```dockerfile
# BAD - secret in layer history
ENV API_KEY=secret123
RUN echo "password" > /app/config
```

**Do this:**

```bash
# Docker secrets (Swarm mode)
echo "mypassword" | docker secret create db_password -
docker service create --name my-service --secret db_password my-image
# Container reads from /run/secrets/db_password

# Mount secrets at runtime
docker run -v /secure/secrets:/run/secrets:ro my-app

# Use environment files (not in image)
docker run --env-file /secure/.env my-app
```

**Best practices:**

- Never in environment variables (visible in `docker inspect`)
- Never in images (in layer history)
- Mount as files with restricted permissions
- Use external secret management (Vault, AWS Secrets Manager)
- Rotate regularly

## Production Best Practices

### Image Tagging Strategy

```bash
# Use semantic versioning
my-app:1.2.3
my-app:1.2
my-app:1

# Include git commit for traceability
my-app:1.2.3-abc123f

# Environment tags
my-app:1.2.3-production
my-app:1.2.3-staging
```

### Monitoring & Observability

```yaml
services:
  app:
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/health"]
      interval: 30s

    labels:
      - "prometheus.io/scrape=true"
      - "prometheus.io/port=9090"
      - "com.company.team=backend"
      - "com.company.version=1.2.3"

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

### Update Strategy (Swarm Mode Rolling Updates)

```yaml
services:
  app:
    deploy:
      replicas: 3
      update_config:
        parallelism: 1
        delay: 10s
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

Use distroless when your app doesn't need shell utilities at runtime:

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
- Configure SELinux/AppArmor profiles
- Use systemd for Docker daemon management

```json
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
- Consider multi-platform builds for ARM

```yaml
volumes:
  - ./src:/app/src:delegated
  - ./build:/app/build:cached
```

### Windows

- Choose container type: Windows or Linux
- For Compose volume paths, prefer forward slashes (`C:/...`)
- Consider WSL2 backend for better performance

```yaml
volumes:
  - C:/Users/name/app:/app
```

## Compliance & Benchmarking

### CIS Docker Benchmark

```bash
docker run --rm --net host --pid host --userns host \
  --cap-add audit_control \
  -v /var/lib:/var/lib:ro \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  -v /etc:/etc:ro \
  docker/docker-bench-security
```

### Security Checklist

**Image:**

- Based on official, minimal image with specific version tag
- Vulnerability scan passed (Docker Scout, Trivy)
- No secrets in layers
- Runs as non-root user
- Signed (Content Trust)

**Build:**

- `.dockerignore` configured (secrets, .git, node_modules excluded)
- Multi-stage build separates build tools from runtime
- Build secrets handled via `--mount=type=secret`, not baked into layers
- Only official BuildKit frontends used

**Runtime:**

- Non-root user with explicit UID/GID
- Capabilities dropped to minimum (--cap-drop=ALL)
- Read-only filesystem with tmpfs for writable paths
- no-new-privileges enabled
- Resource limits configured (CPU, memory, pids)
- Isolated networks (frontend/backend separation)
- Health checks defined for all services
- Log rotation configured

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

# Run as non-root
USER appuser
```

## Code Review Checklist

- Dependency install layers come before copying the full source tree
- Multi-stage builds separate build tools from runtime
- Final stage copies only required artifacts
- `.dockerignore` keeps secrets, VCS, and build outputs out of the context
- Image tags are pinned (no `latest` in production)
- Container runs as non-root (`USER` with explicit UID/GID)
- Secrets are not baked into images or set via `ENV` in Dockerfile
- Health checks exist for long-running services
- Resource limits and restart policies are defined
- Networks are segmented (backend internal networks)
- Logs have rotation configured

## Common Issue Diagnostics

### Build Performance

- Symptoms: slow builds, cache misses on small code changes
- Causes: poor layer ordering, large build context, missing `.dockerignore`
- Fixes: reorder layers, add `.dockerignore`, split `deps` and `build` stages, use BuildKit cache mounts

### Image Too Large

- Symptoms: 1GB+ images, slow deploys
- Causes: build tools in runtime, copying entire repo, not pruning deps
- Fixes: multi-stage builds, `npm prune --production`, distroless/smaller base, selective `COPY`

### Networking/Service Discovery

- Symptoms: services can't reach each other, DNS issues, flaky startup
- Causes: missing shared network, wrong hostnames, missing health checks
- Fixes: explicit networks, `depends_on` with `service_healthy`, correct internal URLs

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
- Use inefficient layer caching
- Commit secrets to Git

✅ **Do:**

- Run as non-root
- Use minimal capabilities
- Isolate containers via networks
- Tag with semantic versions
- Use secrets management
- Implement health checks
- Set resource limits
- Use minimal base images
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
- Proper labeling (version, description)
- Efficient layer caching
- Resource limits defined
- Logging configured
- Signals handled correctly
- Security options set
- Tested on target platform(s)
