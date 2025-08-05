# 🎯 Best Practices Guide

This guide outlines professional best practices for using the AI development environment effectively and securely.

## 🔐 Security Best Practices

### API Key Management

**Never Commit API Keys to Version Control:**
```bash
# Always use .env files
echo ".env" >> .gitignore
echo "*.key" >> .gitignore
echo "secrets/" >> .gitignore

# Use environment variables in scripts
export PERPLEXITY_API_KEY="${PERPLEXITY_API_KEY}"
```

**Rotate API Keys Regularly:**
```bash
# Create key rotation script
cat > scripts/rotate-keys.sh << 'EOF'
#!/bin/bash
echo "API Key Rotation Checklist:"
echo "1. Generate new Perplexity API key"
echo "2. Update .env file"
echo "3. Test new key with health check"
echo "4. Revoke old key"
echo "5. Update team documentation"
EOF
```

**Use Key Validation:**
```bash
# Validate keys before use
validate_perplexity_key() {
    local key="$1"
    if [[ ! "$key" =~ ^pplx- ]]; then
        echo "Invalid Perplexity API key format"
        return 1
    fi
    
    # Test API call
    response=$(curl -s -X POST https://api.perplexity.ai/chat/completions \
        -H "Authorization: Bearer $key" \
        -H "Content-Type: application/json" \
        -d '{"model": "sonar", "messages": [{"role": "user", "content": "test"}], "max_tokens": 1}')
    
    if echo "$response" | grep -q "error"; then
        echo "API key validation failed"
        return 1
    fi
    
    echo "API key validated successfully"
    return 0
}
```

### Access Control

**Team Access Management:**
```bash
# Create team-specific configurations
mkdir -p configs/teams/{frontend,backend,devops}

# Frontend team - limited MCP servers
cat > configs/teams/frontend/claude_config.json << 'EOF'
{
  "mcpServers": {
    "perplexity-server": { ... },
    "figma-dev-mode": { ... },
    "filesystem": { ... }
  }
}
EOF

# Backend team - different server set
cat > configs/teams/backend/claude_config.json << 'EOF'
{
  "mcpServers": {
    "perplexity-server": { ... },
    "manus-mcp": { ... },
    "github": { ... }
  }
}
EOF
```

**Audit Logging:**
```bash
# Enable API usage logging
export LOG_API_USAGE=true
export API_LOG_FILE="logs/api-usage.log"

# Create log analysis script
cat > scripts/analyze-usage.sh << 'EOF'
#!/bin/bash
echo "=== API Usage Analysis ==="
echo "Total API calls today:"
grep "$(date +%Y-%m-%d)" logs/api-usage.log | wc -l

echo "Top users:"
grep "$(date +%Y-%m-%d)" logs/api-usage.log | cut -d' ' -f3 | sort | uniq -c | sort -nr

echo "API endpoints used:"
grep "$(date +%Y-%m-%d)" logs/api-usage.log | cut -d' ' -f4 | sort | uniq -c | sort -nr
EOF
```

## 🚀 Performance Optimization

### Resource Management

**Monitor System Resources:**
```bash
# Create resource monitoring script
cat > scripts/monitor-performance.sh << 'EOF'
#!/bin/bash

echo "=== AI Development Environment Performance Monitor ==="
echo "Timestamp: $(date)"
echo

# Memory usage
echo "Memory Usage:"
if [[ "$OSTYPE" == "darwin"* ]]; then
    vm_stat | awk '
    /Pages free/ { free = $3 }
    /Pages active/ { active = $3 }
    /Pages inactive/ { inactive = $3 }
    /Pages wired/ { wired = $3 }
    END {
        total = (free + active + inactive + wired) * 4096 / 1024 / 1024 / 1024
        used = (active + inactive + wired) * 4096 / 1024 / 1024 / 1024
        printf "Total: %.1fGB, Used: %.1fGB (%.1f%%)\n", total, used, used/total*100
    }'
else
    free -h | grep Mem
fi

# CPU usage by AI processes
echo -e "\nCPU Usage (AI Processes):"
ps aux | grep -E "(Claude|node.*mcp|python.*mcp)" | grep -v grep | awk '{print $3"% "$11}' | sort -nr

# Disk usage
echo -e "\nDisk Usage:"
du -sh ~/.local/share/mcp-servers/* 2>/dev/null | sort -hr

# Network connections
echo -e "\nActive Connections:"
netstat -an 2>/dev/null | grep -E "(3845|8000)" | wc -l || ss -an | grep -E "(3845|8000)" | wc -l

echo -e "\n=== End Monitor ==="
EOF

chmod +x scripts/monitor-performance.sh
```

