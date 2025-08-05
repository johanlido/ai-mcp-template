# 🤖 AI Agent Instructions & Guardrails

This document provides comprehensive guidelines for AI agents (GitHub Copilot, Claude, etc.) working within this professional development environment. These instructions ensure code quality, security, and compliance with industry standards.

## 🎯 Core Principles

### Code Quality Standards
- **Always prioritize readability** over cleverness
- **Use descriptive variable and function names** that clearly indicate purpose
- **Include comprehensive error handling** for all external dependencies
- **Write self-documenting code** with clear comments for complex logic
- **Follow established patterns** within the existing codebase
- **Implement proper logging** for debugging and monitoring

### Security First Approach
- **Never hardcode sensitive information** (API keys, passwords, tokens)
- **Always validate and sanitize user inputs** before processing
- **Implement proper authentication and authorization** for all endpoints
- **Use parameterized queries** to prevent SQL injection
- **Apply principle of least privilege** for all access controls
- **Include security headers** in all HTTP responses

### Performance Considerations
- **Optimize for scalability** from the beginning
- **Implement proper caching strategies** where appropriate
- **Use efficient algorithms** and data structures
- **Minimize database queries** through proper optimization
- **Consider memory usage** in all implementations
- **Profile and benchmark** critical code paths

## 🔐 Backend Development Guidelines

### Authentication & Authorization

**Required Security Measures:**
```javascript
// ✅ CORRECT: Secure JWT implementation
const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');
const rateLimit = require('express-rate-limit');

// Always use environment variables for secrets
const JWT_SECRET = process.env.JWT_SECRET;
const JWT_EXPIRY = process.env.JWT_EXPIRY || '1h';
const SALT_ROUNDS = parseInt(process.env.SALT_ROUNDS) || 12;

// Implement rate limiting for auth endpoints
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // limit each IP to 5 requests per windowMs
  message: 'Too many authentication attempts, please try again later.',
  standardHeaders: true,
  legacyHeaders: false,
});

// Secure password hashing
async function hashPassword(password) {
  if (!password || password.length < 8) {
    throw new Error('Password must be at least 8 characters long');
  }
  return await bcrypt.hash(password, SALT_ROUNDS);
}

// Secure token generation with proper payload
function generateToken(user) {
  const payload = {
    userId: user.id,
    email: user.email,
    role: user.role,
    iat: Math.floor(Date.now() / 1000)
  };
  
  return jwt.sign(payload, JWT_SECRET, { 
    expiresIn: JWT_EXPIRY,
    issuer: 'your-app-name',
    audience: 'your-app-users'
  });
}

// Comprehensive token validation middleware
function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ 
      error: 'Access token required',
      code: 'TOKEN_MISSING'
    });
  }

  jwt.verify(token, JWT_SECRET, (err, decoded) => {
    if (err) {
      const errorResponse = {
        error: 'Invalid or expired token',
        code: err.name === 'TokenExpiredError' ? 'TOKEN_EXPIRED' : 'TOKEN_INVALID'
      };
      return res.status(403).json(errorResponse);
    }
    
    req.user = decoded;
    next();
  });
}
```

**❌ AVOID These Patterns:**
```javascript
// ❌ NEVER: Hardcoded secrets
const JWT_SECRET = 'my-secret-key';

// ❌ NEVER: Weak password validation
if (password.length > 0) { /* insufficient */ }

// ❌ NEVER: Plain text password storage
user.password = password; // Always hash passwords

// ❌ NEVER: Missing rate limiting on auth endpoints
app.post('/login', loginHandler); // Vulnerable to brute force

// ❌ NEVER: Exposing sensitive data in tokens
const payload = { password: user.password, ssn: user.ssn };
```

### Database Security

**Required Practices:**
```javascript
// ✅ CORRECT: Parameterized queries
async function getUserById(userId) {
  const query = 'SELECT id, email, role, created_at FROM users WHERE id = $1';
  const result = await db.query(query, [userId]);
  return result.rows[0];
}

// ✅ CORRECT: Input validation and sanitization
const { body, validationResult } = require('express-validator');

const validateUserInput = [
  body('email').isEmail().normalizeEmail(),
  body('password').isLength({ min: 8 }).matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])/),
  body('name').trim().escape().isLength({ min: 2, max: 50 }),
  
  (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ 
        error: 'Validation failed',
        details: errors.array()
      });
    }
    next();
  }
];
```

### API Design Standards

