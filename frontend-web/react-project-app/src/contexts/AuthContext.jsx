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
  const [user, setUser] = useState(null);
  const [token, setToken] = useState(localStorage.getItem("token"));
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (token) {
      // Optionally decode token to get user info
      setUser({ token });
    }
  }, [token]);

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
    if (!responseData) return { message: "Registration failed", fieldErrors: {} };

    if (typeof responseData === "string") {
      return { message: responseData, fieldErrors: {} };
    }

    if (responseData.errors && typeof responseData.errors === "object") {
      const fieldErrors = {};
      const messages = [];
      const fieldMap = {
        UserName: "userName",
        Email: "email",
        Password: "password",
        Age: "age",
        Gender: "gender",
      };

      Object.entries(responseData.errors).forEach(([key, value]) => {
        const values = Array.isArray(value) ? value : [value];
        const joined = values.join(" ");
        if (key && fieldMap[key]) {
          fieldErrors[fieldMap[key]] = joined;
        } else if (key) {
          fieldErrors[key] = joined;
        }
        messages.push(joined);
      });

      return {
        message: messages.length ? messages.join(" ") : "Registration failed",
        fieldErrors,
      };
    }

    if (responseData.title && responseData.detail) {
      return { message: `${responseData.title}: ${responseData.detail}`, fieldErrors: {} };
    }

    return {
      message: responseData.message || "Registration failed",
      fieldErrors: {},
    };
  };

  const register = async (userData) => {
    setLoading(true);
    try {
      await authAPI.register(userData);
      return { success: true };
    } catch (error) {
      const details = extractErrorDetails(error);
      return {
        success: false,
        error: details.message,
        ...details,
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
