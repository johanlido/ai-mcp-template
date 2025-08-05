# 🔧 Troubleshooting Guide

This guide helps you diagnose and resolve common issues with the AI development environment.

## 🚨 Common Issues and Solutions

### MCP Server Connection Issues

#### Issue: MCP Servers Not Appearing in Claude Desktop

**Symptoms:**
- No MCP server indicator (🔌) in Claude Desktop
- Empty tools list when clicking the indicator
- "No MCP servers configured" message

**Diagnostic Steps:**

1. **Check Claude Desktop Configuration:**
   ```bash
   # macOS
   cat ~/Library/Application\ Support/Claude/claude_desktop_config.json
   
   # Linux
   cat ~/.config/Claude/claude_desktop_config.json
   ```

2. **Validate JSON Syntax:**
   ```bash
   python3 -m json.tool claude_desktop_config.json
   # or
   jq . claude_desktop_config.json
   ```

3. **Verify File Paths:**
   ```bash
   # Check if MCP server files exist
   ls -la ~/.local/share/mcp-servers/perplexity-mcp/build/index.js
   ls -la ~/.local/share/mcp-servers/manus-mcp/mcp_server.py
   ```

**Solutions:**

1. **Regenerate Configuration:**
   ```bash
   ./scripts/configure-claude.sh
   ```

2. **Manual Configuration Fix:**
   ```bash
   # Backup current config
   cp claude_desktop_config.json claude_desktop_config.json.backup
   
   # Use template
   cp configs/claude-desktop/claude_desktop_config.json claude_desktop_config.json
   
   # Update paths manually
   sed -i "s|/ABSOLUTE/PATH/TO|$HOME/.local/share/mcp-servers|g" claude_desktop_config.json
   ```

3. **Restart Claude Desktop:**
   - Completely quit Claude Desktop (Cmd+Q on Mac)
   - Wait 5 seconds
   - Relaunch Claude Desktop

#### Issue: Individual MCP Server Failures

**Perplexity MCP Server Issues:**

*Error: "PERPLEXITY_API_KEY not found"*
```bash
# Check environment variable
echo $PERPLEXITY_API_KEY

# Verify in .env file
grep PERPLEXITY_API_KEY .env

# Test API key directly
curl -X POST https://api.perplexity.ai/chat/completions \
  -H "Authorization: Bearer $PERPLEXITY_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model": "sonar", "messages": [{"role": "user", "content": "test"}]}'
```

*Error: "Module not found" or build failures*
```bash
cd ~/.local/share/mcp-servers/perplexity-mcp

# Clean and rebuild
rm -rf node_modules package-lock.json
npm install
npm run build

# Test manually
node build/index.js
```

**Manus MCP Server Issues:**

*Error: "Python environment not found"*
```bash
cd ~/.local/share/mcp-servers/manus-mcp

# Check virtual environment
ls -la .venv/

# Recreate if missing
uv venv
source .venv/bin/activate
uv pip install -e .

# Test manually
uv run mcp_server.py
```

*Error: "Sandbox directory not accessible"*
```bash
# Check sandbox directory
ls -la ~/manus-sandbox

# Create if missing
mkdir -p ~/manus-sandbox
chmod 755 ~/manus-sandbox

# Update permissions
chown $USER:$USER ~/manus-sandbox
```

### API Key and Authentication Issues

#### Issue: Invalid or Expired API Keys

**Perplexity API Key Problems:**

1. **Verify Key Format:**
   ```bash
   # Perplexity keys start with 'pplx-'
   echo $PERPLEXITY_API_KEY | grep '^pplx-'
   ```

2. **Check Key Status:**
   ```bash
   # Test with minimal request
   curl -X POST https://api.perplexity.ai/chat/completions \
     -H "Authorization: Bearer $PERPLEXITY_API_KEY" \
     -H "Content-Type: application/json" \
     -d '{
       "model": "sonar",
       "messages": [{"role": "user", "content": "Hello"}],
       "max_tokens": 10
     }'
   ```