**Optimize MCP Server Configuration:**
```bash
# Performance-optimized environment variables
cat > .env.performance << 'EOF'
# Reduce timeouts for faster responses
MANUS_GLOBAL_TIMEOUT=30

# Enable headless browser for better performance
MANUS_BROWSER_HEADLESS=true

# Limit search results to reduce processing time
MANUS_GOOGLE_SEARCH_MAX_RESULTS=5
PERPLEXITY_MAX_RESULTS=5

# Reduce concurrent connections
MAX_MCP_CONNECTIONS=3

# Enable caching
ENABLE_RESPONSE_CACHE=true
CACHE_TTL=300

# Optimize logging
LOG_LEVEL=WARNING
ENABLE_DEBUG_LOGGING=false
EOF
```

### Caching Strategies

**Implement Response Caching:**
```bash
# Create caching wrapper for API calls
cat > scripts/cache-wrapper.py << 'EOF'
#!/usr/bin/env python3
import hashlib
import json
import os
import time
from pathlib import Path

class APICache:
    def __init__(self, cache_dir="~/.cache/ai-dev-env", ttl=300):
        self.cache_dir = Path(cache_dir).expanduser()
        self.cache_dir.mkdir(parents=True, exist_ok=True)
        self.ttl = ttl
    
    def _get_cache_key(self, request_data):
        """Generate cache key from request data"""
        request_str = json.dumps(request_data, sort_keys=True)
        return hashlib.md5(request_str.encode()).hexdigest()
    
    def get(self, request_data):
        """Get cached response if available and not expired"""
        cache_key = self._get_cache_key(request_data)
        cache_file = self.cache_dir / f"{cache_key}.json"
        
        if cache_file.exists():
            with open(cache_file) as f:
                cached_data = json.load(f)
            
            if time.time() - cached_data['timestamp'] < self.ttl:
                return cached_data['response']
        
        return None
    
    def set(self, request_data, response):
        """Cache response data"""
        cache_key = self._get_cache_key(request_data)
        cache_file = self.cache_dir / f"{cache_key}.json"
        
        cached_data = {
            'timestamp': time.time(),
            'request': request_data,
            'response': response
        }
        
        with open(cache_file, 'w') as f:
            json.dump(cached_data, f)

# Usage example
if __name__ == "__main__":
    cache = APICache()
    
    # Example request
    request = {"query": "latest React features", "model": "sonar"}
    
    # Check cache first
    cached_response = cache.get(request)
    if cached_response:
        print("Using cached response")
        print(cached_response)
    else:
        print("Making new API call")
        # Make actual API call here
        response = {"result": "API response data"}
        cache.set(request, response)
EOF

chmod +x scripts/cache-wrapper.py
```

## 🔄 Development Workflow Best Practices

### Prompt Engineering

**Effective Prompt Patterns:**

1. **Context-Rich Prompts:**
   ```
   # Good
   "I'm building a React component for user authentication. 
   The component should handle login/logout, display user status, 
   and integrate with our existing Redux store. 
   Please generate the component with TypeScript and proper error handling."
   
   # Poor
   "Create a login component"
   ```

2. **Iterative Refinement:**
   ```
   # Initial prompt
   "Create a REST API endpoint for user registration"
   
   # Follow-up refinement
   "Add input validation, password hashing, and email verification to the registration endpoint"
   
   # Further refinement
   "Add rate limiting and CAPTCHA integration to prevent abuse"
   ```

3. **Multi-Server Coordination:**
   ```
   # Research phase (Perplexity)
   "Search for the latest best practices for Node.js API security in 2024"
   
   # Implementation phase (Manus)
   "Based on the research, implement a secure user authentication system with the recommended practices"
   
   # Design integration (Figma)
   "Generate the login form component based on the Figma design at [URL]"
   ```

