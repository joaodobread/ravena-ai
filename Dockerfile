# ─────────────────────────────────────────────────────────────
# ravena-ai Dockerfile
# Node.js bot — no Chromium, no Puppeteer
# ─────────────────────────────────────────────────────────────
# syntax=docker/dockerfile:1

# ── Etapa 1: instala node_modules (com toolchain para o caso de algum
#    pacote nativo precisar compilar quando não houver binário pré-compilado)
FROM node:20-slim AS deps

RUN --mount=type=cache,id=s/ff036bb5-ef37-42a1-b695-b45e0e6b362f-/var/cache/apt,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,id=s/ff036bb5-ef37-42a1-b695-b45e0e6b362f-/var/lib/apt/lists,target=/var/lib/apt/lists,sharing=locked \
    apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    make \
    g++ \
    libcairo2-dev \
    libpango1.0-dev \
    libjpeg-dev \
    libgif-dev \
    librsvg2-dev

WORKDIR /app
COPY package.json package-lock.json ./
RUN --mount=type=cache,id=s/ff036bb5-ef37-42a1-b695-b45e0e6b362f-/root/.npm,target=/root/.npm \
    npm ci --omit=dev

# ── Etapa 2: imagem final só com o necessário em runtime
#    (canvas, sharp e better-sqlite3 trazem suas libs nativas em node_modules)
FROM node:20-slim

RUN --mount=type=cache,id=s/ff036bb5-ef37-42a1-b695-b45e0e6b362f-/var/cache/apt-rt,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,id=s/ff036bb5-ef37-42a1-b695-b45e0e6b362f-/var/lib/apt/lists-rt,target=/var/lib/apt/lists,sharing=locked \
    apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    imagemagick \
    curl \
    ca-certificates \
    jq \
    python3 \
    fonts-dejavu-core \
    fonts-urw-base35 \
    fonts-droid-fallback \
    fonts-noto-mono

WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Persistent data directories (mapped as volumes in docker-compose)
RUN mkdir -p /app/data /app/public /app/downloads

EXPOSE 5000

CMD ["node", "--dns-result-order=ipv4first", "index.js"]
