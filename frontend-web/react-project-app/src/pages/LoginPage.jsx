import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import FormInput from '../components/FormInput';
import '../assets/styles/auth.css';
import '../assets/styles/components.css';

// Icons (inline SVGs for zero dependency)
const MailIcon = () => (
  <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
    <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z" />
    <polyline points="22,6 12,13 2,6" />
  </svg>
);

const LockIcon = () => (
  <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
    <rect x="3" y="11" width="18" height="11" rx="2" ry="2" />
    <path d="M7 11V7a5 5 0 0 1 10 0v4" />
  </svg>
);

function validate(email, password) {
  const errors = {};
  if (!email) errors.email = 'Email address is required.';
  else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) errors.email = 'Enter a valid email address.';
  if (!password) errors.password = 'Password is required.';
  else if (password.length < 6) errors.password = 'Password must be at least 6 characters.';
  return errors;
}

export default function LoginPage() {
  const navigate = useNavigate();
  const { login, loading } = useAuth();
  const [form, setForm] = useState({ email: '', password: '' });
  const [errors, setErrors] = useState({});
  const [apiError, setApiError] = useState('');

  const handleChange = (field) => (e) => {
    setForm((prev) => ({ ...prev, [field]: e.target.value }));
    if (errors[field]) setErrors((prev) => ({ ...prev, [field]: '' }));
    if (apiError) setApiError('');
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    const errs = validate(form.email, form.password);
    if (Object.keys(errs).length) { setErrors(errs); return; }

    const result = await login(form.email, form.password);
    if (result.success) {
      navigate('/');
    } else {
      setApiError(result.error);
    }
  };

  return (
    <div className="auth-page">
      {/* Minimal Navbar */}
      <nav style={{ borderBottom: '1px solid var(--border-light)', padding: '0 32px', height: 58, display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <span style={{ fontWeight: 800, fontSize: '1.1rem', color: 'var(--primary)', letterSpacing: '-0.03em' }}>ClinicalCloud</span>
        <div className="auth-nav-right">
          <span className="auth-nav-link">Support</span>
          <span className="auth-nav-help">?</span>
        </div>
      </nav>

      {/* Body */}
      <div className="auth-body">
        {/* Logo */}
        <div className="auth-logo-section">
          <h1 className="auth-logo-title">Al-Derma</h1>
          <p className="auth-logo-subtitle">Professional Dermatology Portal</p>
        </div>

        {/* Card */}
        <div className="auth-card">
          <form className="auth-form" onSubmit={handleSubmit} noValidate id="login-form">
            {apiError && <div className="error-message" style={{ color: 'red', marginBottom: '10px' }}>{apiError}</div>}
            <FormInput
              id="login-email"
              label="EMAIL ADDRESS"
              type="email"
              placeholder="name@clinicalcloud.com"
              value={form.email}
              onChange={handleChange('email')}
              error={errors.email}
              icon={<MailIcon />}
              autoComplete="email"
              required
            />

            <FormInput
              id="login-password"
              label="PASSWORD"
              type="password"
              placeholder="••••••••"
              value={form.password}
              onChange={handleChange('password')}
              error={errors.password}
              icon={<LockIcon />}
              autoComplete="current-password"
              required
              rightLabel={
                <span className="auth-forgot">Forgot password?</span>
              }
            />

            <button
              type="submit"
              id="login-submit-btn"
              className="btn-login"
              disabled={loading}
            >
              {loading ? 'Signing in...' : 'SIGN IN'}
            </button>
          </form>

          <p className="auth-switch" style={{ marginTop: 20 }}>
            New to Al-Derma?{' '}
            <Link to="/register" className="auth-link">Register for an account</Link>
          </p>
        </div>

        <div className="auth-secured">Secured Clinical Access</div>
      </div>

      {/* Footer */}
      <div className="auth-footer">
        <span className="auth-footer-copy">© 2024 ClinicalCloud Systems. HIPAA Compliant.</span>
        <div className="auth-footer-links">
          <a href="#privacy">Privacy Policy</a>
          <a href="#terms">Terms of Service</a>
          <a href="#security">Security</a>
        </div>
      </div>
    </div>
  );
}