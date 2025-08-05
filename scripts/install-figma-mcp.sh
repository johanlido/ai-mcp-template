#!/bin/bash

# Figma MCP Server Installation Script

set -e

echo "Installing Figma MCP Server..."

# Create MCP servers directory
MCP_DIR="$HOME/.local/share/mcp-servers/figma-mcp"
mkdir -p "$MCP_DIR"

# Clone the repository
if [ -d "$MCP_DIR/.git" ]; then
    echo "Updating existing Figma MCP installation..."
    cd "$MCP_DIR"
    git pull
else
    echo "Cloning Figma MCP repository..."
    git clone https://github.com/figma/mcp-server-figma.git "$MCP_DIR"
    cd "$MCP_DIR"
fi

# Install dependencies
echo "Installing Node.js dependencies..."
npm install

# Build the project
echo "Building Figma MCP..."
npm run build

# Verify installation
if [ -f "dist/index.js" ]; then
    echo "✅ Figma MCP installed successfully"
    echo "📍 Location: $MCP_DIR"
    echo "🔑 Don't forget to set FIGMA_ACCESS_TOKEN in your .env file"
else
    echo "❌ Installation failed - dist/index.js not found"
    exit 1
fi