### Code Quality Standards

**AI-Generated Code Review Checklist:**
```bash
# Create code review template
cat > .github/PULL_REQUEST_TEMPLATE.md << 'EOF'
## AI-Generated Code Review Checklist

### Code Quality
- [ ] Code follows project style guidelines
- [ ] No hardcoded values or magic numbers
- [ ] Proper error handling implemented
- [ ] Security best practices followed
- [ ] Performance considerations addressed

### AI Assistance
- [ ] AI-generated code has been reviewed and understood
- [ ] Prompts used are documented in commit messages
- [ ] Code has been tested beyond AI suggestions
- [ ] Dependencies and imports are appropriate

### Testing
- [ ] Unit tests added/updated
- [ ] Integration tests pass
- [ ] Manual testing completed
- [ ] Edge cases considered

### Documentation
- [ ] Code is self-documenting with clear variable names
- [ ] Complex logic is commented
- [ ] API documentation updated if applicable
- [ ] README updated if needed
EOF
```

**Automated Quality Checks:**
```bash
# Create pre-commit hook for AI-generated code
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash

echo "Running AI development environment quality checks..."

# Check for exposed API keys
if grep -r "pplx-" --include="*.js" --include="*.py" --include="*.json" . 2>/dev/null; then
    echo "ERROR: Potential API key found in code"
    exit 1
fi

# Check for TODO comments from AI
if grep -r "TODO.*AI\|TODO.*generated" --include="*.js" --include="*.py" . 2>/dev/null; then
    echo "WARNING: AI-generated TODO comments found - please review"
fi

# Validate configuration files
if [ -f claude_desktop_config.json ]; then
    python3 -m json.tool claude_desktop_config.json > /dev/null || {
        echo "ERROR: Invalid Claude Desktop configuration"
        exit 1
    }
fi

echo "Quality checks passed"
EOF

chmod +x .git/hooks/pre-commit
```

### Version Control Best Practices

**Commit Message Standards:**
```bash
# Create commit message template
cat > .gitmessage << 'EOF'
# AI-Assisted Development Commit Template
#
# Format: <type>(<scope>): <description>
#
# Types:
# feat: New feature (AI-generated or AI-assisted)
# fix: Bug fix (AI-suggested solution)
# docs: Documentation (AI-generated docs)
# style: Code style changes
# refactor: Code refactoring (AI-suggested improvements)
# test: Adding tests
# chore: Maintenance tasks
#
# AI Context (if applicable):
# - MCP Server used: [perplexity/manus/figma]
# - Prompt summary: [brief description of AI interaction]
# - Manual modifications: [what was changed after AI generation]
#
# Example:
# feat(auth): implement JWT authentication system
# 
# - Used Perplexity MCP to research latest JWT best practices
# - Generated initial implementation with Manus MCP
# - Added custom rate limiting and validation
# - Manually optimized for our specific use case
EOF

# Set as default commit template
git config commit.template .gitmessage
```

**Branch Strategy for AI Development:**
```bash
# Create branch naming convention
cat > docs/branching-strategy.md << 'EOF'
# AI Development Branching Strategy

## Branch Naming Convention

### Feature Branches
- `ai-feat/description` - AI-generated features
- `ai-research/topic` - Research and experimentation
- `ai-refactor/component` - AI-suggested refactoring

### Examples
- `ai-feat/user-authentication`
- `ai-research/react-performance`
- `ai-refactor/api-endpoints`

## Workflow

1. **Research Phase**
   ```bash
   git checkout -b ai-research/topic-name
   # Use Perplexity MCP for research
   # Document findings in research notes
   ```

2. **Implementation Phase**
   ```bash
   git checkout -b ai-feat/feature-name
   # Use Manus MCP for implementation
   # Commit AI-generated code with proper attribution
   ```

3. **Refinement Phase**
   ```bash
   # Manual review and optimization
   # Add tests and documentation
   # Prepare for code review
   ```

## Code Review Requirements

- All AI-generated code must be reviewed by a human
- Document the AI tools and prompts used
- Verify security and performance implications
- Ensure code aligns with project standards
EOF
```

