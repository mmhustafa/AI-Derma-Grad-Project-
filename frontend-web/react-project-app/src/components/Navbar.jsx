import { NavLink, useNavigate } from "react-router-dom";
import { useAuth } from "../contexts/AuthContext";
import "../assets/styles/navbar.css";

export default function Navbar() {
  const navigate = useNavigate();
  const { isAuthenticated, logout } = useAuth();

  const handleLogout = () => {
    logout();
    navigate("/");
  };

  return (
    <nav className="navbar">
      <div className="navbar-inner">
        {/* Logo */}
        <span
          className="navbar-logo"
          onClick={() => navigate("/")}
          style={{ cursor: "pointer" }}
        >
          Al-Derma
        </span>

        {/* Nav Links */}
        <ul className="navbar-links">
          <li>
            <NavLink
              to="/"
              end
              className={({ isActive }) => (isActive ? "active" : "")}
            >
              Home
            </NavLink>
          </li>
          {isAuthenticated && (
            <>
              <li>
                <NavLink
                  to="/history"
                  className={({ isActive }) => (isActive ? "active" : "")}
                >
                  History
                </NavLink>
              </li>
              <li>
                <NavLink
                  to="/assess"
                  className={({ isActive }) => (isActive ? "active" : "")}
                >
                  Assess
                </NavLink>
              </li>
              <li>
                <NavLink
                  to="/assistant"
                  className={({ isActive }) => (isActive ? "active" : "")}
                >
                  Assistant
                </NavLink>
              </li>
              <li>
                <NavLink
                  to="/profile"
                  className={({ isActive }) => (isActive ? "active" : "")}
                >
                  Profile
                </NavLink>
              </li>
            </>
          )}
        </ul>

        {/* Right section */}
        <div className="navbar-right">
          {isAuthenticated ? (
            <>
              <div className="navbar-search">
                <svg
                  width="13"
                  height="13"
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth="2.5"
                >
                  <circle cx="11" cy="11" r="8" />
                  <path d="m21 21-4.35-4.35" />
                </svg>
                Search insights...
              </div>

              <button className="navbar-icon-btn" aria-label="Notifications">
                <svg
                  width="16"
                  height="16"
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth="2"
                >
                  <path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9" />
                  <path d="M13.73 21a2 2 0 0 1-3.46 0" />
                </svg>
              </button>

              <button className="navbar-icon-btn" aria-label="Settings">
                <svg
                  width="16"
                  height="16"
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth="2"
                >
                  <circle cx="12" cy="12" r="3" />
                  <path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83-2.83l.06-.06A1.65 1.65 0 0 0 4.68 15a1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 2.83-2.83l.06.06A1.65 1.65 0 0 0 9 4.68a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 2.83l-.06.06A1.65 1.65 0 0 0 19.4 9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z" />
                </svg>
              </button>

              <button
                onClick={handleLogout}
                className="navbar-icon-btn"
                aria-label="Logout"
              >
                Logout
              </button>
            </>
          ) : (
            <button
              onClick={() => navigate("/login")}
              className="btn btn-primary navbar-login-btn"
              aria-label="Login"
            >
              Sign In
            </button>
          )}
        </div>
      </div>
    </nav>
  );
}
