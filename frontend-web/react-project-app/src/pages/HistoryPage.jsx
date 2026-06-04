import { useMemo, useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { useAuth } from "../contexts/AuthContext";
import historyService from "../services/historyService";
import Navbar from "../components/Navbar";
import Footer from "../components/Footer";
import "../assets/styles/history.css";
import "../assets/styles/components.css";

const FILTERS = [
  { id: "all", label: "All records" },
  { id: "ai", label: "AI result" },
  { id: "questions", label: "Questions" },
];

/** Normalise confidence to 0‑100 whether API returns 0‑1 or 0‑100 */
function toPercent(raw) {
  const n = typeof raw === "number" ? raw : parseFloat(raw) || 0;
  return n <= 1 ? Math.round(n * 100) : Math.round(n);
}

export default function HistoryPage() {
  const navigate = useNavigate();
  const { isAuthenticated } = useAuth();
  const [activeFilter, setActiveFilter] = useState("all");
  const [diagnostics, setDiagnostics] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [loadingId, setLoadingId] = useState(null); // track which card is loading

  useEffect(() => {
    const fetchHistory = async () => {
      try {
        const data = await historyService.getDiagnostics();
        setDiagnostics(Array.isArray(data) ? data : []);
      } catch (err) {
        console.warn("Failed to load history:", err.message);
        setDiagnostics([]);
      } finally {
        setLoading(false);
      }
    };

    fetchHistory();
  }, []);

  /** Open the full report by fetching /History/diagnostic/{id} first */
  const handleViewReport = async (id, diseaseNameFromList) => {
    setLoadingId(id);
    try {
      const detail = await historyService.getDiagnosticDetails(id);
      console.log("[HistoryDetail] raw response:", detail);

      // Disease info lives in the nested `disease` object
      const disease = detail.disease || {};

      // Resolve disease name from the nested object, then fallback chain
      const resolvedName =
        (typeof disease.diseaseName === "string" && disease.diseaseName.trim())
          ? disease.diseaseName.trim()
          : (typeof detail.diseaseName === "string" && detail.diseaseName.trim())
            ? detail.diseaseName.trim()
            : (typeof diseaseNameFromList === "string" && diseaseNameFromList.trim())
              ? diseaseNameFromList.trim()
              : "Unknown";

      // Normalise confidence to 0–1
      const rawConf = detail.confidenceScore;
      const resolvedConf =
        typeof rawConf === "number"
          ? rawConf <= 1 ? rawConf : rawConf / 100
          : 0;

      // sourceType: "AI Model" → "ai",  "KB" → "expert"
      const resolvedSource =
        typeof detail.sourceType === "string" && detail.sourceType.toLowerCase().includes("kb")
          ? "expert"
          : "ai";

      navigate("/result", {
        state: {
          diseaseName:        resolvedName,
          confidence:         resolvedConf,
          source:             resolvedSource,
          diagnosticResultId: detail.id,
          fromHistory:        true,
          // Full raw payload — AssessmentResultPage reads disease + imageUrl from here
          historyDetail:      detail,
        },
      });
    } catch (err) {
      console.error("Failed to load report:", err.message);
      alert("Could not load the full report. Please try again.");
    } finally {
      setLoadingId(null);
    }
  };

  const items = useMemo(
    () =>
      diagnostics.map((d) => {
        const pct = toPercent(d.confidenceScore);
        const risk = pct > 80 ? "low" : pct > 50 ? "moderate" : "high";
        return {
          id: d.id,
          risk,
          title: d.sourceType === "KB" ? "Knowledge Base Diagnosis" : "AI Analysis",
          time: d.createdAt ? new Date(d.createdAt).toLocaleString() : "—",
          confidencePct: pct,          // number 0‑100
          confidenceLabel: `${pct}%`,  // display string
          badge: pct > 80 ? "Low risk" : pct > 50 ? "Moderate" : "High risk",
          disease: typeof d.diseaseName === "string" ? d.diseaseName : "",
        };
      }),
    [diagnostics],
  );

  const filtered = useMemo(() => {
    if (activeFilter === "all") return items;
    if (activeFilter === "ai") return items.filter((x) => x.title === "AI Analysis");
    if (activeFilter === "questions") return items.filter((x) => x.title === "Knowledge Base Diagnosis");
    return items;
  }, [activeFilter, items]);

  if (loading) {
    return (
      <div className="history-page">
        <Navbar />
        <main className="history-body">
          <div className="history-loading">
            <div className="history-spinner" />
            Loading history...
          </div>
        </main>
        <Footer />
      </div>
    );
  }

  if (error) {
    return (
      <div className="history-page">
        <Navbar />
        <main className="history-body">
          <div style={{ textAlign: "center", padding: "50px", color: "red" }}>{error}</div>
        </main>
        <Footer />
      </div>
    );
  }

  return (
    <div className="history-page">
      <Navbar />

      <main className="history-body">
        <div className="history-header">
          <div>
            <div className="history-eyebrow">Clinical time line</div>
            <h1 className="history-title">History</h1>
            <p className="history-subtitle">
              A comprehensive record of your skin health journey, including AI
              analysis reports and clinical interactions.
            </p>
          </div>

          <div className="history-top-right">
            <div className="history-search">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.4">
                <circle cx="11" cy="11" r="8" />
                <path d="m21 21-4.35-4.35" />
              </svg>
              <span>Search assessments...</span>
            </div>
          </div>
        </div>

        <section className="history-layout">
          {/* Left rail */}
          <aside className="history-rail">
            <div className="history-rail-title">Categorization</div>
            <div className="history-rail-filters">
              {FILTERS.map((f) => (
                <button
                  key={f.id}
                  type="button"
                  className={`history-rail-btn ${activeFilter === f.id ? "active" : ""}`}
                  onClick={() => setActiveFilter(f.id)}
                  id={`history-filter-${f.id}`}
                >
                  {f.label}
                </button>
              ))}
            </div>

            <div className="history-quick">
              <div className="history-quick-title">Quick filter</div>
              <div className="history-tags">
                <span className="history-tag">Melanoma</span>
                <span className="history-tag">Eczema</span>
                <span className="history-tag">Psoriasis</span>
              </div>
            </div>
          </aside>

          {/* Main */}
          <div className="history-main">
            <div className="history-stats">
              <div className="history-stat">
                <div className="history-stat-num">{items.length}</div>
                <div className="history-stat-label">Total assessed</div>
              </div>
              <div className="history-stat ok">
                <div className="history-stat-num">100%</div>
                <div className="history-stat-label">Verified accuracy</div>
              </div>
            </div>

            <div className="history-cards">
              {filtered.map((it) => (
                <article key={it.id} className="history-card2">
                  <div className="history-card2-top">
                    <div className={`risk-pill ${it.risk}`}>{it.badge}</div>
                    <button className="dots" type="button" aria-label="More options">⋮</button>
                  </div>

                  <div className="history-card2-mid">
                    <div className="history-card2-title">{it.title}</div>
                    <div className="history-card2-time">{it.time}</div>
                  </div>

                  {/* ── Confidence bar ── */}
                  <div className="history-meter">
                    <div className="history-meter-row">
                      <span className="history-meter-label">Confidence score</span>
                      <span
                        className="history-meter-value"
                        style={{
                          color:
                            it.risk === "high"
                              ? "#ef4444"
                              : it.risk === "moderate"
                              ? "#f59e0b"
                              : "#22c55e",
                        }}
                      >
                        {it.confidenceLabel}
                      </span>
                    </div>
                    <div className="history-meter-track">
                      <div
                        className={`history-meter-fill ${it.risk}`}
                        style={{ width: `${it.confidencePct}%` }}
                      />
                    </div>
                  </div>

                  {it.disease && (
                    <p className="history-note">Diagnosed: <strong>{it.disease}</strong></p>
                  )}

                  <div className="history-card2-bottom">
                    <button
                      className="history-link"
                      type="button"
                      onClick={() => handleViewReport(it.id, it.disease)}
                      id={`history-view-${it.id}`}
                      disabled={loadingId === it.id}
                    >
                      {loadingId === it.id ? (
                        <span className="history-link-loading">Loading…</span>
                      ) : (
                        "View full report →"
                      )}
                    </button>
                    <span className="badge badge-primary">
                      {it.title.includes("AI") ? "AI" : "KB"}
                    </span>
                  </div>
                </article>
              ))}

              <button
                className="history-new"
                type="button"
                onClick={() => navigate("/upload")}
                id="history-new-assessment"
              >
                <div className="history-new-plus">+</div>
                <div className="history-new-title">New assessment</div>
                <div className="history-new-sub">Upload a new skin image for AI analysis</div>
              </button>
            </div>
          </div>
        </section>
      </main>

      <Footer />
    </div>
  );
}
