#!/bin/bash
set -euo pipefail

echo "🚀 Starting Backstage pre-build process..."

# Setup Node.js if not already available or wrong version
if ! command -v node &> /dev/null || [[ $(node -v) != v18* ]]; then
    echo "🔧 Setting up Node.js 18..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt-get install -y nodejs
fi

# Setup Yarn if not available
if ! command -v yarn &> /dev/null; then
    echo "🔧 Setting up Yarn..."
    npm install -g yarn
fi

# Install dependencies with frozen lockfile for reproducible builds
echo "📦 Installing dependencies..."
yarn install --frozen-lockfile

# Add the GitHub auth provider
echo "🔧 Adding GitHub auth provider..."
yarn --cwd packages/backend add @backstage/plugin-auth-backend-module-github-provider

# Add core plugin API
echo "🔧 Adding core plugin API..."
yarn --cwd packages/app add @backstage/core-plugin-api

# Type check all packages
echo "🔍 Running type checks..."
yarn tsc

# Build the backend bundle (this creates the bundle.tar.gz that Docker needs)
echo "🏗️  Building backend bundle..."
yarn build:backend

# Verify the bundle was created
if [ -f "packages/backend/dist/bundle.tar.gz" ]; then
    echo "✅ Backend bundle created successfully"
    ls -lh packages/backend/dist/bundle.tar.gz
else
    echo "❌ Backend bundle not found!"
    exit 1
fi

echo "🎉 Pre-build completed successfully!"