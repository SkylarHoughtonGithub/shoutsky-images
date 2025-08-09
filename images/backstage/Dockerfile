# Dockerfile
FROM node:20-bookworm-slim AS packages

WORKDIR /app

# Enable Corepack for Yarn 4.x support
RUN corepack enable

COPY package.json yarn.lock ./
COPY packages packages

# Comment this out if you don't have any internal plugins
# COPY plugins plugins

RUN find packages \! -name "*.ts" -type f | xargs rm -f
RUN yarn install --frozen-lockfile --production --network-timeout 300000

FROM node:20-bookworm-slim AS build

# Enable Corepack for Yarn 4.x support
RUN corepack enable

# Install isolate-vm dependencies, these are needed by the @backstage/plugin-scaffolder-backend.
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && \
    apt-get install -y --no-install-recommends python3 g++ build-essential && \
    yarn config set python /usr/bin/python3

# Install sqlite3 dependencies. You can skip this if you don't use sqlite3 in the image,
# in which case you should also move better-sqlite3 to "devDependencies" in package.json.
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && \
    apt-get install -y --no-install-recommends libsqlite3-dev

USER node
WORKDIR /app

COPY --from=packages --chown=node:node /app .

# Comment this out if you don't have any internal plugins
# COPY --chown=node:node plugins plugins

COPY --chown=node:node packages packages
COPY --chown=node:node app-config*.yaml ./
COPY --chown=node:node tsconfig.json package.json yarn.lock ./

ENV NODE_ENV=development

RUN yarn install --frozen-lockfile --network-timeout 300000

RUN yarn tsc
RUN yarn build:backend

FROM node:20-bookworm-slim

# Enable Corepack for Yarn 4.x support
RUN corepack enable

# Install isolate-vm dependencies, these are needed by the @backstage/plugin-scaffolder-backend.
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && \
    apt-get install -y --no-install-recommends python3 g++ build-essential

# Install sqlite3 dependencies. You can skip this if you don't use sqlite3 in the image,
# in which case you should also move better-sqlite3 to "devDependencies" in package.json.
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && \
    apt-get install -y --no-install-recommends libsqlite3-dev

# From here on we use the least-privileged `node` user to run the backend.
USER node

# This should create the app dir as `node`.
# If it is instead created as `root` then the `tar` command below will fail: `can't create directory 'packages/': Permission denied`.
# If this occurs, then ensure BuildKit is enabled (`DOCKER_BUILDKIT=1`) so the app dir is correctly created as `node`.
WORKDIR /app

# Copy the install dependencies from the build stage and context
COPY --from=build --chown=node:node /app/yarn.lock /app/package.json /app/
COPY --from=build --chown=node:node /app/node_modules/ /app/node_modules/
COPY --from=build --chown=node:node /app/packages/ /app/packages/

# Comment this out if you don't have any internal plugins
# COPY --from=build --chown=node:node /app/plugins/ /app/plugins/

# Copy any other files that we need at runtime
COPY --chown=node:node app-config*.yaml ./

ENV NODE_ENV=production

CMD ["node", "packages/backend", "--config", "app-config.yaml"]