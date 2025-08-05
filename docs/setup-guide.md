# 📖 Complete Setup Guide

This comprehensive guide walks you through setting up the professional AI development environment from the template repository.

## 🎯 Prerequisites

### Hardware Requirements

**Minimum Requirements:**
- 16GB RAM (32GB recommended for optimal performance)
- 8GB available disk space
- Multi-core processor (Intel i5/AMD Ryzen 5 or better)
- Stable internet connection

**Recommended Specifications:**
- 32GB RAM or more
- SSD storage with 20GB+ available space
- Intel i7/AMD Ryzen 7 or Apple Silicon M1/M2
- High-speed internet (for AI model interactions)

### Software Prerequisites

**Required Software:**
- **Git** (version 2.20+)
- **Node.js** (version 18+ recommended)
- **Python** (version 3.11+)
- **VSCode** with GitHub Copilot extension
- **Claude Desktop** application

**Operating System Support:**
- macOS 10.15+ (Catalina or later)
- Ubuntu 20.04+ or equivalent Linux distribution
- Windows 10/11 (with WSL2 recommended)

### Account Requirements

**Essential Accounts:**
- GitHub account with Copilot access
- Anthropic account for Claude Desktop
- Perplexity account with API access

**Optional Accounts:**
- Figma account (Professional plan or higher for MCP features)
- Brave Search API account
- Additional service accounts based on your needs

## 🚀 Step-by-Step Installation

### Step 1: Repository Setup

**Create Your Repository from Template:**

1. **Using GitHub Template (Recommended):**
   - Visit: https://github.com/johanlido/ai-mcp-template
   - Click "Use this template" button
   - Create a new repository in your account
   - Choose public or private based on your needs

2. **Clone Your New Repository:**
   ```bash
   git clone https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git
   cd YOUR_REPO_NAME
   ```

3. **Verify Repository Structure:**
   ```bash
   ls -la
   # Should show: configs/, scripts/, docs/, .env.example, README.md
   ```

### Step 2: Environment Configuration

**Create and Configure Environment File:**

1. **Copy Template:**
   ```bash
   cp .env.example .env
   ```

2. **Edit Environment Variables:**
   ```bash
   # Use your preferred editor
   nano .env
   # or
   code .env
   ```

3. **Configure Essential Variables:**
   ```bash
   # Perplexity API (Required)
   PERPLEXITY_API_KEY=your_actual_api_key_here
   PERPLEXITY_MODEL=sonar-pro
   
   # Manus Configuration
   MANUS_SANDBOX_DIR=~/ai-dev-sandbox
   MANUS_GLOBAL_TIMEOUT=120
   MANUS_BROWSER_HEADLESS=false
   
   # Optional: GitHub Integration
   GITHUB_PERSONAL_ACCESS_TOKEN=your_github_token_here
   ```

### Step 3: Run Initial Setup

**Execute the Main Setup Script:**

```bash
# Make script executable (if needed)
chmod +x scripts/setup.sh

# Run setup
./scripts/setup.sh
```

**What the Setup Script Does:**
- Checks system requirements and compatibility
- Verifies all prerequisite software is installed
- Creates necessary directories and configuration files
- Backs up existing configurations
- Installs required Python and Node.js dependencies
- Validates API keys and configuration

**Expected Output:**
```
==================================================
Professional AI Development Environment Setup
==================================================

[INFO] Checking operating system...
[SUCCESS] macOS detected
[INFO] Checking prerequisites...
[SUCCESS] All prerequisites are installed
[INFO] Checking hardware requirements...
[SUCCESS] RAM check passed: 32GB available
...
[SUCCESS] Basic setup completed!
```

### Step 4: Install MCP Servers

**Run MCP Server Installation:**

```bash
./scripts/install-mcp-servers.sh
```

**Installation Process:**
- Downloads and builds Perplexity MCP server
- Sets up Manus MCP server with Python environment
- Installs additional MCP servers via npm
- Creates configuration templates
- Verifies all installations

**Troubleshooting Installation Issues:**

*Node.js Permission Errors:*
```bash
# Fix npm permissions
npm config set prefix ~/.npm-global
export PATH=~/.npm-global/bin:$PATH
```

*Python Environment Issues:*
```bash
# Install uv if missing
curl -LsSf https://astral.sh/uv/install.sh | sh
source ~/.cargo/env
```

