import { useState, useEffect } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import Navbar from '../components/Navbar';
import Footer from '../components/Footer';
import { metadataAPI } from '../services/api';
import '../assets/styles/confirmation.css';
import '../assets/styles/components.css';

export default function ConfirmationQuestionsPage() {
  const navigate = useNavigate();
  const location = useLocation();
  const state = location.state || {};

  const { diseaseName = '', confidence = 0, diagnosticResultId = 0, top3 = [] } = state;

  const [questions, setQuestions] = useState([]);
  const [currentQuestionIndex, setCurrentQuestionIndex] = useState(0);
  const [answers, setAnswers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [submitting, setSubmitting] = useState(false);

  // Fetch confirmation questions on mount
  useEffect(() => {
    if (!diseaseName) {
      setError('Disease name not provided');
      setLoading(false);
      return;
    }

    const fetchQuestions = async () => {
      try {
        setLoading(true);
        setError('');
        const response = await metadataAPI.getConfirmation(diseaseName);
        const questionsList = response.data || [];
        
        if (questionsList.length === 0) {
          setError('No confirmation questions available for this diagnosis.');
        }
        setQuestions(questionsList);
      } catch (err) {
        setError(err.response?.data?.message || err.message || 'Failed to load confirmation questions');
      } finally {
        setLoading(false);
      }
    };

    fetchQuestions();
  }, [diseaseName]);

  const handleYes = () => {
    const currentQuestion = questions[currentQuestionIndex];
    const questionCode = currentQuestion?.QuestionCode || `Q${currentQuestionIndex + 1}`;
    
    setAnswers([
      ...answers,
      {
        code: questionCode,
        text: currentQuestion?.Text || '',
        answer: 'Yes',
      },
    ]);

    if (currentQuestionIndex + 1 < questions.length) {
      setCurrentQuestionIndex(currentQuestionIndex + 1);
    } else {
      // All questions answered YES - user confirmed symptoms
      navigateToResult(true);
    }
  };

  const handleNo = () => {
    // User answered NO - symptoms not confirmed
    navigateToResult(false);
  };

  const navigateToResult = async (symptomsConfirmed) => {
    setSubmitting(true);
    try {
      navigate('/result', {
        state: {
          diseaseName,
          confidence,
          source: 'ai',
          diagnosticResultId,
          top3,
          imageConfirmationRequired: false,
          userConfirmedSymptoms: symptomsConfirmed,
          confirmationAnswers: answers,
        },
      });
    } catch (err) {
      setError('Failed to navigate to result page');
      setSubmitting(false);
    }
  };

  if (loading) {
    return (
      <div className="confirmation-page">
        <Navbar />
        <div className="confirmation-body">
          <div className="info-banner">Loading confirmation questions...</div>
        </div>
        <Footer />
      </div>
    );
  }

  if (error || questions.length === 0) {
    return (
      <div className="confirmation-page">
        <Navbar />
        <div className="confirmation-body">
          <div className="error-banner">{error || 'No questions available'}</div>
          <button
            className="btn-back"
            onClick={() => navigate(-1)}
            style={{ marginTop: '20px' }}
          >
            Go Back
          </button>
        </div>
        <Footer />
      </div>
    );
  }

  const currentQuestion = questions[currentQuestionIndex];
  const progressPercent = ((currentQuestionIndex + 1) / questions.length) * 100;

  return (
    <div className="confirmation-page">
      <Navbar />

      <div className="confirmation-body">
        {/* Header */}
        <div className="confirmation-header">
          <div className="confirmation-eyebrow">Symptom Verification</div>
          <h1 className="confirmation-title">Confirm Your Symptoms</h1>
          <p className="confirmation-subtitle">
            Please answer the following questions to help confirm the diagnosis for{' '}
            <span className="diagnosis-highlight">{diseaseName}</span>
          </p>
        </div>

        {/* Confidence Display */}
        <div className="confirmation-confidence-card">
          <div className="confidence-item">
            <div className="confidence-label">AI Confidence</div>
            <div className="confidence-value">{(confidence * 100).toFixed(1)}%</div>
          </div>
          <div className="confidence-separator" />
          <div className="confidence-item">
            <div className="confidence-label">Your Answers</div>
            <div className="confidence-value">{answers.length}/{questions.length}</div>
          </div>
        </div>

        {/* Progress Bar */}
        <div className="progress-section">
          <div className="progress-label">
            Question {currentQuestionIndex + 1} of {questions.length}
          </div>
          <div className="progress-bar">
            <div className="progress-fill" style={{ width: `${progressPercent}%` }} />
          </div>
        </div>

        {/* Question Card */}
        <div className="question-card-confirmation">
          <div className="question-number">Question {currentQuestionIndex + 1}</div>
          <h2 className="question-text-confirmation">{currentQuestion?.Text || 'Loading question...'}</h2>

          {/* Yes/No Buttons */}
          <div className="confirmation-buttons">
            <button
              className="btn-yes"
              onClick={handleYes}
              disabled={submitting}
              id={`confirmation-yes-btn-${currentQuestionIndex + 1}`}
            >
              <span className="btn-icon">✓</span>
              Yes
            </button>
            <button
              className="btn-no"
              onClick={handleNo}
              disabled={submitting}
              id={`confirmation-no-btn-${currentQuestionIndex + 1}`}
            >
              <span className="btn-icon">✕</span>
              No
            </button>
          </div>

          {/* Skip Link */}
          <div className="confirmation-footer">
            <button
              className="btn-skip"
              onClick={() => navigate(-1)}
              id="confirmation-back-btn"
              disabled={submitting}
            >
              ← Back
            </button>
            <div className="confirmation-note">
              Answering "No" will skip remaining questions
            </div>
          </div>
        </div>
      </div>

      <Footer />

      {/* Styles */}
      <style>{`
        @keyframes fadeIn {
          from {
            opacity: 0;
            transform: translateY(10px);
          }
          to {
            opacity: 1;
            transform: translateY(0);
          }
        }

        .confirmation-page {
          animation: fadeIn 0.3s ease-out;
        }
      `}</style>
    </div>
  );
}
