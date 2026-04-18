import { useNavigate } from "react-router-dom";
import Navbar from "../components/Navbar";
import Footer from "../components/Footer";
import "../assets/styles/assessmentResult.css";
import "../assets/styles/components.css";

export default function AssessmentResultPage() {
  const navigate = useNavigate();

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
              className="result-btn result-btn-primary"
              type="button"
              onClick={() => navigate("/assistant")}
              id="result-consult-specialist"
            >
              Ask about my result
            </button>
          </div>
        </div>

        <section className="result-grid">
          {/* Left — Diagnosis */}
          <div className="result-card">
            <div className="result-card-top">
              <div>
                <div className="result-card-kicker">Primary Diagnosis</div>
                <div className="result-diagnosis-row">
                  <div className="result-diagnosis">Atopic Eczema</div>
                  <span className="badge badge-success">Verified AI</span>
                </div>
              </div>
            </div>

            <div className="result-metric">
              <div className="result-metric-label">AI Confidence Score</div>
              <div className="result-metric-row">
                <div className="result-metric-bar">
                  <div
                    className="result-metric-fill"
                    style={{ width: "94%" }}
                  />
                </div>
                <div className="result-metric-value">94%</div>
              </div>
            </div>

            <div
              className="result-image-card"
              aria-label="Dermatology close-up illustration"
            >
              <div className="result-image-overlay" />
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
                <rect
                  x="0"
                  y="0"
                  width="240"
                  height="140"
                  fill="url(#skinGrad)"
                />
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
              <div className="result-image-caption">
                Microscopic texture analysis
              </div>
            </div>

            <div className="result-pill-grid">
              <div className="result-pill">
                <div className="result-pill-label">Duration</div>
                <div className="result-pill-value">~ 48 hours</div>
              </div>
              <div className="result-pill">
                <div className="result-pill-label">Severity</div>
                <div className="result-pill-value">Moderate</div>
              </div>
            </div>
          </div>

          {/* Right — Details */}
          <div className="result-right">
            <div className="result-card">
              <div className="result-section-title">About Atopic Eczema</div>
              <p className="result-paragraph">
                Atopic dermatitis (eczema) is a condition that makes your skin
                red and itchy. It&apos;s common in children but can occur at any
                age. It is long-lasting (chronic) and tends to flare
                periodically. It may be accompanied by asthma or hay fever.
              </p>

              <div className="result-split">
                <div>
                  <div className="result-subtitle">Key symptoms</div>
                  <ul className="result-list">
                    <li>Dry, scaly patches</li>
                    <li>Itching, which may be severe</li>
                    <li>Red to brownish-gray patches</li>
                  </ul>
                </div>

                <div>
                  <div className="result-subtitle">Common triggers</div>
                  <ul className="result-list result-list-warn">
                    <li>Harsh soaps or detergents</li>
                    <li>Environmental allergens</li>
                    <li>Stress and heat</li>
                  </ul>
                </div>
              </div>
            </div>

            <div className="result-card">
              <div className="result-section-title">Clinical Next Steps</div>

              <button
                className="nextstep"
                type="button"
                onClick={() => navigate("/assistant")}
                id="nextstep-1"
              >
                <span className="nextstep-num">1</span>
                <span className="nextstep-main">
                  <span className="nextstep-title">Gentle Hydration</span>
                  <span className="nextstep-desc">
                    Apply fragrance-free moisturizer twice daily.
                  </span>
                </span>
                <span className="nextstep-arrow" aria-hidden="true">
                  ›
                </span>
              </button>

              <button
                className="nextstep"
                type="button"
                onClick={() => navigate("/assistant")}
                id="nextstep-2"
              >
                <span className="nextstep-num">2</span>
                <span className="nextstep-main">
                  <span className="nextstep-title">OTC Treatment</span>
                  <span className="nextstep-desc">
                    Consider 1% hydrocortisone cream for itching.
                  </span>
                </span>
                <span className="nextstep-arrow" aria-hidden="true">
                  ›
                </span>
              </button>

              <button
                className="nextstep"
                type="button"
                onClick={() => navigate("/assistant")}
                id="nextstep-3"
              >
                <span className="nextstep-num">3</span>
                <span className="nextstep-main">
                  <span className="nextstep-title">Specialist Consult</span>
                  <span className="nextstep-desc">
                    Schedule a follow-up for confirmation and treatment plan.
                  </span>
                </span>
                <span className="nextstep-arrow" aria-hidden="true">
                  ›
                </span>
              </button>
            </div>
          </div>
        </section>
      </main>

      <Footer />
    </div>
  );
}