3. **Common Error Responses:**
   ```json
   // Invalid key
   {"error": {"type": "invalid_request_error", "message": "Invalid API key"}}
   
   // Quota exceeded
   {"error": {"type": "quota_exceeded", "message": "Rate limit exceeded"}}
   
   // Expired key
   {"error": {"type": "authentication_error", "message": "API key expired"}}
   ```

**GitHub Token Issues:**

1. **Verify Token Permissions:**
   ```bash
   curl -H "Authorization: token $GITHUB_PERSONAL_ACCESS_TOKEN" \
     https://api.github.com/user
   ```

2. **Required Scopes:**
   - `repo` (for repository access)
   - `read:user` (for user information)
   - `read:org` (for organization access, if needed)

### Performance and Resource Issues

#### Issue: High Memory Usage

**Diagnostic Commands:**
```bash
# Monitor memory usage
top -o MEM | head -20

# Specific to AI development environment
ps aux | grep -E "(Claude|node|python|mcp)" | awk '{print $1, $2, $4, $11}'

# Memory usage by directory
du -sh ~/.local/share/mcp-servers/*
```

**Solutions:**

1. **Optimize MCP Server Configuration:**
   ```bash
   # Reduce timeouts
   export MANUS_GLOBAL_TIMEOUT=30
   
   # Enable headless browser
   export MANUS_BROWSER_HEADLESS=true
   
   # Limit search results
   export MANUS_GOOGLE_SEARCH_MAX_RESULTS=5
   ```

2. **Restart Services:**
   ```bash
   # Create restart script
   cat > scripts/restart-mcp-servers.sh << 'EOF'
   #!/bin/bash
   echo "Restarting MCP servers..."
   
   # Kill existing processes
   pkill -f "perplexity-mcp"
   pkill -f "manus-mcp"
   
   # Wait for cleanup
   sleep 2
   
   # Restart Claude Desktop
   osascript -e 'quit app "Claude"'
   sleep 2
   open -a Claude
   
   echo "MCP servers restarted"
   EOF
   
   chmod +x scripts/restart-mcp-servers.sh
   ./scripts/restart-mcp-servers.sh
   ```

#### Issue: Slow Response Times

**Network Diagnostics:**
```bash
# Test API connectivity
ping -c 4 api.perplexity.ai
ping -c 4 api.anthropic.com

# Measure response times
curl -w "@curl-format.txt" -o /dev/null -s https://api.perplexity.ai/

# Create curl timing format file
cat > curl-format.txt << 'EOF'
     time_namelookup:  %{time_namelookup}\n
        time_connect:  %{time_connect}\n
     time_appconnect:  %{time_appconnect}\n
    time_pretransfer:  %{time_pretransfer}\n
       time_redirect:  %{time_redirect}\n
  time_starttransfer:  %{time_starttransfer}\n
                     ----------\n
          time_total:  %{time_total}\n
EOF
```

**Performance Optimization:**
```bash
# Clear caches
npm cache clean --force
pip cache purge

# Update DNS settings (macOS)
sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder

# Update DNS settings (Linux)
sudo systemctl restart systemd-resolved
```

### VSCode and GitHub Copilot Issues

#### Issue: GitHub Copilot Not Working

**Diagnostic Steps:**

1. **Check Copilot Status:**
   - Open VSCode
   - Look for Copilot icon in status bar
   - Click icon to see status

2. **Verify Authentication:**
   ```bash
   # Check GitHub CLI authentication
   gh auth status
   
   # Re-authenticate if needed
   gh auth login
   ```

3. **Check Extension Status:**
   - Open Extensions view (Ctrl+Shift+X)
   - Search for "GitHub Copilot"
   - Ensure extension is enabled

**Solutions:**

1. **Reinstall Copilot Extension:**
   ```bash
   # Uninstall and reinstall
   code --uninstall-extension GitHub.copilot
   code --install-extension GitHub.copilot
   ```

2. **Reset Copilot Settings:**
   ```json
   // In VSCode settings.json
   {
     "github.copilot.enable": {
       "*": true
     },
     "github.copilot.editor.enableAutoCompletions": true
   }
   ```

3. **Clear VSCode Cache:**
   ```bash
   # macOS
   rm -rf ~/Library/Caches/com.microsoft.VSCode
   
   # Linux
   rm -rf ~/.cache/vscode
   ```

