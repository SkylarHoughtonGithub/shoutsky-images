#!/bin/bash
set -euo pipefail

echo "🚀 Starting Backstage pre-build process..."

if ! command -v node &> /dev/null || [[ $(node -v) != v18* ]]; then
    echo "🔧 Setting up Node.js 18..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt-get install -y nodejs
fi

if ! command -v yarn &> /dev/null; then
    echo "🔧 Setting up Yarn..."
    npm install -g yarn
fi

echo "📦 Installing dependencies..."
yarn install --frozen-lockfile

echo "🔧 Adding additional packages..."
yarn --cwd packages/backend add @backstage/plugin-auth-backend-module-github-provider
yarn --cwd packages/app add @backstage/core-plugin-api
yarn --cwd packages/app add @backstage/plugin-tech-radar

echo "🔍 Running type checks..."
yarn tsc

echo "🏗️  Building backend bundle..."
yarn build:backend

if [ -f "packages/backend/dist/bundle.tar.gz" ]; then
    echo "✅ Backend bundle created successfully"
    ls -lh packages/backend/dist/bundle.tar.gz
else
    echo "❌ Backend bundle not found!"
    exit 1
fi

echo "🎉 Pre-build completed successfully!"