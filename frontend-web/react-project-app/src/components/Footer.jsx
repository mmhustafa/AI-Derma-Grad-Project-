import "../assets/styles/components.css";

export default function Footer() {
  return (
    <footer className="footer">
      <div className="footer-inner">
        <span className="footer-copy">
          © 2026 Al-Derma Clinical Sanctuary. All Rights Reserved.
        </span>
        <div className="footer-links">
          <a href="#clinical">Clinical Guidelines</a>
          <a href="#privacy">Privacy Policy</a>
          <a href="#terms">Terms of Service</a>
          <a href="#support">Contact Support</a>
        </div>
      </div>
    </footer>
  );
}
