import { useState } from 'react';
import '../assets/styles/components.css';

/**
 * Reusable FormInput component
 */
export default function FormInput({
  id,
  label,
  type = 'text',
  placeholder,
  value,
  onChange,
  error,
  hint,
  icon,        // left icon element (SVG or emoji)
  rightLabel,  // element shown on the right of the label row
  required = false,
  autoComplete,
  ...rest
}) {
  const [showPassword, setShowPassword] = useState(false);
  const isPassword = type === 'password';
  const inputType = isPassword && showPassword ? 'text' : type;

  return (
    <div className="form-group">
      {label && (
        <div className="auth-label-row">
          <label htmlFor={id} className="form-label">
            {label}
            {required && <span style={{ color: 'var(--danger)', marginLeft: 2 }}>*</span>}
          </label>
          {rightLabel && rightLabel}
        </div>
      )}

      <div className="input-wrapper">
        {icon && <span className="input-icon">{icon}</span>}

        <input
          id={id}
          type={inputType}
          placeholder={placeholder}
          value={value}
          onChange={onChange}
          autoComplete={autoComplete}
          className={`form-input ${error ? 'error' : ''}`}
          style={!icon ? { paddingLeft: 16 } : {}}
          aria-invalid={!!error}
          aria-describedby={error ? `${id}-error` : hint ? `${id}-hint` : undefined}
          {...rest}
        />

        {isPassword && (
          <button
            type="button"
            className="input-icon-right"
            onClick={() => setShowPassword((p) => !p)}
            aria-label={showPassword ? 'Hide password' : 'Show password'}
          >
            {showPassword ? (
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                <path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24" />
                <line x1="1" y1="1" x2="23" y2="23" />
              </svg>
            ) : (
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z" />
                <circle cx="12" cy="12" r="3" />
              </svg>
            )}
          </button>
        )}
      </div>

      {error && <span id={`${id}-error`} className="form-error">{error}</span>}
      {hint && !error && <span id={`${id}-hint`} className="form-hint">{hint}</span>}
    </div>
  );
}