### Operating System Specific Issues

#### macOS Issues

**Issue: Permission Denied Errors**
```bash
# Fix npm permissions
sudo chown -R $(whoami) ~/.npm
sudo chown -R $(whoami) /usr/local/lib/node_modules

# Fix Python permissions
sudo chown -R $(whoami) ~/.local
```

**Issue: Gatekeeper Blocking Executables**
```bash
# Allow specific executable
sudo xattr -rd com.apple.quarantine /path/to/executable

# Disable Gatekeeper temporarily (not recommended)
sudo spctl --master-disable
```

#### Linux Issues

**Issue: Missing Dependencies**
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install -y build-essential python3-dev nodejs npm git curl

# CentOS/RHEL
sudo yum groupinstall "Development Tools"
sudo yum install python3-devel nodejs npm git curl

# Arch Linux
sudo pacman -S base-devel python nodejs npm git curl
```

**Issue: AppImage Execution Problems**
```bash
# Make AppImage executable
chmod +x Claude-*.AppImage

# Install FUSE if needed
sudo apt install fuse

# Run with --no-sandbox if needed
./Claude-*.AppImage --no-sandbox
```

## 🔍 Diagnostic Tools and Scripts

### System Information Script

```bash
cat > scripts/system-info.sh << 'EOF'
#!/bin/bash

echo "=== AI Development Environment System Information ==="
echo

echo "Operating System:"
uname -a
echo

echo "Memory Information:"
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Total RAM: $(($(sysctl -n hw.memsize) / 1024 / 1024 / 1024))GB"
    vm_stat | grep -E "(free|active|inactive|wired)"
else
    free -h
fi
echo

echo "Disk Space:"
df -h | grep -E "(/$|/home)"
echo

echo "Node.js Information:"
node --version
npm --version
echo

echo "Python Information:"
python3 --version
pip3 --version
if command -v uv &> /dev/null; then
    echo "uv version: $(uv --version)"
fi
echo

echo "Git Information:"
git --version
echo

echo "VSCode Information:"
if command -v code &> /dev/null; then
    code --version
else
    echo "VSCode not found in PATH"
fi
echo

echo "Claude Desktop:"
if [[ "$OSTYPE" == "darwin"* ]]; then
    if [ -d "/Applications/Claude.app" ]; then
        echo "Claude Desktop: Installed"
    else
        echo "Claude Desktop: Not found"
    fi
else
    echo "Claude Desktop: Check manually"
fi
echo

echo "MCP Servers:"
if [ -d ~/.local/share/mcp-servers ]; then
    ls -la ~/.local/share/mcp-servers/
else
    echo "MCP servers directory not found"
fi
EOF

chmod +x scripts/system-info.sh
```

### MCP Server Health Check

```bash
cat > scripts/health-check.sh << 'EOF'
#!/bin/bash

echo "=== MCP Server Health Check ==="
echo

# Check Perplexity MCP
echo "Checking Perplexity MCP..."
if [ -f ~/.local/share/mcp-servers/perplexity-mcp/build/index.js ]; then
    echo "✓ Perplexity MCP files found"
    cd ~/.local/share/mcp-servers/perplexity-mcp
    if timeout 10s node build/index.js --version 2>/dev/null; then
        echo "✓ Perplexity MCP executable"
    else
        echo "✗ Perplexity MCP not executable"
    fi
else
    echo "✗ Perplexity MCP not found"
fi
echo

# Check Manus MCP
echo "Checking Manus MCP..."
if [ -f ~/.local/share/mcp-servers/manus-mcp/mcp_server.py ]; then
    echo "✓ Manus MCP files found"
    cd ~/.local/share/mcp-servers/manus-mcp
    if [ -d .venv ]; then
        echo "✓ Manus virtual environment found"
        if timeout 10s uv run mcp_server.py --version 2>/dev/null; then
            echo "✓ Manus MCP executable"
        else
            echo "✗ Manus MCP not executable"
        fi
    else
        echo "✗ Manus virtual environment not found"
    fi
else
    echo "✗ Manus MCP not found"
fi
echo