**Required Response Format:**
```javascript
// ✅ CORRECT: Consistent API response structure
const ApiResponse = {
  success: (data, message = 'Success') => ({
    success: true,
    message,
    data,
    timestamp: new Date().toISOString()
  }),
  
  error: (message, code = 'INTERNAL_ERROR', details = null) => ({
    success: false,
    error: {
      message,
      code,
      details,
      timestamp: new Date().toISOString()
    }
  })
};

// ✅ CORRECT: Comprehensive error handling
app.use((err, req, res, next) => {
  // Log error for monitoring
  console.error(`Error ${err.status || 500}: ${err.message}`, {
    url: req.url,
    method: req.method,
    ip: req.ip,
    userAgent: req.get('User-Agent'),
    stack: err.stack
  });

  // Don't expose internal errors in production
  const isDevelopment = process.env.NODE_ENV === 'development';
  const message = isDevelopment ? err.message : 'Internal server error';
  
  res.status(err.status || 500).json(
    ApiResponse.error(message, err.code, isDevelopment ? err.stack : null)
  );
});
```

## 🎨 Frontend Development Guidelines

### WCAG 2.1 AA Compliance

**Required Accessibility Features:**
```jsx
// ✅ CORRECT: Accessible form components
import React, { useState, useId } from 'react';

const AccessibleForm = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [errors, setErrors] = useState({});
  
  const emailId = useId();
  const passwordId = useId();
  const errorId = useId();

  return (
    <form 
      onSubmit={handleSubmit}
      aria-labelledby="login-heading"
      aria-describedby={Object.keys(errors).length > 0 ? errorId : undefined}
    >
      <h1 id="login-heading">Sign In to Your Account</h1>
      
      {/* Error summary for screen readers */}
      {Object.keys(errors).length > 0 && (
        <div 
          id={errorId}
          role="alert"
          aria-live="polite"
          className="error-summary"
        >
          <h2>Please correct the following errors:</h2>
          <ul>
            {Object.entries(errors).map(([field, message]) => (
              <li key={field}>
                <a href={`#${field}-input`}>{message}</a>
              </li>
            ))}
          </ul>
        </div>
      )}

      <div className="form-group">
        <label htmlFor={emailId} className="required">
          Email Address
          <span aria-label="required" className="required-indicator">*</span>
        </label>
        <input
          id={emailId}
          name="email"
          type="email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          aria-required="true"
          aria-invalid={errors.email ? 'true' : 'false'}
          aria-describedby={errors.email ? `${emailId}-error` : undefined}
          autoComplete="email"
        />
        {errors.email && (
          <div id={`${emailId}-error`} className="error-message" role="alert">
            {errors.email}
          </div>
        )}
      </div>

      <div className="form-group">
        <label htmlFor={passwordId} className="required">
          Password
          <span aria-label="required" className="required-indicator">*</span>
        </label>
        <input
          id={passwordId}
          name="password"
          type="password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          aria-required="true"
          aria-invalid={errors.password ? 'true' : 'false'}
          aria-describedby={errors.password ? `${passwordId}-error` : `${passwordId}-help`}
          autoComplete="current-password"
        />
        <div id={`${passwordId}-help`} className="help-text">
          Password must be at least 8 characters long
        </div>
        {errors.password && (
          <div id={`${passwordId}-error`} className="error-message" role="alert">
            {errors.password}
          </div>
        )}
      </div>

      <button 
        type="submit" 
        className="btn-primary"
        disabled={isSubmitting}
        aria-describedby="submit-help"
      >
        {isSubmitting ? (
          <>
            <span aria-hidden="true">⏳</span>
            <span className="sr-only">Signing in...</span>
            Signing In...
          </>
        ) : (
          'Sign In'
        )}
      </button>
      
      <div id="submit-help" className="help-text">
        By signing in, you agree to our Terms of Service and Privacy Policy
      </div>
    </form>
  );
};
```

**Required CSS for Accessibility:**
```css
/* ✅ CORRECT: Accessible focus indicators */
.btn-primary:focus,
input:focus,
select:focus,
textarea:focus {
  outline: 3px solid #005fcc;
  outline-offset: 2px;
}

/* ✅ CORRECT: High contrast colors (WCAG AA compliant) */
:root {
  --text-primary: #212529;      /* 16.94:1 contrast ratio */
  --text-secondary: #6c757d;    /* 4.54:1 contrast ratio */
  --background: #ffffff;
  --error: #dc3545;             /* 5.93:1 contrast ratio */
  --success: #198754;           /* 4.56:1 contrast ratio */
}

/* ✅ CORRECT: Screen reader only content */
.sr-only {
  position: absolute;
  width: 1px;
  height: 1px;
  padding: 0;
  margin: -1px;
  overflow: hidden;
  clip: rect(0, 0, 0, 0);
  white-space: nowrap;
  border: 0;
}

/* ✅ CORRECT: Reduced motion support */
@media (prefers-reduced-motion: reduce) {
  *,
  *::before,
  *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}

/* ✅ CORRECT: Minimum touch target size (44px) */
.btn,
.form-control,
.nav-link {
  min-height: 44px;
  min-width: 44px;
}
```

### Component Architecture

**Required Patterns:**
```jsx
// ✅ CORRECT: Accessible modal component
import React, { useEffect, useRef } from 'react';
import { createPortal } from 'react-dom';

