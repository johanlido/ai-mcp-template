# macOS Setup Guide

Complete setup guide for AI MCP Template on macOS systems.

## 🍎 Prerequisites

### System Requirements
- **macOS**: 12.0+ (Monterey or later)
- **RAM**: 8GB minimum, 16GB+ recommended
- **Storage**: 5GB free space
- **Internet**: Stable connection for downloads

### Required Tools Installation

#### 1. Homebrew Package Manager
```bash
# Install Homebrew (if not already installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add Homebrew to PATH (follow the instructions shown after installation)
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

#### 2. Development Tools
```bash
# Install essential development tools
brew install node@18 python@3.11 git

# Install additional utilities
brew install curl wget jq

# Verify installations
node --version    # Should show v18.x.x or higher
python3 --version # Should show 3.11.x or higher
git --version     # Should show latest version
```

#### 3. Xcode Command Line Tools
```bash
# Install Xcode Command Line Tools (required for native modules)
xcode-select --install

# Accept the license agreement
sudo xcodebuild -license accept
```

### Apple Silicon (M1/M2/M3) Considerations

#### Rosetta 2 (if needed)
```bash
# Install Rosetta 2 for x86 compatibility (if not already installed)
sudo softwareupdate --install-rosetta --agree-to-license
```

#### Architecture-Specific Notes
- Most MCP servers run natively on Apple Silicon
- Some Node.js packages may require compilation
- Python packages generally work without issues

## 🔧 Application Installation

### 1. Claude Desktop
```bash
# Download Claude Desktop for macOS
curl -L -o Claude.dmg "https://claude.ai/download/desktop/mac"

# Mount and install (or use the GUI installer)
hdiutil mount Claude.dmg
cp -R /Volumes/Claude/Claude.app /Applications/
hdiutil unmount /Volumes/Claude
rm Claude.dmg
```

### 2. Visual Studio Code
```bash
# Install VSCode via Homebrew
brew install --cask visual-studio-code

# Or download directly
# curl -L -o VSCode.zip "https://code.visualstudio.com/sha/download?build=stable&os=darwin-universal"
```

### 3. Required VSCode Extensions
```bash
# Install GitHub Copilot extension
code --install-extension GitHub.copilot

# Install additional recommended extensions
code --install-extension ms-python.python
code --install-extension bradlc.vscode-tailwindcss
code --install-extension esbenp.prettier-vscode
code --install-extension ms-vscode.vscode-json
```

## 🔐 Security Configuration

### 1. System Permissions

#### Terminal Full Disk Access
1. Open **System Preferences** → **Security & Privacy** → **Privacy**
2. Select **Full Disk Access** from the left sidebar
3. Click the lock icon and enter your password
4. Click **+** and add your terminal application:
   - **Terminal.app**: `/Applications/Utilities/Terminal.app`
   - **iTerm2**: `/Applications/iTerm.app`
   - **VSCode**: `/Applications/Visual Studio Code.app`

#### Claude Desktop Permissions
1. Open **System Preferences** → **Security & Privacy** → **Privacy**
2. Grant Claude Desktop access to:
   - **Files and Folders** (for MCP server file operations)
   - **Accessibility** (for automation features, if needed)

### 2. Network Security
```bash
# Allow Claude Desktop through firewall (if enabled)
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --add /Applications/Claude.app
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --unblockapp /Applications/Claude.app
```

## 🚀 AI MCP Template Setup

### 1. Clone and Setup
```bash
# Clone the template repository
git clone https://github.com/johanlido/ai-mcp-template.git
cd ai-mcp-template