*Build Failures:*
```bash
# Clear npm cache
npm cache clean --force

# Reinstall dependencies
cd ~/.local/share/mcp-servers/perplexity-mcp
rm -rf node_modules package-lock.json
npm install
```

### Step 5: Configure Claude Desktop

**Run Claude Configuration Script:**

```bash
./scripts/configure-claude.sh
```

**Configuration Process:**
- Detects Claude Desktop installation
- Backs up existing configuration
- Generates new configuration with all MCP servers
- Validates JSON configuration
- Creates Figma setup documentation

**Manual Verification:**
1. **Check Configuration File:**
   ```bash
   # macOS
   cat ~/Library/Application\ Support/Claude/claude_desktop_config.json
   
   # Linux
   cat ~/.config/Claude/claude_desktop_config.json
   ```

2. **Restart Claude Desktop:**
   - Completely quit Claude Desktop
   - Relaunch the application
   - Look for MCP server indicator (🔌) in the chat interface

### Step 6: Configure VSCode

**Run VSCode Configuration Script:**

```bash
./scripts/configure-vscode.sh
```

**Manual VSCode Setup:**

1. **Install Recommended Extensions:**
   - Open VSCode in the repository directory
   - VSCode will prompt to install recommended extensions
   - Accept the installation of all recommended extensions

2. **Apply Settings:**
   ```bash
   # Copy settings to VSCode user directory
   # macOS
   cp configs/vscode/settings.json ~/Library/Application\ Support/Code/User/
   
   # Linux
   cp configs/vscode/settings.json ~/.config/Code/User/
   ```

3. **Verify GitHub Copilot:**
   - Open any code file
   - Start typing to see Copilot suggestions
   - Use Ctrl+I (Cmd+I on Mac) to open Copilot chat

## 🔧 Advanced Configuration

### Custom MCP Server Selection

**Disable Unused Servers:**

Edit the Claude configuration to include only needed servers:

```json
{
  "mcpServers": {
    "perplexity-server": { ... },
    // "manus-mcp": { ... },  // Commented out
    "filesystem": { ... }
  }
}
```

### Team-Specific Customization

**Create Team Configurations:**

1. **Branch Strategy:**
   ```bash
   git checkout -b team-frontend
   # Customize for frontend team
   git checkout -b team-backend
   # Customize for backend team
   ```

2. **Environment Templates:**
   ```bash
   cp .env.example .env.frontend
   cp .env.example .env.backend
   # Customize each template
   ```

### Performance Optimization

**Resource Management:**

1. **Monitor Resource Usage:**
   ```bash
   # Create monitoring script
   cat > scripts/monitor-resources.sh << 'EOF'
   #!/bin/bash
   echo "=== AI Development Environment Resource Usage ==="
   echo "Memory Usage:"
   ps aux | grep -E "(Claude|node|python)" | awk '{print $1, $2, $4, $11}'
   echo "Disk Usage:"
   du -sh ~/.local/share/mcp-servers/*
   EOF
   chmod +x scripts/monitor-resources.sh
   ```

2. **Optimize Settings:**
   ```bash
   # Reduce timeout for faster responses
   MANUS_GLOBAL_TIMEOUT=30
   
   # Enable headless browser for better performance
   MANUS_BROWSER_HEADLESS=true
   
   # Limit search results
   MANUS_GOOGLE_SEARCH_MAX_RESULTS=5
   ```

## 🔍 Verification and Testing

### Test MCP Server Connectivity

**In Claude Desktop:**

1. **Check Server Status:**
   - Look for MCP server indicator (🔌)
   - Click indicator to see available tools
   - Verify all expected servers are listed

2. **Test Each Server:**
   ```
   # Test Perplexity
   "Search for the latest React 18 features"
   
   # Test Manus
   "Browse to https://github.com and tell me about trending repositories"
   
   # Test Filesystem
   "List the files in my Documents folder"
   ```

### Test VSCode Integration

**Verify GitHub Copilot:**

1. **Code Suggestions:**
   - Create a new JavaScript file
   - Type: `function calculateFibonacci(`
   - Verify Copilot suggests completion

2. **Chat Integration:**
   - Press Ctrl+I (Cmd+I on Mac)
   - Ask: "How do I implement a REST API in Node.js?"
   - Verify response quality and relevance

### Performance Benchmarks

**Measure Response Times:**

