import { useState, useRef } from 'react';
import { useNavigate } from 'react-router-dom';
import Navbar from '../components/Navbar';
import Footer from '../components/Footer';
import '../assets/styles/upload.css';
import '../assets/styles/components.css';

export default function UploadPage() {
  const navigate = useNavigate();
  const fileInputRef = useRef(null);
  const [previewUrl, setPreviewUrl] = useState(null);
  const [isDragOver, setIsDragOver] = useState(false);
  const [analyzing, setAnalyzing] = useState(false);

  const handleFileSelect = (file) => {
    if (!file || !file.type.startsWith('image/')) return;
    const reader = new FileReader();
    reader.onload = (e) => setPreviewUrl(e.target.result);
    reader.readAsDataURL(file);
  };

  const handleInputChange = (e) => {
    handleFileSelect(e.target.files[0]);
  };

  const handleDrop = (e) => {
    e.preventDefault();
    setIsDragOver(false);
    handleFileSelect(e.dataTransfer.files[0]);
  };

  const handleDragOver = (e) => {
    e.preventDefault();
    setIsDragOver(true);
  };

  const handleDragLeave = () => setIsDragOver(false);

  const handleAnalyze = async () => {
    if (!previewUrl) return;
    setAnalyzing(true);
    await new Promise((r) => setTimeout(r, 2000));
    setAnalyzing(false);
    navigate('/result');
  };

  return (
    <div className="upload-page">
      <Navbar />

      <div className="upload-body">
        {/* Header */}
        <div className="upload-header">
          <div className="upload-eyebrow">Dermatological Assessment</div>
          <h1 className="upload-title">Capture Your Concern</h1>
          <p className="upload-subtitle">
            Upload a clear image of the skin area you'd like to analyze. Our clinical AI will
            process the textures and patterns to provide preliminary insights.
          </p>
        </div>

        {/* Upload Method Cards */}
        <div className="upload-methods">
          {/* Capture Photo */}
          <div
            className="upload-method-card"
            id="capture-photo-card"
            onClick={() => fileInputRef.current?.click()}
            role="button"
            tabIndex={0}
            onKeyDown={(e) => e.key === 'Enter' && fileInputRef.current?.click()}
          >
            <div className="upload-method-icon-wrap">
              <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8">
                <path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z" />
                <circle cx="12" cy="13" r="4" />
              </svg>
            </div>
            <h3 className="upload-method-title">Capture Photo</h3>
            <p className="upload-method-desc">Use your device's camera for a live shot</p>
          </div>

          {/* From Gallery */}
          <div
            className="upload-method-card"
            id="gallery-card"
            onClick={() => fileInputRef.current?.click()}
            role="button"
            tabIndex={0}
            onKeyDown={(e) => e.key === 'Enter' && fileInputRef.current?.click()}
            onDrop={handleDrop}
            onDragOver={handleDragOver}
            onDragLeave={handleDragLeave}
            style={{ borderColor: isDragOver ? 'var(--primary)' : undefined }}
          >
            <div className="upload-method-icon-wrap">
              <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8">
                <rect x="3" y="3" width="18" height="18" rx="2" ry="2" />
                <circle cx="8.5" cy="8.5" r="1.5" />
                <polyline points="21 15 16 10 5 21" />
              </svg>
            </div>
            <h3 className="upload-method-title">From Gallery</h3>
            <p className="upload-method-desc">Select an existing photo from your storage</p>
          </div>

          {/* Hidden file input */}
          <input
            ref={fileInputRef}
            type="file"
            accept="image/*"
            onChange={handleInputChange}
            style={{ display: 'none' }}
            id="image-file-input"
          />
        </div>

        {/* Lower Section */}
        <div className="upload-lower">
          {/* Image Preview */}
          <div className="preview-card">
            <div className="preview-card-header">
              <span className="preview-card-title">Image Preview</span>
              <span className="preview-no-image">
                {previewUrl ? 'IMAGE SELECTED' : 'NO IMAGE SELECTED'}
              </span>
            </div>

            <div
              className="preview-area"
              onDrop={handleDrop}
              onDragOver={handleDragOver}
              onDragLeave={handleDragLeave}
              style={{ borderColor: isDragOver ? 'var(--primary)' : undefined }}
            >
              {previewUrl ? (
                <img
                  src={previewUrl}
                  alt="Uploaded skin area for analysis"
                  className="preview-img"
                />
              ) : (
                <>
                  <svg className="preview-chart-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.2">
                    <line x1="18" y1="20" x2="18" y2="10" />
                    <line x1="12" y1="20" x2="12" y2="4" />
                    <line x1="6" y1="20" x2="6" y2="14" />
                    <line x1="2" y1="20" x2="22" y2="20" />
                  </svg>
                  <span className="preview-waiting">Waiting for upload...</span>
                </>
              )}
            </div>

            {previewUrl && (
              <div style={{ padding: '12px 20px', borderTop: '1px solid var(--border-light)' }}>
                <button
                  style={{
                    fontSize: '0.8rem',
                    color: 'var(--danger)',
                    background: 'transparent',
                    border: '1px solid var(--danger)',
                    borderRadius: 'var(--radius-sm)',
                    padding: '5px 12px',
                    cursor: 'pointer',
                    transition: 'all 0.2s',
                  }}
                  onMouseEnter={(e) => { e.target.style.background = 'var(--danger)'; e.target.style.color = 'white'; }}
                  onMouseLeave={(e) => { e.target.style.background = 'transparent'; e.target.style.color = 'var(--danger)'; }}
                  onClick={() => setPreviewUrl(null)}
                  id="remove-image-btn"
                >
                  Remove image
                </button>
              </div>
            )}
          </div>

          {/* Guide Card */}
          <div className="guide-card">
            <div>
              <div className="guide-header">
                <span className="guide-icon">
                  <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                    <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14" />
                    <polyline points="22 4 12 14.01 9 11.01" />
                  </svg>
                </span>
                <span className="guide-title">Best Results Guide</span>
              </div>
            </div>

            <div className="guide-items">
              {[
                {
                  icon: (
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                      <circle cx="12" cy="12" r="5" />
                      <line x1="12" y1="1" x2="12" y2="3" /><line x1="12" y1="21" x2="12" y2="23" />
                      <line x1="4.22" y1="4.22" x2="5.64" y2="5.64" /><line x1="18.36" y1="18.36" x2="19.78" y2="19.78" />
                      <line x1="1" y1="12" x2="3" y2="12" /><line x1="21" y1="12" x2="23" y2="12" />
                    </svg>
                  ),
                  title: 'Good lighting',
                  desc: 'Use natural light or a bright indoor lamp. Avoid strong shadows.',
                },
                {
                  icon: (
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                      <circle cx="11" cy="11" r="8" /><line x1="21" y1="21" x2="16.65" y2="16.65" />
                      <line x1="11" y1="8" x2="11" y2="14" /><line x1="8" y1="11" x2="14" y2="11" />
                    </svg>
                  ),
                  title: 'Close-up view',
                  desc: 'Keep the camera 2–4 inches away from the area of concern.',
                },
                {
                  icon: (
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                      <circle cx="12" cy="12" r="10" />
                      <circle cx="12" cy="12" r="3" />
                    </svg>
                  ),
                  title: 'Clear focus',
                  desc: 'Ensure the skin texture is sharp and not blurry before capturing.',
                },
              ].map((item, i) => (
                <div className="guide-item" key={i}>
                  <div className="guide-item-icon">{item.icon}</div>
                  <div>
                    <div className="guide-item-title">{item.title}</div>
                    <div className="guide-item-desc">{item.desc}</div>
                  </div>
                </div>
              ))}
            </div>

            <div>
              <button
                className="btn-analyze"
                id="analyze-btn"
                onClick={handleAnalyze}
                disabled={!previewUrl || analyzing}
                style={{ opacity: !previewUrl ? 0.6 : 1, cursor: !previewUrl ? 'not-allowed' : 'pointer' }}
              >
                {analyzing ? (
                  <>
                    <span style={{ display: 'inline-block', width: 18, height: 18, border: '2px solid rgba(255,255,255,0.4)', borderTopColor: 'white', borderRadius: '50%', animation: 'spin 0.7s linear infinite' }} />
                    Analyzing...
                  </>
                ) : (
                  <>
                    Analyze with AI
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                      <path d="M12 2L2 7l10 5 10-5-10-5z" />
                      <path d="M2 17l10 5 10-5" />
                      <path d="M2 12l10 5 10-5" />
                    </svg>
                  </>
                )}
              </button>
              <div className="analyze-privacy" style={{ marginTop: 10 }}>Clinical Data Privacy Enabled</div>
            </div>
          </div>
        </div>
      </div>

      <Footer />

      {/* Keyframe animation */}
      <style>{`
        @keyframes spin { to { transform: rotate(360deg); } }
      `}</style>
    </div>
  );
}