## 📊 Monitoring and Analytics

### Usage Analytics

**Track AI Development Productivity:**
```bash
# Create productivity tracking script
cat > scripts/track-productivity.sh << 'EOF'
#!/bin/bash

METRICS_FILE="metrics/productivity-$(date +%Y-%m).json"
mkdir -p metrics

# Initialize metrics file if it doesn't exist
if [ ! -f "$METRICS_FILE" ]; then
    echo '{"ai_interactions": [], "code_generation": [], "research_queries": []}' > "$METRICS_FILE"
fi

# Function to log AI interaction
log_ai_interaction() {
    local server="$1"
    local type="$2"
    local duration="$3"
    
    python3 -c "
import json
import datetime

with open('$METRICS_FILE', 'r') as f:
    data = json.load(f)

interaction = {
    'timestamp': datetime.datetime.now().isoformat(),
    'server': '$server',
    'type': '$type',
    'duration': $duration
}

data['ai_interactions'].append(interaction)

with open('$METRICS_FILE', 'w') as f:
    json.dump(data, f, indent=2)
"
}

# Function to generate productivity report
generate_report() {
    python3 -c "
import json
import datetime
from collections import defaultdict

with open('$METRICS_FILE', 'r') as f:
    data = json.load(f)

print('=== AI Development Productivity Report ===')
print(f'Period: $(date +%Y-%m)')
print()

# Count interactions by server
server_counts = defaultdict(int)
for interaction in data['ai_interactions']:
    server_counts[interaction['server']] += 1

print('Interactions by MCP Server:')
for server, count in server_counts.items():
    print(f'  {server}: {count}')

print()
print(f'Total AI interactions: {len(data[\"ai_interactions\"])}')
print(f'Code generation events: {len(data[\"code_generation\"])}')
print(f'Research queries: {len(data[\"research_queries\"])}')
"
}

# Usage examples
case "$1" in
    "log")
        log_ai_interaction "$2" "$3" "$4"
        ;;
    "report")
        generate_report
        ;;
    *)
        echo "Usage: $0 {log|report}"
        echo "  log <server> <type> <duration>"
        echo "  report"
        ;;
esac
EOF

chmod +x scripts/track-productivity.sh
```

### Health Monitoring

**Automated Health Checks:**
```bash
# Create monitoring cron job
cat > scripts/setup-monitoring.sh << 'EOF'
#!/bin/bash

# Create monitoring script
cat > scripts/health-monitor.sh << 'MONITOR_EOF'
#!/bin/bash

LOG_FILE="logs/health-$(date +%Y-%m-%d).log"
mkdir -p logs

echo "$(date): Starting health check" >> "$LOG_FILE"

# Check MCP server status
./scripts/health-check.sh >> "$LOG_FILE" 2>&1

# Check resource usage
./scripts/monitor-performance.sh >> "$LOG_FILE" 2>&1

# Check API quotas (if applicable)
if [ -n "$PERPLEXITY_API_KEY" ]; then
    # Add API quota check here
    echo "$(date): API quota check completed" >> "$LOG_FILE"
fi

echo "$(date): Health check completed" >> "$LOG_FILE"
MONITOR_EOF

chmod +x scripts/health-monitor.sh

# Add to crontab (run every hour)
(crontab -l 2>/dev/null; echo "0 * * * * $(pwd)/scripts/health-monitor.sh") | crontab -

echo "Health monitoring setup completed"
echo "Logs will be written to logs/health-YYYY-MM-DD.log"
EOF

chmod +x scripts/setup-monitoring.sh
```

## 🎓 Training and Onboarding

### Team Onboarding Checklist

