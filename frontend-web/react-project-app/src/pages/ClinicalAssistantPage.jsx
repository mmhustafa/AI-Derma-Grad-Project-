import { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { useAuth } from "../contexts/AuthContext";
import { chatAPI } from "../services/api";
import Navbar from "../components/Navbar";
import Footer from "../components/Footer";
import "../assets/styles/assistant.css";
import "../assets/styles/components.css";

export default function ClinicalAssistantPage() {
  const navigate = useNavigate();
  const { isAuthenticated } = useAuth();
  const [messages, setMessages] = useState([]);
  const [input, setInput] = useState("");
  const [loading, setLoading] = useState(false);
  const [sessionId, setSessionId] = useState("");

  useEffect(() => {
    // Wait for authentication to be established
    const token = localStorage.getItem("token");
    if (!token) {
      navigate("/login");
      return;
    }

    if (!isAuthenticated) {
      // If we have a token but isAuthenticated is false, wait a bit for state to update
      const timer = setTimeout(() => {
        if (!isAuthenticated) {
          navigate("/login");
        }
      }, 100);
      return () => clearTimeout(timer);
    }

    const initializeChat = async () => {
      try {
        const response = await chatAPI.getWelcome();
        setSessionId(response.data.sessionId);
        setMessages([
          {
            id: "welcome",
            role: "assistant",
            author: "AL-DERMA AI",
            time: new Date().toLocaleTimeString(),
            text: response.data.reply,
          },
        ]);
      } catch (error) {
        console.error("Failed to initialize chat", error);
      }
    };

    initializeChat();
  }, [isAuthenticated, navigate]);

  const handleSendMessage = async () => {
    if (!input.trim() || loading) return;

    const userMessage = {
      id: Date.now(),
      role: "user",
      author: "You",
      time: new Date().toLocaleTimeString(),
      text: input,
    };

    setMessages((prev) => [...prev, userMessage]);
    setInput("");
    setLoading(true);

    try {
      const response = await chatAPI.sendMessage({
        message: input,
        sessionId,
        condition: "",
        confidence: 0,
      });

      const aiMessage = {
        id: Date.now() + 1,
        role: "assistant",
        author: "AL-DERMA AI",
        time: new Date().toLocaleTimeString(),
        text: response.data.reply,
      };

      setMessages((prev) => [...prev, aiMessage]);
    } catch (error) {
      console.error("Failed to send message", error);
      const errorMessage = {
        id: Date.now() + 1,
        role: "assistant",
        author: "AL-DERMA AI",
        time: new Date().toLocaleTimeString(),
        text: "Sorry, I encountered an error. Please try again.",
      };
      setMessages((prev) => [...prev, errorMessage]);
    } finally {
      setLoading(false);
    }
  };

  const handleSend = () => {
    handleSendMessage();
  };

  return (
    <div className="assistant-page">
      <Navbar />

      <main className="assistant-body">
        <div className="assistant-topbar">
          <div>
            <div className="assistant-tab-row">
              <span className="assistant-tab active">Active session</span>
              <span className="assistant-tab">Encrypted</span>
            </div>
            <h1 className="assistant-title">
              Clinical Assistant —{" "}
              <span className="assistant-title-accent">AI-Derma Identity</span>
            </h1>
          </div>

          <div className="assistant-actions">
            <button
              className="assistant-btn assistant-btn-ghost"
              type="button"
              onClick={() => window.print()}
              id="assistant-export-transcript"
            >
              Export transcript
            </button>
            <button
              className="assistant-btn assistant-btn-primary"
              type="button"
              onClick={() => navigate("/result")}
              id="assistant-clinical-summary"
            >
              Clinical summary
            </button>
          </div>
        </div>

        <section className="assistant-chat-card">
          <div
            className="assistant-chat-scroll"
            role="log"
            aria-label="Clinical assistant chat"
          >
            {messages.map((m) => (
              <div
                key={m.id}
                className={`chat-row ${m.role === "user" ? "right" : "left"}`}
              >
                <div className="chat-meta">
                  <span
                    className={`chat-badge ${m.role === "user" ? "badge-user" : "badge-ai"}`}
                  >
                    {m.author}
                  </span>
                  <span className="chat-time">{m.time}</span>
                </div>
                <div
                  className={`chat-bubble ${m.role === "user" ? "bubble-user" : "bubble-ai"}`}
                >
                  <p className="chat-text">{m.text}</p>
                  {m.card ? (
                    <div className="ai-card">
                      <div className="ai-card-col">
                        <div className="ai-card-label">Confidence score</div>
                        <div className="ai-card-value">{m.card.confidence}</div>
                      </div>
                      <div className="ai-card-col">
                        <div className="ai-card-label">Risk classification</div>
                        <div className="ai-card-risk">{m.card.risk}</div>
                        <div className="ai-card-note">{m.card.note}</div>
                      </div>
                    </div>
                  ) : null}
                </div>
              </div>
            ))}
          </div>

          <div className="assistant-input-row">
            <div className="assistant-input-wrap">
              <input
                value={input}
                onChange={(e) => setInput(e.target.value)}
                onKeyDown={(e) => e.key === "Enter" && handleSend()}
                className="assistant-input"
                placeholder="Type clinical findings or ask for diagnostic support..."
                aria-label="Message input"
                id="assistant-message-input"
              />
              <button
                className="assistant-send"
                type="button"
                onClick={handleSend}
                disabled={loading}
                aria-label="Send message"
                id="assistant-send-btn"
              >
                {loading ? (
                  "..."
                ) : (
                  <svg
                    width="16"
                    height="16"
                    viewBox="0 0 24 24"
                    fill="none"
                    stroke="currentColor"
                    strokeWidth="2.3"
                  >
                    <path d="M22 2 11 13" />
                    <path d="M22 2 15 22 11 13 2 9 22 2z" />
                  </svg>
                )}
              </button>
            </div>
            <div className="assistant-disclaimer">
              AI-generated assessments are for clinical decision support only and
              do not replace a licensed consultant.
            </div>
          </div>
        </section>
      </main>

      <Footer />
    </div>
  );
}
