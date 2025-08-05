# 🔧 Comprehensive Troubleshooting Guide

This guide helps you diagnose and resolve common issues with the AI MCP Template across all platforms.

## 🚨 Common Issues Quick Reference

| Problem | Symptoms | Solution | Platform |
|---------|----------|----------|----------|
| **Claude Desktop not detecting MCP** | No servers in dropdown | Check `claude_desktop_config.json` path | All |
| **API key errors** | 401/403 responses | Verify `.env` file configuration | All |
| **Permission denied errors** | File operation failures | Grant terminal full disk access | macOS |
| **Module not found errors** | Import/require failures | Reinstall dependencies | All |
| **Port already in use** | Server startup failures | Kill existing processes | All |

## 🔍 Diagnostic Steps

### 1. Run Health Check
```bash
# Run comprehensive system check
./scripts/health-check.sh

# Check specific components
./scripts/validate-setup.js
```

### 2. Verify Installation
```bash
# Check MCP server installations
ls -la ~/.local/share/mcp-servers/

# Verify Claude Desktop configuration
cat ~/.config/Claude/claude_desktop_config.json  # Linux
cat ~/Library/Application\ Support/Claude/claude_desktop_config.json  # macOS
```

### 3. Test API Connections
```bash
# Test Perplexity API
curl -X POST https://api.perplexity.ai/chat/completions \
  -H "Authorization: Bearer $PERPLEXITY_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model": "sonar", "messages": [{"role": "user", "content": "test"}], "max_tokens": 10}'

# Test GitHub API (if configured)
curl -H "Authorization: token $GITHUB_PERSONAL_ACCESS_TOKEN" \
  https://api.github.com/user
```

## 🖥️ Platform-Specific Issues

### macOS Issues

#### Issue: "Permission denied" accessing files
**Symptoms:**
- MCP servers can't read/write files
- "Operation not permitted" errors

**Solution:**
1. **Grant Full Disk Access:**
   - System Preferences → Security & Privacy → Privacy
   - Select "Full Disk Access"
   - Add Terminal.app and Claude.app

2. **Fix file permissions:**
   ```bash
   # Fix npm permissions
   sudo chown -R $(whoami) ~/.npm
   sudo chown -R $(whoami) /usr/local/lib/node_modules
   
   # Fix Python permissions
   sudo chown -R $(whoami) ~/.local
   ```

#### Issue: Gatekeeper blocking executables
**Symptoms:**
- "App can't be opened because it is from an unidentified developer"
- MCP servers fail to start

**Solution:**
```bash
# Remove quarantine attribute
sudo xattr -rd com.apple.quarantine /Applications/Claude.app
sudo xattr -rd com.apple.quarantine ~/.local/share/mcp-servers/

# For specific files
sudo xattr -rd com.apple.quarantine /path/to/blocked/file
```

#### Issue: Apple Silicon compatibility
**Symptoms:**
- Node.js modules fail to compile
- "Architecture mismatch" errors

**Solution:**
```bash
# Install Rosetta 2 if needed
sudo softwareupdate --install-rosetta --agree-to-license

# Rebuild native modules
npm rebuild

# Use x86 version if needed
arch -x86_64 npm install
```

### Windows Issues

#### Issue: PowerShell execution policy
**Symptoms:**
- Scripts cannot be executed
- "Execution of scripts is disabled" error

**Solution:**
```powershell
# Run as Administrator
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Or for single session
powershell -ExecutionPolicy Bypass -File script.ps1
```

#### Issue: Long path names
**Symptoms:**
- "Path too long" errors
- Installation failures in deep directories

**Solution:**
```powershell
# Enable long paths (Windows 10 1607+)
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Value 1 -PropertyType DWORD -Force

# Or use shorter installation path
mkdir C:\mcp
cd C:\mcp
git clone https://github.com/johanlido/ai-mcp-template.git
```

### Linux Issues

#### Issue: Missing dependencies
**Symptoms:**
- "Command not found" errors
- Compilation failures

**Solution:**
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

#### Issue: Claude Desktop not available
**Symptoms:**
- No native Claude Desktop app for Linux

**Solution:**
- Use Claude web interface at https://claude.ai
- MCP servers will still work with API integration
- Consider using Claude Desktop in Windows Subsystem for Linux (WSL)

## 🔧 MCP Server Specific Issues

### Perplexity MCP Issues

#### Issue: "PERPLEXITY_API_KEY not found"
**Diagnosis:**
```bash
# Check environment variable
echo $PERPLEXITY_API_KEY

# Verify in .env file
grep PERPLEXITY_API_KEY .env
```

**Solution:**
```bash
# Add to .env file
echo "PERPLEXITY_API_KEY=pplx-your-key-here" >> .env

# Restart Claude Desktop after updating .env
```

#### Issue: API rate limiting
**Symptoms:**
- "Rate limit exceeded" errors
- Slow or failed responses

**Solution:**
```bash
# Add rate limiting configuration to .env
echo "PERPLEXITY_RATE_LIMIT=10" >> .env
echo "PERPLEXITY_TIMEOUT=30000" >> .env
```

### Manus MCP Issues

#### Issue: Python environment not found
**Symptoms:**
- "No module named 'mcp_server'" errors
- Virtual environment activation failures

**Solution:**
```bash
cd ~/.local/share/mcp-servers/manus-mcp

# Recreate virtual environment
rm -rf .venv
uv venv
source .venv/bin/activate
uv pip install -e .
```

#### Issue: Browser automation failures
**Symptoms:**
- "Browser not found" errors
- Selenium/Playwright issues

**Solution:**
```bash
# Install browser dependencies
cd ~/.local/share/mcp-servers/manus-mcp
source .venv/bin/activate

# For Playwright
playwright install
playwright install-deps

# For Selenium
pip install selenium webdriver-manager
```