# Check Claude Desktop configuration
echo "Checking Claude Desktop configuration..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    config_file="$HOME/Library/Application Support/Claude/claude_desktop_config.json"
else
    config_file="$HOME/.config/Claude/claude_desktop_config.json"
fi

if [ -f "$config_file" ]; then
    echo "✓ Claude Desktop config found"
    if python3 -m json.tool "$config_file" > /dev/null 2>&1; then
        echo "✓ Claude Desktop config is valid JSON"
        server_count=$(python3 -c "import json; print(len(json.load(open('$config_file'))['mcpServers']))")
        echo "✓ $server_count MCP servers configured"
    else
        echo "✗ Claude Desktop config is invalid JSON"
    fi
else
    echo "✗ Claude Desktop config not found"
fi
echo

# Check API keys
echo "Checking API keys..."
if [ -f .env ]; then
    source .env
    if [ -n "$PERPLEXITY_API_KEY" ] && [ "$PERPLEXITY_API_KEY" != "your_perplexity_api_key_here" ]; then
        echo "✓ Perplexity API key configured"
    else
        echo "✗ Perplexity API key not configured"
    fi
    
    if [ -n "$GITHUB_PERSONAL_ACCESS_TOKEN" ] && [ "$GITHUB_PERSONAL_ACCESS_TOKEN" != "your_github_token_here" ]; then
        echo "✓ GitHub token configured"
    else
        echo "ℹ GitHub token not configured (optional)"
    fi
else
    echo "✗ .env file not found"
fi

echo
echo "Health check completed"
EOF

chmod +x scripts/health-check.sh
```

### Log Collection Script

```bash
cat > scripts/collect-logs.sh << 'EOF'
#!/bin/bash

LOG_DIR="logs/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$LOG_DIR"

echo "Collecting logs in $LOG_DIR..."

# System information
./scripts/system-info.sh > "$LOG_DIR/system-info.txt" 2>&1

# Health check
./scripts/health-check.sh > "$LOG_DIR/health-check.txt" 2>&1

# Configuration files
if [[ "$OSTYPE" == "darwin"* ]]; then
    cp "$HOME/Library/Application Support/Claude/claude_desktop_config.json" "$LOG_DIR/" 2>/dev/null || echo "Claude config not found"
else
    cp "$HOME/.config/Claude/claude_desktop_config.json" "$LOG_DIR/" 2>/dev/null || echo "Claude config not found"
fi

cp .env "$LOG_DIR/env-sanitized.txt" 2>/dev/null && sed -i 's/=.*/=***REDACTED***/g' "$LOG_DIR/env-sanitized.txt"

# Process information
ps aux | grep -E "(Claude|node|python|mcp)" > "$LOG_DIR/processes.txt"

# Network information
netstat -an | grep -E "(3845|8000)" > "$LOG_DIR/network.txt" 2>/dev/null || ss -an | grep -E "(3845|8000)" > "$LOG_DIR/network.txt"

echo "Logs collected in $LOG_DIR"
echo "Share this directory when reporting issues"
EOF

chmod +x scripts/collect-logs.sh
```

## 📞 Getting Help

### Before Reporting Issues

1. **Run Diagnostic Scripts:**
   ```bash
   ./scripts/health-check.sh
   ./scripts/collect-logs.sh
   ```

2. **Check Common Solutions:**
   - Restart Claude Desktop
   - Verify API keys
   - Check internet connectivity
   - Review configuration files

3. **Gather Information:**
   - Operating system and version
   - Hardware specifications
   - Error messages (exact text)
   - Steps to reproduce the issue

### Support Channels

- **GitHub Issues**: [Repository Issues](https://github.com/johanlido/ai-mcp-template/issues)
- **Documentation**: Check all files in the `docs/` directory
- **Community**: [GitHub Discussions](https://github.com/johanlido/ai-mcp-template/discussions)

### Reporting Bugs

**Include in Bug Reports:**
- Output from `./scripts/collect-logs.sh`
- Steps to reproduce the issue
- Expected vs. actual behavior
- Screenshots if applicable
- System information from `./scripts/system-info.sh`

This troubleshooting guide should help resolve most common issues. If you encounter problems not covered here, please report them so we can improve the documentation.

