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
    console.log("Token from localStorage:", token ? "present" : "null/empty");
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
      console.log("Authorization header set:", config.headers.Authorization.substring(0, 20) + "...");
    } else {
      console.log("No token found, Authorization header not set");
    }

    if (config.url?.includes("/Diagnostic/next-step")) {
      console.log("Axios diagnostic next-step request body:", config.data);
      try {
        console.log("Axios diagnostic next-step JSON:", JSON.stringify(config.data));
      } catch (e) {
        console.warn("Unable to stringify diagnostic next-step data", e);
      }
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
  getNextStep: (payload) => api.post("/Diagnostic/next-step", payload),
  saveAnswers: (answersData) => api.post("/Diagnostic/save-answers", answersData),
  getDiseaseDetails: (diseaseName) =>
    api.get(`/Diagnostic/disease-details?name=${encodeURIComponent(diseaseName)}`),
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
