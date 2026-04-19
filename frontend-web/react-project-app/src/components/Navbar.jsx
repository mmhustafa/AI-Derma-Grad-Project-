import { NavLink, useNavigate } from "react-router-dom";
import { useAuth } from "../contexts/AuthContext";
import "../assets/styles/navbar.css";

export default function Navbar() {
  const navigate = useNavigate();
  const { isAuthenticated, logout } = useAuth();

  const handleLogout = () => {
    logout();
    navigate("/login");
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

              <button
                onClick={handleLogout}
                className="btn btn-secondary navbar-logout-btn"
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
