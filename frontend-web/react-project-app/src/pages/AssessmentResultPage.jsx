import { useState, useEffect } from "react";
import { useNavigate, useLocation } from "react-router-dom";
import Navbar from "../components/Navbar";
import Footer from "../components/Footer";
import { diagnosticAPI } from "../services/api";
import "../assets/styles/assessmentResult.css";
import "../assets/styles/components.css";

export default function AssessmentResultPage() {
  const navigate = useNavigate();
  const location = useLocation();
  const state = location.state || {};

  const diseaseName = state.diseaseName || "Unknown diagnosis";
  const sourceType = state.source || "ai";
  const answers = state.answers || [];
  const userConfirmedSymptoms = state.userConfirmedSymptoms ?? null;
  const originalConfidence = state.confidence || 0;
  const imageConfirmationRequired = state.imageConfirmationRequired ?? false;

  const [diseaseDetails, setDiseaseDetails] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const [uploadedImage, setUploadedImage] = useState(null);
  const [showChatTooltip, setShowChatTooltip] = useState(false);

  useEffect(() => {
    if (!state.diseaseName) {
      return;
    }

    setLoading(true);
    setError("");

    diagnosticAPI
      .getDiseaseDetails(state.diseaseName)
      .then((response) => {
        setDiseaseDetails(response.data);
      })
      .catch((err) => {
        setError(err.response?.data || "Unable to load disease details.");
      })
      .finally(() => {
        setLoading(false);
      });

    // Try to get uploaded image from sessionStorage
    const storedImage = sessionStorage.getItem('uploadedImagePreview');
    if (storedImage) {
      setUploadedImage(storedImage);
    }
  }, [diseaseName]);


  // Calculate displayed confidence
  const isHighConfidence = originalConfidence >= 0.90;
  const displayedConfidence = userConfirmedSymptoms === true ? Math.max(originalConfidence, 0.90) : originalConfidence;

  const diagnosisLabel = diseaseDetails?.diseaseName || diseaseName;
  const description = diseaseDetails?.description || "No disease information available.";
  const nextSteps = diseaseDetails?.careInstructions
    ? diseaseDetails.careInstructions
        .split(".")
        .map((item) => item.trim())
        .filter(Boolean)
    : [];
  const confidenceValue = sourceType === "expert" ? "-" : (displayedConfidence * 100).toFixed(1);
  const metricWidth = sourceType === "expert" ? "0%" : `${displayedConfidence * 100}%`;
  const badgeText = sourceType === "expert" ? "Expert System" : "Verified AI";

  return (
    <div className="result-page">
      <Navbar />

      <main className="result-body">
        <div className="result-header-row">
          <div>
            <div className="result-eyebrow">Clinical Analysis Report</div>
            <h1 className="result-title">Assessment Complete</h1>
          </div>

          <div className="result-header-actions">
            <button
              className="result-btn result-btn-ghost"
              type="button"
              onClick={() => window.print()}
              id="result-download-pdf"
            >
              Download PDF
            </button>
            <button
              className="result-btn result-btn-secondary"
              type="button"
              onClick={() => navigate('/confirmation', { state: { diseaseName, confidence: originalConfidence, diagnosticResultId: state.diagnosticResultId, top3: state.top3 || [] } })}
              id="result-confirmation-questions-btn"
            >
              Confirmation Questions
            </button>
          </div>

          {/* Floating Chat Button */}
          <div 
            className="floating-chat-button"
            onMouseEnter={() => setShowChatTooltip(true)}
            onMouseLeave={() => setShowChatTooltip(false)}
          >
            <button
              className="chat-fab"
              type="button"
              onClick={() => navigate("/assistant")}
              id="floating-chat-btn"
              title="Ask about the result"
            >
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z" />
              </svg>
            </button>
            {showChatTooltip && <span className="floating-chat-tooltip">Ask about the result</span>}
          </div>
        </div>

        {loading && <div className="info-banner">Loading disease details…</div>}
        {error && <div className="error-banner">{error}</div>}

        {/* Confirmation Status Banner - Only show when user explicitly answered NO */}
        {userConfirmedSymptoms === false && (
          <div className="confirmation-status-banner not-confirmed">
            <div className="confirmation-status-content">
              <span className="confirmation-status-icon">⚠</span>
              <span className="confirmation-status-text">
                User answers do not match the AI prediction. The assessment could not be confidently confirmed and further clinical evaluation may be required.
              </span>
            </div>
          </div>
        )}

        <section className="result-grid">
          {/* Left — Diagnosis */}
          <div className="result-card">
            <div className="result-card-top">
              <div>
                <div className="result-card-kicker">Primary Diagnosis</div>
                <div className="result-diagnosis-row">
                  <div className="result-diagnosis">{diagnosisLabel}</div>
                  <span className="badge badge-success">{badgeText}</span>
                  {userConfirmedSymptoms === true && (
                    <span className="badge badge-confirmed">CONFIRMED BY USER</span>
                  )}
                </div>
              </div>
            </div>

            <div className="result-metric">
              <div className="result-metric-label">
                AI Confidence Score
                {userConfirmedSymptoms === true && originalConfidence < 0.90 && (
                  <span className="confidence-note">(Increased with confirmed symptoms)</span>
                )}
              </div>
              <div className="result-metric-row">
                <div className="result-metric-bar">
                  <div className="result-metric-fill" style={{ width: metricWidth }} />
                </div>
                <div className="result-metric-value">
                  {confidenceValue}
                  {userConfirmedSymptoms === true && originalConfidence < 0.90 && (
                    <span className="original-confidence">(was {(originalConfidence * 100).toFixed(1)}%)</span>
                  )}
                </div>
              </div>
            </div>

            <div className="result-image-card" aria-label="Uploaded skin area analysis">
              {uploadedImage ? (
                <img
                  src={uploadedImage}
                  alt="Uploaded skin image for analysis"
                  className="result-uploaded-image"
                />
              ) : sourceType === "expert" ? (
                <div className="result-no-photo" style={{ padding: "2rem 1rem", textAlign: "center", color: "#fff", fontWeight: 700 }}>
                  No photo
                </div>
              ) : (
                <>
                  <svg
                    className="result-image-lines"
                    viewBox="0 0 240 140"
                    xmlns="http://www.w3.org/2000/svg"
                    aria-hidden="true"
                  >
                    <defs>
                      <linearGradient id="skinGrad" x1="0" y1="0" x2="1" y2="1">
                        <stop offset="0" stopColor="rgba(255,255,255,0.15)" />
                        <stop offset="1" stopColor="rgba(255,255,255,0)" />
                      </linearGradient>
                    </defs>
                    <rect x="0" y="0" width="240" height="140" fill="url(#skinGrad)" />
                    <path
                      d="M-10 105 C 40 75, 80 110, 130 85 C 170 65, 210 95, 260 60"
                      stroke="rgba(255,255,255,0.45)"
                      strokeWidth="2.4"
                      fill="none"
                    />
                    <path
                      d="M-10 120 C 50 95, 90 130, 145 102 C 185 82, 215 110, 260 80"
                      stroke="rgba(255,255,255,0.22)"
                      strokeWidth="2"
                      fill="none"
                    />
                  </svg>
                  <div className="result-image-caption">Microscopic texture analysis</div>
                </>
              )}
            </div>

            <div className="result-pill-grid">
              <div className="result-pill">
                <div className="result-pill-label">Severity</div>
                <div className="result-pill-value">{diseaseDetails?.severityLevel || "Unknown"}</div>
              </div>
              <div className="result-pill">
                <div className="result-pill-label">Source</div>
                <div className="result-pill-value">{sourceType === "expert" ? "Expert System" : "AI Model"}</div>
              </div>
            </div>

            {/* High Confidence Message */}
            {isHighConfidence && !imageConfirmationRequired && (
              <div className="high-confidence-notice">
                <div className="notice-icon"></div>
                <div className="notice-text">
                  <strong>High Confidence Prediction</strong>
                  <p>This prediction has sufficient confidence and does not require symptom verification.</p>
                </div>
              </div>
            )}
          </div>

          {/* Right — Details */}
          <div className="result-right">
            <div className="result-card">
              <div className="result-section-title">About {diagnosisLabel}</div>
              <p className="result-paragraph">{description}</p>
            </div>

            <div className="result-card">
              <div className="result-section-title">Care Instructions</div>

              {nextSteps.length > 0 ? (
                nextSteps.map((step, index) => (
                  <button
                    key={index}
                    className="nextstep"
                    type="button"
                    onClick={() => navigate("/assistant")}
                    id={`nextstep-${index + 1}`}
                  >
                    <span className="nextstep-num">{index + 1}</span>
                    <span className="nextstep-main">
                      <span className="nextstep-title">{step}</span>
                      <span className="nextstep-desc">Review this guidance with a clinician if needed.</span>
                    </span>
                    <span className="nextstep-arrow" aria-hidden="true">
                      ›
                    </span>
                  </button>
                ))
              ) : (
                <button className="nextstep" type="button" onClick={() => navigate("/assistant")}> 
                  <span className="nextstep-num">1</span>
                  <span className="nextstep-main">
                    <span className="nextstep-title">Continue monitoring symptoms</span>
                    <span className="nextstep-desc">Return to the assistant for further guidance.</span>
                  </span>
                  <span className="nextstep-arrow" aria-hidden="true">›</span>
                </button>
              )}
            </div>
          </div>
        </section>
        
      </main>
      <Footer />
    </div>
  ); 
}