Create a test script to measure AI response performance:

```bash
cat > scripts/benchmark.sh << 'EOF'
#!/bin/bash
echo "=== AI Development Environment Benchmarks ==="

# Test Perplexity response time
echo "Testing Perplexity MCP..."
start_time=$(date +%s.%N)
# Add actual test here
end_time=$(date +%s.%N)
echo "Perplexity response time: $(echo "$end_time - $start_time" | bc) seconds"

# Test Manus response time
echo "Testing Manus MCP..."
# Add actual test here

echo "Benchmark completed"
EOF
chmod +x scripts/benchmark.sh
```

## 🛠️ Troubleshooting Common Issues

### MCP Server Connection Problems

**Symptoms:**
- MCP indicator not appearing in Claude Desktop
- "Server not responding" errors
- Missing tools in Claude interface

**Solutions:**

1. **Check Server Status:**
   ```bash
   # Test Perplexity server manually
   cd ~/.local/share/mcp-servers/perplexity-mcp
   node build/index.js
   
   # Test Manus server manually
   cd ~/.local/share/mcp-servers/manus-mcp
   uv run mcp_server.py
   ```

2. **Verify Configuration:**
   ```bash
   # Validate JSON syntax
   python3 -m json.tool ~/Library/Application\ Support/Claude/claude_desktop_config.json
   ```

3. **Check Logs:**
   ```bash
   # Claude Desktop logs (macOS)
   tail -f ~/Library/Logs/Claude/claude_desktop.log
   
   # System logs
   tail -f /var/log/system.log | grep Claude
   ```

### API Key Issues

**Invalid API Key Errors:**

1. **Verify Key Format:**
   ```bash
   # Perplexity API keys start with 'pplx-'
   echo $PERPLEXITY_API_KEY | grep '^pplx-'
   ```

2. **Test API Access:**
   ```bash
   # Test Perplexity API directly
   curl -X POST https://api.perplexity.ai/chat/completions \
     -H "Authorization: Bearer $PERPLEXITY_API_KEY" \
     -H "Content-Type: application/json" \
     -d '{"model": "sonar", "messages": [{"role": "user", "content": "test"}]}'
   ```

### Performance Issues

**High Memory Usage:**

1. **Identify Resource Hogs:**
   ```bash
   # Monitor memory usage
   top -o MEM | grep -E "(Claude|node|python)"
   ```

2. **Optimize Configuration:**
   ```bash
   # Reduce concurrent connections
   MAX_MCP_CONNECTIONS=3
   
   # Enable resource limits
   MANUS_GLOBAL_TIMEOUT=30
   ```

**Slow Response Times:**

1. **Network Diagnostics:**
   ```bash
   # Test API connectivity
   ping api.perplexity.ai
   curl -w "@curl-format.txt" -o /dev/null -s https://api.perplexity.ai/
   ```

2. **Local Optimization:**
   ```bash
   # Clear caches
   npm cache clean --force
   pip cache purge
   
   # Restart services
   ./scripts/restart-mcp-servers.sh
   ```

## 📋 Post-Installation Checklist

- [ ] All MCP servers appear in Claude Desktop
- [ ] Perplexity search functionality works
- [ ] Manus web browsing and code execution work
- [ ] Filesystem access functions properly
- [ ] GitHub Copilot provides code suggestions
- [ ] VSCode extensions are installed and active
- [ ] API keys are properly configured
- [ ] Performance is acceptable for your hardware
- [ ] Backup configurations are created
- [ ] Team members can access shared configurations
- [ ] Documentation is updated with customizations

## 🔄 Maintenance and Updates

### Regular Maintenance Tasks

**Weekly:**
- Check for MCP server updates
- Monitor resource usage
- Review API usage and costs

**Monthly:**
- Update dependencies
- Review and rotate API keys
- Update documentation

**Quarterly:**
- Full system backup
- Performance optimization review
- Security audit

### Update Procedures

**Update MCP Servers:**
```bash
./scripts/update-mcp-servers.sh
```

**Update Template:**
```bash
# Add upstream remote
git remote add upstream https://github.com/johanlido/ai-mcp-template.git

# Fetch updates
git fetch upstream

# Merge updates (resolve conflicts as needed)
git merge upstream/main
```

This completes the comprehensive setup guide. The next sections will cover specific MCP server configurations and advanced usage patterns.

