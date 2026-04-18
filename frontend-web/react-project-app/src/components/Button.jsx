import '../assets/styles/buttons.css';

/**
 * Reusable Button component
 * @param {string} variant - 'primary' | 'outline' | 'outline-dark' | 'teal'
 * @param {string} size - 'sm' | 'md' | 'lg'
 * @param {boolean} fullWidth
 * @param {boolean} loading
 * @param {React.ReactNode} icon - optional icon node
 * @param {string} iconPosition - 'left' | 'right'
 */
export default function Button({
  children,
  variant = 'primary',
  size = 'md',
  fullWidth = false,
  loading = false,
  icon = null,
  iconPosition = 'left',
  className = '',
  onClick,
  type = 'button',
  disabled = false,
  ...rest
}) {
  const classes = [
    'btn',
    `btn-${variant}`,
    size === 'sm' ? 'btn-sm' : size === 'lg' ? 'btn-lg' : '',
    fullWidth ? 'btn-full' : '',
    loading ? 'btn-loading' : '',
    className,
  ]
    .filter(Boolean)
    .join(' ');

  return (
    <button
      className={classes}
      type={type}
      onClick={onClick}
      disabled={disabled || loading}
      {...rest}
    >
      {loading ? (
        <>
          <span className="btn-spinner" style={{ display: 'inline-block', width: 14, height: 14, border: '2px solid rgba(255,255,255,0.4)', borderTopColor: 'white', borderRadius: '50%', animation: 'spin 0.7s linear infinite' }} />
          Processing...
        </>
      ) : (
        <>
          {icon && iconPosition === 'left' && <span className="btn-icon">{icon}</span>}
          {children}
          {icon && iconPosition === 'right' && <span className="btn-icon">{icon}</span>}
        </>
      )}
    </button>
  );
}
