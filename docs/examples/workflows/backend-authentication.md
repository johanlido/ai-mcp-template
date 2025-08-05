# 🔐 Backend Authentication Workflow

This workflow demonstrates building a secure, production-ready authentication system using the AI MCP Template.

## 🎯 Scenario: Enterprise-Grade Authentication API

**Goal:** Build a comprehensive authentication system with JWT tokens, role-based access control, and security best practices.

**Features:**
- User registration and login
- JWT token management with refresh tokens
- Role-based access control (RBAC)
- Password reset functionality
- Rate limiting and security headers
- Audit logging and monitoring

**Tools Used:**
- **Perplexity MCP**: Research security best practices
- **Manus MCP**: API testing and validation
- **GitHub Copilot**: Code generation with security patterns

## 📋 Step-by-Step Workflow

### Phase 1: Security Research and Architecture (10-15 minutes)

#### 1.1 Research Current Security Standards
**Claude Prompt:**
```
Using Perplexity, search for "Node.js authentication security best practices 2024" and "JWT security vulnerabilities prevention". Focus on:
1. OWASP authentication guidelines
2. JWT security best practices
3. Password hashing standards
4. Rate limiting strategies
5. Session management security
```

**Expected Research Areas:**
- OWASP Top 10 authentication vulnerabilities
- JWT vs session-based authentication
- Password hashing algorithms (bcrypt, Argon2)
- Multi-factor authentication implementation
- API security headers and CORS configuration

#### 1.2 Architecture Planning
**Claude Prompt:**
```
Based on the security research, design an authentication system architecture with:
- Database schema for users, roles, and sessions
- API endpoint structure
- Security middleware stack
- Token management strategy
- Error handling and logging approach
```

**Expected Architecture:**
```
Authentication System
├── Models/
│   ├── User (id, email, password_hash, role, created_at, updated_at)
│   ├── Role (id, name, permissions)
│   ├── RefreshToken (id, user_id, token, expires_at)
│   └── AuditLog (id, user_id, action, ip_address, timestamp)
├── Middleware/
│   ├── Authentication (JWT verification)
│   ├── Authorization (role-based access)
│   ├── Rate Limiting (request throttling)
│   └── Security Headers (CORS, CSP, etc.)
├── Controllers/
│   ├── AuthController (login, register, refresh)
│   ├── UserController (profile, password change)
│   └── AdminController (user management)
└── Services/
    ├── TokenService (JWT generation/validation)
    ├── PasswordService (hashing/verification)
    └── AuditService (security logging)
```

### Phase 2: Project Setup and Dependencies (5-10 minutes)

#### 2.1 Initialize Node.js Project
**Claude Prompt:**
```
Create a Node.js authentication API project with these requirements:
- Express.js framework
- TypeScript configuration
- Security-focused dependencies (helmet, cors, rate-limiter)
- Database ORM (Prisma or TypeORM)
- Testing framework (Jest)
- Environment configuration
- Docker setup for development

Provide the complete package.json and initial project structure.
```

#### 2.2 Security Configuration
**Claude Prompt:**
```
Set up comprehensive security configuration including:
- Environment variable validation
- CORS policy for production
- Security headers with Helmet
- Rate limiting configuration
- Input validation with Joi or Zod
- Logging configuration with Winston
```

### Phase 3: Database Schema and Models (15-20 minutes)

#### 3.1 Design Database Schema
**Claude Prompt:**
```
Create a Prisma schema for the authentication system with:
- User model with secure password storage
- Role-based access control tables
- Refresh token management
- Audit logging for security events
- Proper indexes for performance
- Data validation constraints
```

**Expected Schema:**
```prisma
model User {
  id            String   @id @default(cuid())
  email         String   @unique
  passwordHash  String
  firstName     String?
  lastName      String?
  isActive      Boolean  @default(true)
  isVerified    Boolean  @default(false)
  lastLoginAt   DateTime?
  createdAt     DateTime @default(now())
  updatedAt     DateTime @updatedAt
  
  role          Role     @relation(fields: [roleId], references: [id])
  roleId        String
  
  refreshTokens RefreshToken[]
  auditLogs     AuditLog[]
  
  @@map("users")
}

model Role {
  id          String   @id @default(cuid())
  name        String   @unique
  permissions Json
  createdAt   DateTime @default(now())
  
  users       User[]
  
  @@map("roles")
}

model RefreshToken {
  id        String   @id @default(cuid())
  token     String   @unique
  expiresAt DateTime
  createdAt DateTime @default(now())
  
  user      User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  userId    String
  
  @@map("refresh_tokens")
}

model AuditLog {
  id        String   @id @default(cuid())
  action    String
  resource  String?
  ipAddress String
  userAgent String?
  createdAt DateTime @default(now())
  
  user      User?    @relation(fields: [userId], references: [id])
  userId    String?
  
  @@map("audit_logs")
}
```

