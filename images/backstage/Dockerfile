FROM node:20-bookworm-slim AS packages

WORKDIR /app
COPY package.json yarn.lock ./
COPY packages packages

RUN find packages \! -name "*.ts" -type f | xargs rm -f
RUN yarn install --frozen-lockfile --production --network-timeout 300000

FROM node:20-bookworm-slim AS build

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && \
    apt-get install -y --no-install-recommends python3 g++ build-essential && \
    yarn config set python /usr/bin/python3
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && \
    apt-get install -y --no-install-recommends libsqlite3-dev

USER node

WORKDIR /app
COPY --from=packages --chown=node:node /app .

COPY --chown=node:node packages packages
COPY --chown=node:node app-config*.yaml ./
COPY --chown=node:node tsconfig.json package.json yarn.lock ./

ENV NODE_ENV development

RUN yarn install --frozen-lockfile --network-timeout 300000

RUN yarn tsc
RUN yarn build:backend

FROM node:20-bookworm-slim

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && \
    apt-get install -y --no-install-recommends python3 g++ build-essential

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && \
    apt-get install -y --no-install-recommends libsqlite3-dev

USER node

WORKDIR /app

COPY --from=build --chown=node:node /app/yarn.lock /app/package.json /app/
COPY --from=build --chown=node:node /app/node_modules/ /app/node_modules/
COPY --from=build --chown=node:node /app/packages/ /app/packages/
COPY --chown=node:node app-config*.yaml ./

ENV NODE_ENV production

CMD ["node", "packages/backend", "--config", "app-config.yaml"]