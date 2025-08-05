# 🎨 Template Customization Guide

This guide helps you customize the AI Development Environment Template for your specific needs.

## 🔧 Initial Customization Steps

### 1. Repository Information

After creating your repository from this template, update these files:

**README.md**
- Replace all instances of `johanlido/ai-mcp-template` with your repository path
- Update the repository description and badges
- Add your own contact information and support links
- Customize the feature list based on what you plan to use

**Example replacements:**
```bash
# Find and replace in README.md
johanlido/ai-mcp-template → your-username/your-repo-name
```

### 2. Environment Configuration

**Copy and customize the environment file:**
```bash
cp .env.example .env
```

**Edit `.env` with your specific values:**
- Add your actual API keys
- Customize paths for your system
- Set organization-specific settings
- Configure team identifiers

### 3. MCP Server Selection

**Choose which MCP servers to include:**

Edit `configs/claude-desktop/claude_desktop_config.json` to include only the servers you need:

```json
{
  "mcpServers": {
    // Keep only the servers you want to use
    "perplexity-server": { ... },
    // "manus-mcp": { ... },  // Comment out unused servers
    // "figma-dev-mode": { ... }
  }
}
```

### 4. VSCode Configuration

**Customize VSCode settings in `configs/vscode/settings.json`:**
- Adjust formatting preferences
- Modify language-specific settings
- Add/remove extensions based on your stack
- Configure team coding standards

### 5. Team-Specific Customization

**For team/organization use:**

1. **Create team-specific branches:**
   ```bash
   git checkout -b team-frontend
   git checkout -b team-backend
   git checkout -b team-mobile
   ```

2. **Customize per team:**
   - Different MCP server configurations
   - Team-specific VSCode settings
   - Role-based API access

3. **Create team setup scripts:**
   ```bash
   cp scripts/setup.sh scripts/setup-frontend-team.sh
   # Customize for frontend team needs
   ```

## 🏢 Organization-Level Customization

### 1. Security and Compliance

**Update security settings in `.env.example`:**
```bash
# Add your organization's security requirements
ORG_SECURITY_POLICY=strict
ALLOWED_API_ENDPOINTS=your-approved-endpoints
AUDIT_LOGGING=enabled
```

**Create organization-specific documentation:**
- Security guidelines
- API usage policies
- Code review requirements
- Compliance checklists

### 2. Infrastructure Integration

**Customize for your infrastructure:**

1. **CI/CD Integration:**
   ```bash
   mkdir -p .github/workflows
   # Add your CI/CD pipelines
   ```

2. **Docker Configuration:**
   ```bash
   # Create Dockerfile for containerized development
   # Add docker-compose.yml for team environments
   ```

3. **Cloud Provider Integration:**
   ```bash
   # Add cloud-specific configurations
   # AWS, Azure, GCP setup scripts
   ```

### 3. Monitoring and Analytics

**Add monitoring configuration:**
```bash
# In .env.example, add:
MONITORING_ENDPOINT=your-monitoring-service
ERROR_TRACKING=your-error-service
PERFORMANCE_ANALYTICS=your-analytics-service
```

## 🎯 Use Case Specific Customization

### For Web Development Teams

**Focus on web-specific tools:**
```json
{
  "mcpServers": {
    "perplexity-server": { ... },
    "figma-dev-mode": { ... },
    "browser-automation": { ... }
  }
}
```

**Add web-specific VSCode extensions:**
```json
{
  "recommendations": [
    "ms-vscode.vscode-typescript-next",
    "bradlc.vscode-tailwindcss",
    "esbenp.prettier-vscode",
    "ms-vscode.vscode-json"
  ]
}
```

### For Data Science Teams

**Focus on data science tools:**
```json
{
  "mcpServers": {
    "perplexity-server": { ... },
    "jupyter-mcp": { ... },
    "data-analysis-mcp": { ... }
  }
}
```

**Add data science VSCode extensions:**
```json
{
  "recommendations": [
    "ms-python.python",
    "ms-toolsai.jupyter",
    "ms-python.black-formatter",
    "ms-python.pylint"
  ]
}
```

### For Mobile Development Teams

**Focus on mobile development:**
```json
{
  "mcpServers": {
    "perplexity-server": { ... },
    "figma-dev-mode": { ... },
    "mobile-testing-mcp": { ... }
  }
}
```

## 🔄 Maintenance and Updates

### 1. Keeping Your Template Updated

**Set up upstream tracking:**
```bash
git remote add upstream https://github.com/johanlido/ai-mcp-template.git
git fetch upstream
```

**Merge updates selectively:**
```bash
git checkout main
git merge upstream/main
# Resolve conflicts, keeping your customizations
```

### 2. Version Management

**Tag your customized versions:**
```bash
git tag -a v1.0-custom -m "Initial customized version for our team"
git push origin v1.0-custom
```

### 3. Documentation Updates

**Keep your documentation current:**
- Update README.md with your changes
- Document custom configurations
- Maintain troubleshooting guides
- Update team onboarding instructions

## 🤝 Contributing Back to Template

### 1. Identify Improvements

**Consider contributing back:**
- Bug fixes in setup scripts
- New MCP server integrations
- Documentation improvements
- Cross-platform compatibility fixes

### 2. Contribution Process

1. **Fork the original template repository**
2. **Create a feature branch**
3. **Make your improvements**
4. **Test thoroughly**
5. **Submit a pull request**

### 3. Sharing Configurations

**Share useful configurations:**
- Create example configurations for specific use cases
- Document best practices you've discovered
- Share troubleshooting solutions

## 📋 Customization Checklist

- [ ] Updated repository information in README.md
- [ ] Configured .env with your API keys
- [ ] Selected appropriate MCP servers
- [ ] Customized VSCode settings
- [ ] Added team-specific configurations
- [ ] Updated security settings
- [ ] Added monitoring/analytics
- [ ] Created team documentation
- [ ] Set up CI/CD integration
- [ ] Tested complete setup
- [ ] Documented customizations
- [ ] Trained team members

## 🆘 Getting Help

- **Template Issues**: [Original Repository Issues](https://github.com/johanlido/ai-mcp-template/issues)
- **Customization Help**: Check the [Discussions](https://github.com/johanlido/ai-mcp-template/discussions)
- **Documentation**: See the `docs/` directory for detailed guides

---

**Remember**: This template is designed to be flexible. Don't hesitate to modify it extensively to fit your specific needs!