#### 3.2 Create Database Models
**GitHub Copilot + Claude:**
```typescript
// Generate TypeScript interfaces and database access layers
// with proper error handling and validation
```

### Phase 4: Authentication Core Implementation (30-40 minutes)

#### 4.1 Password Security Service
**Claude Prompt:**
```
Create a secure password service with:
- Bcrypt hashing with appropriate salt rounds
- Password strength validation
- Secure password comparison
- Password history to prevent reuse
- Rate limiting for password attempts
```

**Expected Implementation:**
```typescript
import bcrypt from 'bcrypt';
import { z } from 'zod';

const SALT_ROUNDS = 12;
const MAX_LOGIN_ATTEMPTS = 5;
const LOCKOUT_TIME = 15 * 60 * 1000; // 15 minutes

export class PasswordService {
  private static readonly passwordSchema = z.string()
    .min(8, 'Password must be at least 8 characters')
    .regex(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]/, 
           'Password must contain uppercase, lowercase, number, and special character');

  static async hashPassword(password: string): Promise<string> {
    this.passwordSchema.parse(password);
    return bcrypt.hash(password, SALT_ROUNDS);
  }

  static async verifyPassword(password: string, hash: string): Promise<boolean> {
    return bcrypt.compare(password, hash);
  }

  static validatePasswordStrength(password: string): boolean {
    try {
      this.passwordSchema.parse(password);
      return true;
    } catch {
      return false;
    }
  }
}
```

#### 4.2 JWT Token Service
**Claude Prompt:**
```
Implement a comprehensive JWT token service with:
- Access token generation (short-lived, 15 minutes)
- Refresh token generation (long-lived, 7 days)
- Token validation and verification
- Token blacklisting for logout
- Automatic token rotation
- Secure token storage recommendations
```

#### 4.3 Authentication Middleware
**Claude Prompt:**
```
Create authentication middleware that:
- Validates JWT tokens from Authorization header
- Handles token expiration gracefully
- Implements role-based access control
- Logs authentication attempts
- Provides clear error responses
- Supports both required and optional authentication
```

### Phase 5: API Endpoints Implementation (25-35 minutes)

#### 5.1 Registration Endpoint
**Claude Prompt:**
```
Create a user registration endpoint with:
- Input validation (email, password, name)
- Duplicate email checking
- Password hashing
- Email verification token generation
- Welcome email sending (mock implementation)
- Audit logging
- Rate limiting (5 attempts per hour per IP)
```

#### 5.2 Login Endpoint
**Claude Prompt:**
```
Implement secure login endpoint with:
- Email/password validation
- Brute force protection
- Account lockout after failed attempts
- JWT token generation (access + refresh)
- Login audit logging
- Device/location tracking
- Remember me functionality
```

#### 5.3 Token Refresh Endpoint
**Claude Prompt:**
```
Create token refresh endpoint that:
- Validates refresh token
- Generates new access token
- Rotates refresh token for security
- Handles token family invalidation
- Logs refresh attempts
- Implements sliding session expiration
```

#### 5.4 Password Reset Flow
**Claude Prompt:**
```
Implement complete password reset flow:
- Password reset request (email-based)
- Secure reset token generation
- Token validation and expiration
- Password update with history check
- Account security notifications
- Rate limiting for reset requests
```

### Phase 6: Security Middleware and Headers (15-20 minutes)

#### 6.1 Security Headers Configuration
**Claude Prompt:**
```
Configure comprehensive security headers using Helmet:
- Content Security Policy (CSP)
- HTTP Strict Transport Security (HSTS)
- X-Frame-Options
- X-Content-Type-Options
- Referrer Policy
- Permissions Policy
- CORS configuration for production
```

#### 6.2 Rate Limiting Implementation
**Claude Prompt:**
```
Implement sophisticated rate limiting:
- Global rate limits (1000 requests/hour per IP)
- Endpoint-specific limits (login: 5/hour, register: 3/hour)
- User-based rate limiting
- Progressive delays for repeated violations
- Whitelist for trusted IPs
- Redis-based distributed rate limiting
```

### Phase 7: Testing and Validation (20-25 minutes)

#### 7.1 Automated API Testing with Manus MCP
**Claude Prompt:**
```
Using Manus MCP, create comprehensive API tests:
1. Test user registration flow
2. Verify login with valid credentials
3. Test authentication middleware
4. Validate token refresh mechanism
5. Test password reset flow
6. Verify rate limiting enforcement
7. Test role-based access control
```

#### 7.2 Security Testing
**Claude Prompt:**
```
Create security-focused tests:
- SQL injection prevention
- XSS attack prevention
- CSRF protection validation
- JWT token manipulation attempts
- Brute force attack simulation
- Authorization bypass attempts
```

