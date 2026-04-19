import api from "./api";

/**
 * History Service - Handles all history-related API calls
 */
export const historyService = {
  /**
   * Fetch all diagnostic history for the logged-in user
   * @returns {Promise<Array>} Array of diagnostic records
   */
  getDiagnostics: async () => {
    try {
      const response = await api.get("/History/diagnostics");
      return response.data || [];
    } catch (error) {
      // For now, don't auto-redirect on 401 - let the component handle it
      // This prevents redirect loops after successful login
      throw error; // Re-throw the error for the component to handle
    }
  },

  /**
   * Fetch details of a specific diagnostic result
   * @param {string} resultId - The diagnostic result ID
   * @returns {Promise<Object>} Detailed diagnostic record
   */
  getDiagnosticDetails: async (resultId) => {
    try {
      const response = await api.get(`/History/diagnostic/${resultId}`);
      return response.data;
    } catch (error) {
      if (error.response?.status === 401) {
        throw new Error("Authentication required. Please log in again.");
      }
      throw new Error(error.response?.data?.message || "Failed to fetch diagnostic details");
    }
  },
};

export default historyService;
