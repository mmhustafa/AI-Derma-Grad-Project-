import React, { createContext, useContext, useState, useEffect } from "react";
import { authAPI } from "../services/api";

const AuthContext = createContext();

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error("useAuth must be used within an AuthProvider");
  }
  return context;
};

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(() => {
    // Initialize user state immediately if token exists
    const storedToken = localStorage.getItem("token");
    return storedToken ? { token: storedToken } : null;
  });
  const [token, setToken] = useState(localStorage.getItem("token"));
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    const storedToken = localStorage.getItem("token");
    if (storedToken && !user) {
      setToken(storedToken);
      setUser({ token: storedToken });
    }
  }, [user]);

  const login = async (email, password) => {
    setLoading(true);
    try {
      const response = await authAPI.login({ email, password });
      const { token: newToken } = response.data;
      localStorage.setItem("token", newToken);
      setToken(newToken);
      setUser({ token: newToken });
      return { success: true };
    } catch (error) {
      return {
        success: false,
        error: error.response?.data?.message || "Login failed",
      };
    } finally {
      setLoading(false);
    }
  };

  const extractErrorDetails = (error) => {
    const responseData = error?.response?.data;
    if (!responseData) return { errors: ["Registration failed"], fieldErrors: {} };

    // Handle string response
    if (typeof responseData === "string") {
      return { errors: [responseData], fieldErrors: {} };
    }

    // Check if errors are nested under responseData.errors
    let errorsObj = responseData.errors || responseData;
    
    const fieldErrors = {};
    const errors = [];
    const fieldMap = {
      UserName: "userName",
      Email: "email",
      Password: "password",
      Age: "age",
      Gender: "gender",
    };

    // Extract all error messages
    Object.entries(errorsObj).forEach(([key, value]) => {
      // Handle both string and array values
      const values = Array.isArray(value) ? value : [value];
      const messages = values.filter(v => v && typeof v === 'string');
      
      if (messages.length > 0) {
        const joined = messages.join(" ");
        
        // Map field names for form validation
        if (key && fieldMap[key]) {
          fieldErrors[fieldMap[key]] = joined;
        } else if (key && key !== "") {
          fieldErrors[key] = joined;
        }
        
        // Collect all error messages
        errors.push(joined);
      }
    });

    return {
      errors: errors.length > 0 ? errors : ["Registration failed"],
      fieldErrors,
    };
  };

  const register = async (userData) => {
    setLoading(true);
    try {
      await authAPI.register(userData);
      return { success: true };
    } catch (error) {
      const { errors, fieldErrors } = extractErrorDetails(error);
      return {
        success: false,
        errors, // Array of error strings
        fieldErrors, // Map of field-specific errors
      };
    } finally {
      setLoading(false);
    }
  };

  const logout = () => {
    localStorage.removeItem("token");
    setToken(null);
    setUser(null);
  };

  const isAuthenticated = !!token;

  return (
    <AuthContext.Provider
      value={{
        user,
        token,
        loading,
        login,
        register,
        logout,
        isAuthenticated,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
};
