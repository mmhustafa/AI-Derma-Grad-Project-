import { useNavigate } from "react-router-dom";
import { useState, useEffect } from "react";
import { useAuth } from "../contexts/AuthContext";
import Navbar from "../components/Navbar";
import Footer from "../components/Footer";
import historyService from "../services/historyService";
import "../assets/styles/home.css";
import "../assets/styles/components.css";

export default function HomePage() {
  const navigate = useNavigate();
  const { isAuthenticated } = useAuth();
  const [history, setHistory] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const [hasFetched, setHasFetched] = useState(false);

  // Fetch history when component mounts and user is authenticated
  useEffect(() => {
    if (isAuthenticated && !hasFetched) {
      setHasFetched(true);
      fetchHistory();
    }
  }, [isAuthenticated, hasFetched]);

  const fetchHistory = async () => {
    setLoading(true);
    setError("");
    try {
      const data = await historyService.getDiagnostics();
      setHistory(Array.isArray(data) ? data.slice(0, 2) : []); // Show only first 2 items
    } catch (err) {
      // For any error, just show empty state - don't redirect
      console.warn("Failed to load history:", err.message);
      setHistory([]);
    } finally {
      setLoading(false);
    }
  };

  // Helper function to format date
  const formatDate = (dateString) => {
    if (!dateString) return "Unknown date";
    try {
      const date = new Date(dateString);
      return date.toLocaleDateString("en-US", {
        year: "numeric",
        month: "short",
        day: "numeric",
      });
    } catch {
      return dateString;
    }
  };

  // Helper function to get status display
  const getStatusDisplay = (status) => {
    const statusMap = {
      completed: "Completed",
      pending: "Pending Review",
      analyzing: "Analysis Phase",
      processing: "Processing",
    };
    return statusMap[status?.toLowerCase()] || status || "In Progress";
  };

  return (
    <div
      style={{
        minHeight: "100vh",
        display: "flex",
        flexDirection: "column",
        background: "var(--bg-primary)",
      }}
    >
      <Navbar />

      {/* Hero Banner */}
      <section className="hero-banner">
        {/* Decorative neural lines SVG */}
        <svg
          className="hero-decoration"
          viewBox="0 0 400 300"
          xmlns="http://www.w3.org/2000/svg"
        >
          <g stroke="white" strokeWidth="0.8" fill="none">
            <circle cx="200" cy="150" r="80" />
            <circle cx="200" cy="150" r="120" />
            <circle cx="200" cy="150" r="40" />
            <line x1="200" y1="30" x2="200" y2="270" />
            <line x1="80" y1="150" x2="320" y2="150" />
            <line x1="113" y1="63" x2="287" y2="237" />
            <line x1="287" y1="63" x2="113" y2="237" />
            {[0, 45, 90, 135, 180, 225, 270, 315].map((deg, i) => {
              const rad = (deg * Math.PI) / 180;
              const x1 = 200 + 40 * Math.cos(rad);
              const y1 = 150 + 40 * Math.sin(rad);
              const x2 = 200 + 120 * Math.cos(rad);
              const y2 = 150 + 120 * Math.sin(rad);
              return <line key={i} x1={x1} y1={y1} x2={x2} y2={y2} />;
            })}
          </g>
        </svg>

        <div className="hero-eyebrow">Clinical Sanctuary Assessment</div>
        <h1 className="hero-title">
          Intelligence in
          <br />
          Skin Health.
        </h1>
        <p className="hero-subtitle">
          Start your journey towards dermatological clarity with our AI-assisted
          diagnostic tools. Secure, private, and precise.
        </p>
        <div className="hero-actions">
          <button
            className="btn btn-primary"
            onClick={() => navigate("/upload")}
            id="hero-photo-btn"
          >
            <svg
              width="16"
              height="16"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              strokeWidth="2"
            >
              <path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z" />
              <circle cx="12" cy="13" r="4" />
            </svg>
            Continue with Photo
          </button>
          <button
            className="btn btn-outline"
            onClick={() => navigate("/assess")}
            id="hero-symptoms-btn"
          >
            <svg
              width="16"
              height="16"
              viewBox="0 0 24 24"
              fill="none"
              stroke="currentColor"
              strokeWidth="2"
            >
              <path d="M9 11l3 3L22 4" />
              <path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11" />
            </svg>
            Go to Symptom Questions
          </button>
        </div>
      </section>

      {/* Main Content */}
      <main className="home-main">
        {/* Two column grid */}
        <div className="home-grid-2">
          {/* Clinical History */}
          <div className="history-card">
            <div className="history-card-header">
              <div>
                <div className="history-card-title">Clinical History</div>
                <div className="history-card-subtitle">
                  Your recent dermatological records
                </div>
              </div>
              <span
                className="view-all-link"
                role="button"
                tabIndex={0}
                onClick={() => navigate("/history")}
                onKeyDown={(e) => e.key === "Enter" && navigate("/history")}
              >
                View All
              </span>
            </div>

            <div className="history-list">
              {loading ? (
                <div style={{ padding: "24px", textAlign: "center", color: "var(--text-secondary)" }}>
                  <div style={{ fontSize: "0.9rem" }}>Loading your history...</div>
                </div>
              ) : error ? (
                <div style={{ padding: "24px", textAlign: "center", color: "var(--text-secondary)" }}>
                  <div style={{ fontSize: "0.9rem", marginBottom: "12px" }}>{error}</div>
                  <button
                    onClick={fetchHistory}
                    style={{
                      padding: "6px 12px",
                      backgroundColor: "var(--primary)",
                      color: "white",
                      border: "none",
                      borderRadius: "4px",
                      cursor: "pointer",
                      fontSize: "0.85rem",
                    }}
                  >
                    Retry
                  </button>
                </div>
              ) : history.length > 0 ? (
                history.map((item, index) => (
                  <div
                    key={item.id || index}
                    className="history-item"
                    onClick={() => navigate(`/result?id=${item.id}`)}
                    role="button"
                    tabIndex={0}
                    onKeyDown={(e) => e.key === "Enter" && navigate(`/result?id=${item.id}`)}
                  >
                    <div className={`history-item-icon ${item.status?.toLowerCase() === "completed" ? "success" : ""}`}>
                      {item.status?.toLowerCase() === "completed" ? (
                        <svg
                          width="18"
                          height="18"
                          viewBox="0 0 24 24"
                          fill="none"
                          stroke="currentColor"
                          strokeWidth="2"
                        >
                          <polyline points="20 6 9 17 4 12" />
                        </svg>
                      ) : (
                        <svg
                          width="18"
                          height="18"
                          viewBox="0 0 24 24"
                          fill="none"
                          stroke="currentColor"
                          strokeWidth="2"
                        >
                          <polyline points="23 4 23 10 17 10" />
                          <polyline points="1 20 1 14 7 14" />
                          <path d="M3.51 9a9 9 0 0 1 14.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0 0 20.49 15" />
                        </svg>
                      )}
                    </div>
                    <div className="history-item-content">
                      <div className="history-item-title">
                        {item.disease || item.diagnosis || `Assessment #${item.id?.slice(-4) || "0000"}`}
                      </div>
                      <div className="history-item-meta">
                        {formatDate(item.diagnosisDate || item.createdAt)} • {getStatusDisplay(item.status)}
                      </div>
                    </div>
                    <svg
                      className="history-item-arrow"
                      width="14"
                      height="14"
                      viewBox="0 0 24 24"
                      fill="none"
                      stroke="currentColor"
                      strokeWidth="2"
                    >
                      <polyline points="9 18 15 12 9 6" />
                    </svg>
                  </div>
                ))
              ) : (
                <div style={{ padding: "24px", textAlign: "center", color: "var(--text-secondary)" }}>
                  <div style={{ fontSize: "0.9rem", marginBottom: "12px" }}>No assessments yet</div>
                  <button
                    onClick={() => navigate("/upload")}
                    style={{
                      padding: "8px 16px",
                      backgroundColor: "var(--primary)",
                      color: "white",
                      border: "none",
                      borderRadius: "4px",
                      cursor: "pointer",
                      fontSize: "0.9rem",
                    }}
                  >
                    Start Your First Assessment
                  </button>
                </div>
              )}
            </div>
          </div>

          {/* Protocol Card */}
          <div className="protocol-card">
            <div className="protocol-title">The AI-Derma Protocol</div>
            <p className="protocol-desc">
              Our clinical sanctuary utilizes a multi-layered diagnostic engine
              that compares your skin data against thousands of verified cases.
            </p>
            <div className="protocol-steps">
              {[
                "Ensure high-resolution lighting.",
                "Answer clinical questions.",
                "Receive AI and Specialist insights.",
              ].map((step, i) => (
                <div className="protocol-step" key={i}>
                  <div className="protocol-step-num">{i + 1}</div>
                  <div className="protocol-step-text">{step}</div>
                </div>
              ))}
            </div>
            {/* <button
              className="btn btn-outline-dark btn-full"
              id="protocol-guide-btn"
              style={{ borderRadius: "var(--radius-md)" }}
            >
              View Comprehensive Guide
            </button> */}
          </div>
        </div>

        {/* Bottom Section */}
        <div className="home-bottom-grid">
          {/* Did you know */}
          <div className="did-you-know">
            <div className="did-you-know-icon">
              <svg
                width="18"
                height="18"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                strokeWidth="2"
              >
                <path d="M9 18h6" />
                <path d="M10 22h4" />
                <path d="M15.09 14c.18-.98.65-1.74 1.41-2.5A4.65 4.65 0 0 0 18 8 6 6 0 0 0 6 8c0 1 .23 2.23 1.5 3.5A4.61 4.61 0 0 1 8.91 14" />
              </svg>
            </div>
            <div className="did-you-know-title">Did you know?</div>
            <p className="did-you-know-text">
              The skin is your body's largest organ. It renews itself roughly
              every 28 to 30 days to maintain its barrier integrity.
            </p>
          </div>

          {/* Article Card */}
          <div className="article-card" id="article-spf">
            <div className="article-content">
              <div className="article-eyebrow">
                <span className="article-tag">Skin Care Tip</span>
                <span className="article-read-time">• 4 min read</span>
              </div>
              <h3 className="article-title">
                The Importance of SPF in Clinical Recovery
              </h3>
              <p className="article-desc">
                UV radiation can decelerate the healing of skin conditions.
                Using a broad-spectrum SPF 30+ daily is critical during
                treatment phases.
              </p>
              <span className="article-learn-more">Learn more →</span>
            </div>
            <div className="article-image-placeholder">🧴</div>
          </div>
        </div>
      </main>

      <Footer />
    </div>
  );
}