```bash
# Create onboarding script
cat > scripts/onboard-team-member.sh << 'EOF'
#!/bin/bash

echo "=== AI Development Environment Onboarding ==="
echo

read -p "Enter new team member's name: " MEMBER_NAME
read -p "Enter team (frontend/backend/devops): " TEAM

echo "Setting up environment for $MEMBER_NAME ($TEAM team)..."

# Create personal configuration
mkdir -p "configs/users/$MEMBER_NAME"

# Copy team-specific configuration
if [ -d "configs/teams/$TEAM" ]; then
    cp -r "configs/teams/$TEAM"/* "configs/users/$MEMBER_NAME/"
    echo "✓ Team-specific configuration applied"
else
    cp -r configs/claude-desktop/* "configs/users/$MEMBER_NAME/"
    echo "✓ Default configuration applied"
fi

# Create personal .env template
cp .env.example ".env.$MEMBER_NAME"
echo "✓ Personal environment template created"

# Generate onboarding checklist
cat > "onboarding-$MEMBER_NAME.md" << CHECKLIST_EOF
# Onboarding Checklist for $MEMBER_NAME

## Prerequisites
- [ ] Install VSCode with GitHub Copilot
- [ ] Install Claude Desktop
- [ ] Install Node.js 18+
- [ ] Install Python 3.11+
- [ ] Get Perplexity API key

## Setup Steps
- [ ] Clone repository
- [ ] Copy .env.$MEMBER_NAME to .env
- [ ] Fill in API keys in .env
- [ ] Run ./scripts/setup.sh
- [ ] Run ./scripts/install-mcp-servers.sh
- [ ] Run ./scripts/configure-claude.sh

## Verification
- [ ] MCP servers appear in Claude Desktop
- [ ] GitHub Copilot works in VSCode
- [ ] Can perform web search via Perplexity
- [ ] Can execute code via Manus (if applicable)

## Training
- [ ] Complete AI prompt engineering tutorial
- [ ] Review code quality standards
- [ ] Practice with sample projects
- [ ] Shadow experienced team member

## Resources
- Setup Guide: docs/setup-guide.md
- Best Practices: docs/best-practices.md
- Troubleshooting: docs/troubleshooting.md
- Team Standards: docs/team-standards.md
CHECKLIST_EOF

echo "✓ Onboarding checklist created: onboarding-$MEMBER_NAME.md"
echo
echo "Next steps:"
echo "1. Share onboarding-$MEMBER_NAME.md with the new team member"
echo "2. Schedule setup session"
echo "3. Assign mentor for first week"
echo "4. Add to team communication channels"
EOF

chmod +x scripts/onboard-team-member.sh
```

### Training Materials

**Create Interactive Tutorials:**
```bash
# Create tutorial script
cat > scripts/create-tutorial.sh << 'EOF'
#!/bin/bash

mkdir -p tutorials

# Basic usage tutorial
cat > tutorials/01-basic-usage.md << 'TUTORIAL_EOF'
# Tutorial 1: Basic AI Development Environment Usage

## Objective
Learn to use the AI development environment for basic coding tasks.

## Exercise 1: Research and Implementation
1. **Research Phase (Perplexity MCP)**
   - Ask Claude: "Search for the latest React hooks best practices"
   - Review the research results
   - Identify key patterns and recommendations

2. **Implementation Phase (Manus MCP)**
   - Ask Claude: "Create a custom React hook for API data fetching based on the research"
   - Review the generated code
   - Test the implementation

3. **Refinement Phase**
   - Ask for improvements: "Add error handling and loading states to the hook"
   - Compare with your own implementation approach
   - Document the differences

## Exercise 2: Design Integration (if Figma available)
1. **Design Analysis**
   - Share a Figma component URL with Claude
   - Ask: "Implement this design as a React component"
   - Review the generated code for design accuracy

2. **Code Quality Review**
   - Check for responsive design implementation
   - Verify accessibility features
   - Test cross-browser compatibility

## Reflection Questions
- How did AI assistance change your development approach?
- What types of tasks were most effectively handled by AI?
- Where did you need to provide additional guidance or corrections?
- How can you improve your prompts for better results?

## Next Steps
- Complete Tutorial 2: Advanced Prompt Engineering
- Practice with your own project requirements
- Share learnings with team members
TUTORIAL_EOF

echo "Tutorial created: tutorials/01-basic-usage.md"
EOF

chmod +x scripts/create-tutorial.sh
```

This comprehensive best practices guide provides the foundation for professional, secure, and efficient use of the AI development environment. Teams should customize these practices based on their specific requirements and organizational policies.