### Figma MCP Issues

#### Issue: Invalid Figma token
**Symptoms:**
- "Unauthorized" errors when accessing Figma
- Token validation failures

**Solution:**
1. **Generate new token:**
   - Go to Figma → Settings → Account → Personal Access Tokens
   - Create new token with appropriate permissions

2. **Update configuration:**
   ```bash
   # Add to .env file
   echo "FIGMA_ACCESS_TOKEN=your-new-token-here" >> .env
   ```

#### Issue: File access permissions
**Symptoms:**
- "File not found" errors
- Cannot access Figma files

**Solution:**
- Ensure Figma files are shared with your account
- Check file URLs are correct and accessible
- Verify token has read permissions for the files

## 🔄 Reset and Reinstall Procedures

### Complete Reset
```bash
# Stop all processes
pkill -f Claude
pkill -f node
pkill -f python

# Remove MCP servers
rm -rf ~/.local/share/mcp-servers

# Remove configuration
rm -f ~/.config/Claude/claude_desktop_config.json  # Linux
rm -f ~/Library/Application\ Support/Claude/claude_desktop_config.json  # macOS

# Clean npm cache
npm cache clean --force

# Clean Python cache
pip cache purge

# Restart setup
./scripts/interactive-setup.sh
```

### Selective Reinstall
```bash
# Reinstall specific MCP server
rm -rf ~/.local/share/mcp-servers/perplexity-mcp
./scripts/install-perplexity-mcp.sh

# Reconfigure Claude Desktop
./scripts/configure-claude.sh

# Run health check
./scripts/health-check.sh
```

## 📊 Performance Issues

### High Memory Usage
**Symptoms:**
- System slowdown
- Out of memory errors

**Diagnosis:**
```bash
# Monitor memory usage
top -o MEM | head -20

# Check specific processes
ps aux | grep -E "(Claude|node|python|mcp)"
```

**Solutions:**
```bash
# Restart Claude Desktop periodically
osascript -e 'quit app "Claude"'  # macOS
# Or manually quit and restart

# Limit concurrent MCP connections
# Edit claude_desktop_config.json to reduce active servers

# Increase system memory if possible
```

### Slow Response Times
**Symptoms:**
- Long delays in AI responses
- Timeout errors

**Diagnosis:**
```bash
# Test network connectivity
ping -c 4 api.perplexity.ai
ping -c 4 api.anthropic.com

# Measure API response times
curl -w "@curl-format.txt" -o /dev/null -s https://api.perplexity.ai/
```

**Solutions:**
```bash
# Optimize network settings
# Use faster DNS servers
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf
echo "nameserver 1.1.1.1" | sudo tee -a /etc/resolv.conf

# Reduce timeout values
export MANUS_GLOBAL_TIMEOUT=30
export PERPLEXITY_TIMEOUT=20000

# Use local caching
export ENABLE_RESPONSE_CACHE=true
```

## 🔍 Advanced Debugging

### Enable Debug Logging
```bash
# Add to .env file
echo "DEBUG=true" >> .env
echo "LOG_LEVEL=debug" >> .env
echo "VERBOSE_LOGGING=true" >> .env
```

### Collect Diagnostic Information
```bash
# Run diagnostic script
./scripts/collect-logs.sh

# Manual information gathering
echo "=== System Information ===" > debug.log
uname -a >> debug.log
node --version >> debug.log
python3 --version >> debug.log

echo "=== MCP Servers ===" >> debug.log
ls -la ~/.local/share/mcp-servers/ >> debug.log

echo "=== Claude Configuration ===" >> debug.log
cat ~/.config/Claude/claude_desktop_config.json >> debug.log 2>&1

echo "=== Environment Variables ===" >> debug.log
env | grep -E "(PERPLEXITY|FIGMA|GITHUB)" >> debug.log

echo "=== Process Information ===" >> debug.log
ps aux | grep -E "(Claude|node|python)" >> debug.log
```

### Network Debugging
```bash
# Test API endpoints
curl -v https://api.perplexity.ai/chat/completions
curl -v https://api.anthropic.com/v1/messages

# Check for proxy/firewall issues
curl -v --proxy-header "User-Agent: AI-MCP-Template" https://api.perplexity.ai/

# Monitor network traffic (macOS)
sudo tcpdump -i en0 host api.perplexity.ai
```

## 📞 Getting Help

### Before Reporting Issues
1. **Run health check:** `./scripts/health-check.sh`
2. **Collect logs:** `./scripts/collect-logs.sh`
3. **Check this guide** for similar issues
4. **Try reset procedure** if appropriate

### Information to Include
- **Operating system** and version
- **Hardware specifications** (RAM, CPU, architecture)
- **Error messages** (exact text)
- **Steps to reproduce** the issue
- **Output from health check** script
- **Relevant log files**

### Support Channels
- **GitHub Issues**: [Report bugs and feature requests](https://github.com/johanlido/ai-mcp-template/issues)
- **GitHub Discussions**: [Community support and questions](https://github.com/johanlido/ai-mcp-template/discussions)
- **Documentation**: Check all files in the `docs/` directory

### Emergency Procedures
If the system becomes completely unresponsive:

1. **Force quit all processes:**
   ```bash
   sudo pkill -f Claude
   sudo pkill -f node
   sudo pkill -f python
   ```

2. **Clear all caches:**
   ```bash
   rm -rf ~/.npm/_cacache
   rm -rf ~/.cache/pip
   npm cache clean --force
   ```

3. **Restart from clean state:**
   ```bash
   ./scripts/interactive-setup.sh
   ```

---

**💡 Pro Tip:** Most issues can be resolved by restarting Claude Desktop and running the health check script. When in doubt, try the reset procedure first!