# Make setup scripts executable
chmod +x scripts/*.sh

# Run the interactive setup
./scripts/interactive-setup.sh
```

### 2. Environment Configuration
```bash
# Copy environment template
cp .env.example .env

# Edit with your API keys
nano .env  # or use your preferred editor

# Required API keys:
# - PERPLEXITY_API_KEY=pplx-your-key-here
# - GITHUB_PERSONAL_ACCESS_TOKEN=ghp-your-token-here (optional)
# - FIGMA_ACCESS_TOKEN=your-figma-token-here (optional)
```

### 3. MCP Servers Installation
```bash
# Install all MCP servers
./scripts/install-mcp-servers.sh

# Or install individually
./scripts/install-perplexity-mcp.sh
./scripts/install-manus-mcp.sh
./scripts/install-figma-mcp.sh
```

### 4. Claude Desktop Configuration
```bash
# Configure Claude Desktop with MCP servers
./scripts/configure-claude.sh

# Verify configuration
cat ~/Library/Application\ Support/Claude/claude_desktop_config.json
```

## 🔍 Verification and Testing

### 1. Health Check
```bash
# Run comprehensive health check
./scripts/health-check.sh

# Expected output:
# ✓ Perplexity MCP: Connected
# ✓ Manus MCP: Connected  
# ✓ Figma MCP: Connected (if configured)
# ✓ Claude Desktop: Configuration valid
```

### 2. Test MCP Connections
1. **Launch Claude Desktop**
2. **Look for MCP indicator** (🔌) in the interface
3. **Test each server**:
   - Perplexity: "Search for the latest React 18 features"
   - Manus: "Browse to github.com and tell me about trending repositories"
   - Figma: "Analyze the design at [figma-url]" (if configured)

### 3. VSCode Integration
```bash
# Open project in VSCode
code .

# Verify GitHub Copilot is active
# Look for Copilot icon in status bar
```

## 🛠️ macOS-Specific Troubleshooting

### Common Issues

#### Issue: "Permission denied" errors
```bash
# Fix npm permissions
sudo chown -R $(whoami) ~/.npm
sudo chown -R $(whoami) /usr/local/lib/node_modules

# Fix Python permissions  
sudo chown -R $(whoami) ~/.local
```

#### Issue: Claude Desktop not detecting MCP servers
```bash
# Check configuration file location
ls -la ~/Library/Application\ Support/Claude/

# Verify JSON syntax
python3 -m json.tool ~/Library/Application\ Support/Claude/claude_desktop_config.json

# Restart Claude Desktop completely
pkill -f Claude
sleep 2
open -a Claude
```

#### Issue: Gatekeeper blocking executables
```bash
# Remove quarantine attribute from specific files
sudo xattr -rd com.apple.quarantine /path/to/blocked/file

# For MCP server executables
find ~/.local/share/mcp-servers -name "*.js" -exec sudo xattr -rd com.apple.quarantine {} \;
```

#### Issue: Node.js module compilation failures
```bash
# Clear npm cache
npm cache clean --force

# Rebuild native modules
npm rebuild

# For Python modules
pip3 install --upgrade pip setuptools wheel
```

### Performance Optimization

#### Memory Management
```bash
# Monitor memory usage
top -o MEM | head -20

# If experiencing high memory usage:
# 1. Restart Claude Desktop periodically
# 2. Limit concurrent MCP server connections
# 3. Use Activity Monitor to identify memory-heavy processes
```

#### Network Optimization
```bash
# Test API connectivity
ping -c 4 api.perplexity.ai
ping -c 4 api.anthropic.com

# If experiencing slow responses:
# 1. Check internet connection stability
# 2. Consider using a VPN if corporate firewall blocks APIs
# 3. Verify DNS settings (try 8.8.8.8, 1.1.1.1)
```

## 🎯 Next Steps

After successful setup:

1. **Explore Example Workflows**: Check `docs/examples/workflows/`
2. **Customize Configuration**: See `docs/guides/customization.md`
3. **Team Setup**: Review `docs/guides/team-onboarding.md`
4. **Advanced Features**: Explore `docs/guides/advanced-usage.md`

## 📞 macOS-Specific Support

For macOS-specific issues:
- Check [macOS Troubleshooting Guide](../guides/troubleshooting-macos.md)
- Review [Apple Silicon Compatibility](../guides/apple-silicon.md)
- Join our [GitHub Discussions](https://github.com/johanlido/ai-mcp-template/discussions)

---

**🎉 Congratulations!** Your AI development environment is now ready. Start with the [Quick Start Guide](README.md) to begin your first AI-assisted development workflow.