#### 7.3 Load Testing
**Claude Prompt:**
```
Using Manus MCP, implement load testing:
- Concurrent login attempts
- Token refresh under load
- Database connection pooling
- Memory usage monitoring
- Response time analysis
```

### Phase 8: Monitoring and Logging (10-15 minutes)

#### 8.1 Audit Logging Implementation
**Claude Prompt:**
```
Create comprehensive audit logging:
- Authentication events (login, logout, failed attempts)
- Authorization events (access granted/denied)
- Administrative actions (user creation, role changes)
- Security events (suspicious activity, rate limit hits)
- Structured logging with correlation IDs
```

#### 8.2 Health Monitoring
**Claude Prompt:**
```
Implement health monitoring endpoints:
- Database connectivity check
- Redis connectivity (if used)
- Memory and CPU usage
- Active session count
- Failed authentication rate
- API response time metrics
```

## 🔒 Security Checklist

### Authentication Security
- [ ] Passwords hashed with bcrypt (12+ salt rounds)
- [ ] JWT tokens properly signed and validated
- [ ] Refresh token rotation implemented
- [ ] Account lockout after failed attempts
- [ ] Rate limiting on authentication endpoints
- [ ] Secure password reset flow

### Authorization Security
- [ ] Role-based access control implemented
- [ ] Principle of least privilege enforced
- [ ] Token expiration properly handled
- [ ] Session management secure
- [ ] Administrative functions protected

### Data Security
- [ ] Input validation on all endpoints
- [ ] SQL injection prevention
- [ ] XSS protection implemented
- [ ] CSRF protection enabled
- [ ] Sensitive data not logged
- [ ] Database connections encrypted

### Infrastructure Security
- [ ] HTTPS enforced in production
- [ ] Security headers configured
- [ ] CORS properly configured
- [ ] Environment variables secured
- [ ] Secrets management implemented
- [ ] Regular security updates

## 📊 Performance Metrics

### Expected Performance
- **Registration**: < 500ms response time
- **Login**: < 300ms response time
- **Token Refresh**: < 100ms response time
- **Protected Endpoints**: < 50ms auth overhead

### Scalability Targets
- **Concurrent Users**: 10,000+
- **Requests per Second**: 1,000+
- **Database Connections**: Pooled and optimized
- **Memory Usage**: < 512MB per instance

## 🚀 Deployment Considerations

### Environment Configuration
```bash
# Production environment variables
NODE_ENV=production
JWT_SECRET=your-super-secure-secret-key
JWT_REFRESH_SECRET=your-refresh-secret-key
DATABASE_URL=postgresql://user:pass@host:5432/db
REDIS_URL=redis://localhost:6379
CORS_ORIGIN=https://yourdomain.com
```

### Docker Configuration
**Claude Prompt:**
```
Create production-ready Docker configuration:
- Multi-stage build for optimization
- Non-root user for security
- Health checks implemented
- Environment variable handling
- Volume mounts for logs
- Security scanning integration
```

### CI/CD Pipeline
**Claude Prompt:**
```
Design CI/CD pipeline with:
- Automated security testing
- Dependency vulnerability scanning
- Code quality checks
- Integration tests
- Performance benchmarks
- Automated deployment strategies
```

## 🔧 Troubleshooting Common Issues

### Issue: JWT Token Validation Failures
```bash
# Debug token issues
node -e "console.log(require('jsonwebtoken').decode('your-token-here'))"

# Verify token signature
curl -H "Authorization: Bearer your-token" http://localhost:3000/api/verify
```

### Issue: Database Connection Problems
```bash
# Test database connectivity
npx prisma db push --preview-feature
npx prisma studio

# Check connection pool
curl http://localhost:3000/health/database
```

### Issue: Rate Limiting Not Working
```bash
# Test rate limiting
for i in {1..10}; do curl -X POST http://localhost:3000/api/login; done

# Check Redis connection (if using Redis)
redis-cli ping
```

## 📚 Advanced Topics

### Multi-Factor Authentication
- TOTP implementation with speakeasy
- SMS-based verification
- Backup codes generation
- Recovery procedures

### OAuth Integration
- Google OAuth 2.0
- GitHub OAuth
- Microsoft Azure AD
- Custom OAuth providers

### Advanced Security
- Device fingerprinting
- Geolocation-based security
- Behavioral analysis
- Threat detection

## 🎯 Next Steps

1. **Add Multi-Factor Authentication**: Implement TOTP-based 2FA
2. **OAuth Integration**: Add social login options
3. **Advanced Monitoring**: Implement security analytics
4. **Microservices**: Split into dedicated auth service
5. **Federation**: Implement SAML/OpenID Connect

---

**🔐 Security Note:** Always conduct security audits and penetration testing before deploying authentication systems to production!