const Modal = ({ 
  isOpen, 
  onClose, 
  title, 
  children, 
  closeOnEscape = true,
  closeOnOverlay = true 
}) => {
  const modalRef = useRef(null);
  const previousFocusRef = useRef(null);

  useEffect(() => {
    if (isOpen) {
      // Store the currently focused element
      previousFocusRef.current = document.activeElement;
      
      // Focus the modal
      modalRef.current?.focus();
      
      // Prevent body scroll
      document.body.style.overflow = 'hidden';
      
      // Handle escape key
      const handleEscape = (e) => {
        if (closeOnEscape && e.key === 'Escape') {
          onClose();
        }
      };
      
      document.addEventListener('keydown', handleEscape);
      
      return () => {
        document.removeEventListener('keydown', handleEscape);
        document.body.style.overflow = 'unset';
        
        // Restore focus to previous element
        previousFocusRef.current?.focus();
      };
    }
  }, [isOpen, onClose, closeOnEscape]);

  if (!isOpen) return null;

  return createPortal(
    <div 
      className="modal-overlay"
      onClick={closeOnOverlay ? onClose : undefined}
      role="dialog"
      aria-modal="true"
      aria-labelledby="modal-title"
    >
      <div 
        ref={modalRef}
        className="modal-content"
        onClick={(e) => e.stopPropagation()}
        tabIndex={-1}
      >
        <div className="modal-header">
          <h2 id="modal-title">{title}</h2>
          <button
            type="button"
            className="modal-close"
            onClick={onClose}
            aria-label="Close modal"
          >
            <span aria-hidden="true">&times;</span>
          </button>
        </div>
        <div className="modal-body">
          {children}
        </div>
      </div>
    </div>,
    document.body
  );
};
```

## 🚫 Prohibited Patterns

### Security Anti-Patterns
```javascript
// ❌ NEVER: Client-side authentication logic
if (localStorage.getItem('isAdmin') === 'true') {
  // This can be manipulated by users
}

// ❌ NEVER: Exposing sensitive data in client code
const API_SECRET = 'secret-key'; // Visible to all users

// ❌ NEVER: SQL injection vulnerabilities
const query = `SELECT * FROM users WHERE id = ${userId}`; // Dangerous

// ❌ NEVER: Missing CORS configuration
app.use(cors()); // Too permissive

// ❌ NEVER: Weak session management
req.session.user = userData; // Without proper security
```

### Accessibility Anti-Patterns
```jsx
{/* ❌ NEVER: Missing alt text for images */}
<img src="chart.png" />

{/* ❌ NEVER: Non-semantic HTML for interactive elements */}
<div onClick={handleClick}>Click me</div>

{/* ❌ NEVER: Missing form labels */}
<input type="email" placeholder="Email" />

{/* ❌ NEVER: Poor color contrast */}
<p style={{color: '#999', background: '#fff'}}>Low contrast text</p>

{/* ❌ NEVER: Missing focus management */}
<div tabIndex="0">Focusable but no focus indicator</div>
```

## 📋 Code Review Checklist

### Before Submitting Code
- [ ] **Security**: No hardcoded secrets, proper input validation
- [ ] **Accessibility**: WCAG 2.1 AA compliance verified
- [ ] **Performance**: Optimized queries and efficient algorithms
- [ ] **Error Handling**: Comprehensive error handling implemented
- [ ] **Testing**: Unit tests cover critical functionality
- [ ] **Documentation**: Code is self-documenting with necessary comments
- [ ] **Standards**: Follows established patterns and conventions

### AI-Specific Considerations
- [ ] **Prompt Context**: AI was given sufficient context about requirements
- [ ] **Code Review**: Human review completed for AI-generated code
- [ ] **Security Audit**: Extra scrutiny applied to security-related code
- [ ] **Accessibility Testing**: Screen reader and keyboard navigation tested
- [ ] **Integration**: Code integrates properly with existing systems

## 🎯 Success Metrics

### Code Quality Indicators
- **Zero security vulnerabilities** in static analysis
- **100% accessibility compliance** with automated testing
- **90%+ code coverage** for critical business logic
- **Sub-200ms response times** for API endpoints
- **Zero console errors** in production builds

### AI Collaboration Effectiveness
- **Reduced development time** while maintaining quality
- **Consistent code patterns** across team members
- **Improved security posture** through systematic checks
- **Enhanced accessibility** through automated compliance
- **Better documentation** through AI-assisted generation

---

**Remember**: These guidelines ensure that AI-generated code meets professional standards and contributes to a secure, accessible, and maintainable codebase. Always prioritize user safety, security, and accessibility in every implementation.

