import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import Navbar from '../components/Navbar';
import Footer from '../components/Footer';
import { diagnosticAPI } from '../services/api';
import '../assets/styles/symptom.css';
import '../assets/styles/components.css';

export default function SymptomPage() {
  const navigate = useNavigate();
  const [facts, setFacts] = useState([]);
  const [selected, setSelected] = useState('');
  const [question, setQuestion] = useState(null);
  const [diagnosis, setDiagnosis] = useState(null);
  const [resultId, setResultId] = useState(0);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  // Check authentication status
  useEffect(() => {
    const token = localStorage.getItem('token');
    console.log('SymptomPage - Token in localStorage:', token ? 'present' : 'null/empty');
    if (!token) {
      console.log('No token found, user might not be logged in');
    }
  }, []);

  const fetchNextStep = async (nextFacts, diagnosticResultId = 0) => {
    setLoading(true);
    setError('');

    const payload = { facts: nextFacts, diagnosticResultId };
    console.log('Diagnostic next-step payload:', payload);

    try {
      const response = await diagnosticAPI.getNextStep(payload);
      const data = response.data;
      const responseType = data.Type || data.type;
      const questionCode = data.QuestionCode || data.questionCode;
      const questionData = data.QuestionData || data.questionData;
      const disease = data.Disease || data.disease;
      const nextResultId = data.DiagnosticResultId ?? data.diagnosticResultId ?? diagnosticResultId ?? 0;

      if (responseType === 'question') {
        setQuestion({
          code: questionCode,
          ...questionData,
        });
        setDiagnosis(null);
        setResultId(nextResultId);
      } else if (responseType === 'diagnosis') {
        const diseaseName = disease ?? 'Unknown';
        setDiagnosis(diseaseName);
        setQuestion(null);
        setResultId(nextResultId);
        
        // Get stored answers from session storage
        const storedAnswers = sessionStorage.getItem('diagnosticAnswers') ? JSON.parse(sessionStorage.getItem('diagnosticAnswers')) : [];
        
        navigate('/result', {
          state: {
            diseaseName,
            source: 'expert',
            diagnosticResultId: nextResultId,
            answers: storedAnswers,
          },
        });
      } else {
        setError('Unexpected response from diagnostic service.');
      }
    } catch (err) {
      setError(err.response?.data?.title || err.message || 'Failed to contact diagnostic service.');
    } finally {
      setLoading(false);
      setSelected('');
    }
  };

  useEffect(() => {
    fetchNextStep([]);
  }, []);

  const handleSelect = (val) => {
    setSelected(val);
    setError('');
  };

  const handleNext = async () => {
    if (!selected) return;

    setLoading(true);
    try {
      // Store the answer locally (will be saved in batch later)
      const questionText = renderedQuestionText;
      const selectedOption = answerOptions.find(opt => (opt.Val || opt.val) === selected);
      const answerLabel = selectedOption?.Label || selectedOption?.label || selected;

      // Store answer in sessionStorage for later batch saving
      const currentAnswers = JSON.parse(sessionStorage.getItem('diagnosticAnswers') || '[]');
      currentAnswers.push({
        questionText: questionText,
        answer: answerLabel,
      });
      sessionStorage.setItem('diagnosticAnswers', JSON.stringify(currentAnswers));

      // Fetch next step
      const nextFacts = [...facts, selected];
      await fetchNextStep(nextFacts, resultId);
      setFacts(nextFacts);
    } catch (err) {
      setError(err.response?.data?.title || err.message || 'Failed to save answer.');
      setLoading(false);
    }
  };

  const handleReset = () => {
    setFacts([]);
    setSelected('');
    setQuestion(null);
    setDiagnosis(null);
    setResultId(0);
    setError('');
    fetchNextStep([]);
  };

  const renderedQuestionText = question?.Text || question?.text || 'Loading question...';
  const answerOptions = question?.Options || question?.options || [];

  return (
    <div className="assess-page">
      <Navbar />

      <div className="assess-body">
        <div className="assess-eyebrow">Symptom Analysis</div>
        <h1 className="assess-title">Clinical Diagnostic Flow</h1>

        {loading && <div className="info-banner">Loading next diagnostic step...</div>}
        {error && <div className="error-banner">{error}</div>}

        {diagnosis ? (
          <div className="diagnosis-result-card">
            <div className="result-header">Expert System Diagnosis</div>
            <div className="result-value">{diagnosis}</div>
            <div className="result-note">This diagnosis was generated through the linked expert system.</div>
            <div className="result-actions">
              <button className="btn btn-secondary" onClick={() => navigate('/')}>Return Home</button>
              <button className="btn btn-primary" onClick={handleReset}>Restart Assessment</button>
            </div>
          </div>
        ) : (
          <div className="question-card">
            <div className="question-card-accent" />
            <div className="question-card-body">
              <h2 className="question-text">{renderedQuestionText}</h2>

              <div className="answer-options">
                {answerOptions.map((option) => (
                  <div
                    key={option.Val || option.val}
                    className={`answer-option ${selected === (option.Val || option.val) ? 'selected' : ''}`}
                    onClick={() => handleSelect(option.Val || option.val)}
                    role="button"
                    tabIndex={0}
                    onKeyDown={(e) => e.key === 'Enter' && handleSelect(option.Val || option.val)}
                    aria-pressed={selected === (option.Val || option.val)}
                  >
                    <div className={`answer-option-icon ${selected === (option.Val || option.val) ? 'yes' : 'no'}`}>
                      {selected === (option.Val || option.val) ? (
                        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5">
                          <polyline points="20 6 9 17 4 12" />
                        </svg>
                      ) : (
                        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                          <polyline points="20 6 9 17 4 12" />
                        </svg>
                      )}
                    </div>
                    <div className="answer-option-label">{option.Label || option.label}</div>
                  </div>
                ))}
              </div>

              <div className="question-card-footer">
                <button
                  className="btn-back"
                  onClick={() => navigate('/')}
                  id="symptom-back-btn"
                >
                  <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5">
                    <polyline points="15 18 9 12 15 6" />
                  </svg>
                  Home
                </button>
                <button
                  className="btn-next"
                  onClick={handleNext}
                  id="symptom-next-btn"
                  disabled={!selected || loading}
                  style={{ opacity: !selected || loading ? 0.5 : 1, cursor: !selected || loading ? 'not-allowed' : 'pointer' }}
                >
                  Continue
                  <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5">
                    <polyline points="9 18 15 12 9 6" />
                  </svg>
                </button>
              </div>
            </div>
          </div>
        )}
      </div>

      <Footer />
    </div>
  );
}
