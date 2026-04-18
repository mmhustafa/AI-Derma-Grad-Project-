import { BrowserRouter, Routes, Route, Navigate } from "react-router-dom";
import { AuthProvider } from "./contexts/AuthContext";
import HomePage from "./pages/HomePage";
import LoginPage from "./pages/LoginPage";
import RegisterPage from "./pages/RegisterPage";
import SymptomPage from "./pages/SymptomPage";
import UploadPage from "./pages/UploadPage";
import AssessmentResultPage from "./pages/AssessmentResultPage";
import ClinicalAssistantPage from "./pages/ClinicalAssistantPage";
import HistoryPage from "./pages/HistoryPage";
import ProfilePage from "./pages/ProfilePage";

export default function App() {
  return (
    <AuthProvider>
      <BrowserRouter>
        <Routes>
          <Route path="/" element={<HomePage />} />
          <Route path="/login" element={<LoginPage />} />
          <Route path="/register" element={<RegisterPage />} />
          <Route path="/assess" element={<SymptomPage />} />
          <Route path="/upload" element={<UploadPage />} />
          <Route path="/result" element={<AssessmentResultPage />} />
          <Route path="/assistant" element={<ClinicalAssistantPage />} />
          <Route path="/history" element={<HistoryPage />} />
          <Route path="/profile" element={<ProfilePage />} />

          {/* 404 fallback */}
          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </BrowserRouter>
    </AuthProvider>
  );
}
