import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import FormInput from '../components/FormInput';
import '../assets/styles/auth.css';
import '../assets/styles/components.css';

const UserIcon = () => (
  <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
    <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2" />
    <circle cx="12" cy="7" r="4" />
  </svg>
);

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

function validate(userName, email, password, age, gender) {
  const errors = {};
  if (!userName.trim()) errors.userName = 'Username is required.';
  if (!email) errors.email = 'Email address is required.';
  else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) errors.email = 'Enter a valid email address.';
  if (!password) errors.password = 'Password is required.';
  else if (password.length < 6) errors.password = 'Password must be at least 6 characters.';
  if (!age || age < 1) errors.age = 'Valid age is required.';
  if (!gender) errors.gender = 'Gender is required.';
  return errors;
}

export default function RegisterPage() {
  const navigate = useNavigate();
  const { register, loading } = useAuth();
  const [form, setForm] = useState({ userName: '', email: '', password: '', age: '', gender: '' });
  const [errors, setErrors] = useState({});
  const [apiError, setApiError] = useState('');

  const handleChange = (field) => (e) => {
    setForm((prev) => ({ ...prev, [field]: e.target.value }));
    if (errors[field]) setErrors((prev) => ({ ...prev, [field]: '' }));
    if (apiError) setApiError('');
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    const errs = validate(form.userName, form.email, form.password, form.age, form.gender);
    if (Object.keys(errs).length) { setErrors(errs); return; }

    const result = await register({
      UserName: form.userName,
      Email: form.email,
      Password: form.password,
      Age: parseInt(form.age),
      Gender: form.gender,
    });
    if (result.success) {
      navigate('/login'); // Redirect to login after registration
    } else {
      setApiError(result.error || result.message || 'Registration failed');
      if (result.fieldErrors) {
        setErrors((prev) => ({ ...prev, ...result.fieldErrors }));
      }
    }
  };

  return (
    <div className="auth-page">
      {/* Body — no top navbar per design */}
      <div className="auth-body">
        {/* Logo */}
        <div className="auth-logo-section">
          <h1 className="auth-logo-title">Al-Derma</h1>
          <p className="auth-logo-subtitle" style={{ letterSpacing: '0.14em', textTransform: 'uppercase', fontSize: '0.78rem' }}>
            Dermatology Excellence
          </p>
        </div>

        {/* Card */}
        <div className="auth-card">
          <h2 className="auth-card-title">Create Account</h2>
          <p className="auth-card-subtitle">
            Join the clinical network for advanced skin care management.
          </p>

          <form className="auth-form" onSubmit={handleSubmit} noValidate id="register-form">
            {apiError && <div className="error-message" style={{ color: 'red', marginBottom: '10px' }}>{apiError}</div>}
            <FormInput
              id="register-username"
              label="USERNAME"
              type="text"
              placeholder="johndoe"
              value={form.userName}
              onChange={handleChange('userName')}
              error={errors.userName}
              icon={<UserIcon />}
              autoComplete="username"
              required
            />

            <FormInput
              id="register-email"
              label="EMAIL ADDRESS"
              type="email"
              placeholder="jane.smith@clinicalcloud.com"
              value={form.email}
              onChange={handleChange('email')}
              error={errors.email}
              icon={<MailIcon />}
              autoComplete="email"
              required
            />

            <FormInput
              id="register-password"
              label="PASSWORD"
              type="password"
              placeholder="••••••••"
              value={form.password}
              onChange={handleChange('password')}
              error={errors.password}
              hint={!errors.password ? 'Must be at least 6 characters.' : undefined}
              icon={<LockIcon />}
              autoComplete="new-password"
              required
            />

            <FormInput
              id="register-age"
              label="AGE"
              type="number"
              placeholder="25"
              value={form.age}
              onChange={handleChange('age')}
              error={errors.age}
              required
            />

            <div style={{ marginBottom: '20px' }}>
              <label style={{ display: 'block', marginBottom: '5px', fontSize: '0.875rem', fontWeight: 600, color: 'var(--text-primary)' }}>GENDER</label>
              <select
                value={form.gender}
                onChange={handleChange('gender')}
                style={{
                  width: '100%',
                  padding: '10px',
                  border: '1px solid var(--border-light)',
                  borderRadius: '4px',
                  backgroundColor: 'var(--bg-primary)',
                  color: 'var(--text-primary)',
                }}
                required
              >
                <option value="">Select Gender</option>
                <option value="Male">Male</option>
                <option value="Female">Female</option>
                <option value="Other">Other</option>
              </select>
              {errors.gender && <div style={{ color: 'red', fontSize: '0.875rem', marginTop: '5px' }}>{errors.gender}</div>}
            </div>

            <button
              type="submit"
              id="register-submit-btn"
              className="btn-login"
              disabled={loading}
            >
              {loading ? 'Creating account...' : 'Create Account'}
            </button>
          </form>

          <p className="auth-switch" style={{ marginTop: 20 }}>
            Already have an account?{' '}
            <Link to="/login" className="auth-link">Login</Link>
          </p>
        </div>
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