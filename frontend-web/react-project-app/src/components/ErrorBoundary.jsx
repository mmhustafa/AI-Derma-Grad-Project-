import React from "react";

/**
 * ErrorBoundary — wraps the app to catch unhandled render errors
 * and display a helpful message instead of a blank white screen.
 */
export default class ErrorBoundary extends React.Component {
  constructor(props) {
    super(props);
    this.state = { hasError: false, error: null };
  }

  static getDerivedStateFromError(error) {
    return { hasError: true, error };
  }

  componentDidCatch(error, info) {
    console.error("ErrorBoundary caught:", error, info.componentStack);
  }

  render() {
    if (this.state.hasError) {
      return (
        <div
          style={{
            minHeight: "100vh",
            display: "flex",
            flexDirection: "column",
            alignItems: "center",
            justifyContent: "center",
            background: "#f0f4f8",
            fontFamily: "Inter, sans-serif",
            padding: "32px",
          }}
        >
          <div
            style={{
              background: "#fff",
              border: "1px solid #dde8f0",
              borderRadius: "16px",
              padding: "40px",
              maxWidth: "560px",
              width: "100%",
              boxShadow: "0 8px 32px rgba(0,0,0,0.1)",
            }}
          >
            <div style={{ fontSize: "2rem", marginBottom: "12px" }}>⚠️</div>
            <h2
              style={{
                color: "#0f1f2e",
                fontSize: "1.3rem",
                marginBottom: "12px",
              }}
            >
              Something went wrong
            </h2>
            <p style={{ color: "#5a7a96", marginBottom: "20px", fontSize: "0.9rem" }}>
              The app encountered an unexpected error. See below for details.
            </p>
            <pre
              style={{
                background: "#f0f4f8",
                borderRadius: "8px",
                padding: "16px",
                fontSize: "0.78rem",
                color: "#ef4444",
                overflowX: "auto",
                whiteSpace: "pre-wrap",
                wordBreak: "break-word",
              }}
            >
              {this.state.error?.toString()}
            </pre>
            <button
              onClick={() => window.location.reload()}
              style={{
                marginTop: "20px",
                padding: "10px 24px",
                background: "#00a8e8",
                color: "#fff",
                border: "none",
                borderRadius: "9999px",
                cursor: "pointer",
                fontWeight: 600,
                fontSize: "0.9rem",
              }}
            >
              Reload page
            </button>
          </div>
        </div>
      );
    }

    return this.props.children;
  }
}
