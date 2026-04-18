import axios from "axios";

// Base URL for the backend API
const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || "http://localhost:5232/api";

// Create axios instance
const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    "Content-Type": "application/json",
  },
});

// Add request interceptor to include JWT token
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem("token");
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  },
);

// Auth APIs
export const authAPI = {
  register: (userData) => api.post("/Auth/Register", userData),
  login: (credentials) => api.post("/Auth/Login", credentials),
};

// Chat APIs
export const chatAPI = {
  getWelcome: () => api.get("/Chat/welcome"),
  sendMessage: (messageData) =>
    api.post("/Chat", {
      Message: messageData.message,
      SessionId: messageData.sessionId,
      Condition: messageData.condition ?? "",
      Confidence: messageData.confidence ?? 0,
    }),
};

// Diagnostic APIs
export const diagnosticAPI = {
  getNextStep: (facts) => api.post("/Diagnostic/next-step", { facts }),
  saveAnswer: (answerData) => api.post("/Diagnostic/save-answer", answerData),
};

// History APIs
export const historyAPI = {
  getDiagnostics: () => api.get("/History/diagnostics"),
  getDiagnosticDetails: (resultId) =>
    api.get(`/History/diagnostic/${resultId}`),
};

// Metadata APIs
export const metadataAPI = {
  getKnowledgeBase: () => api.get("/Metadata/knowledge-base"),
  getConfirmation: (diseaseName) =>
    api.get(`/Metadata/confirmation/${diseaseName}`),
};

export default api;
