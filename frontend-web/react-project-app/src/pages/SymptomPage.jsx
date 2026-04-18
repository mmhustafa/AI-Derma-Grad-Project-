import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import Navbar from '../components/Navbar';
import Footer from '../components/Footer';
import '../assets/styles/symptom.css';
import '../assets/styles/components.css';

const QUESTIONS = [
  {
    id: 1,
    text: 'Is the affected area itchy?',
    subtext: 'Commonly associated with contact dermatitis or localized reactions.',
    insight: 'Itchiness (Pruritus) is a key diagnostic indicator for over 70% of non-infectious inflammatory skin conditions.',
    yes: 'FREQUENT SENSATION',
    no: 'NO DISCOMFORT',
  },
  {
    id: 2,
    text: 'Have you noticed any scaling or flaking?',
    subtext: 'Scaling can indicate psoriasis, eczema, or dry skin conditions.',
    insight: 'Scaling is one of the most common signs of chronic skin conditions, appearing in over 60% of dermatological cases.',
    yes: 'VISIBLE FLAKING',
    no: 'NO SCALING',
  },
  {
    id: 3,
    text: 'Is there any redness or discoloration?',
    subtext: 'Erythema (redness) can signal inflammation, allergy, or infection.',
    insight: 'Redness intensity helps clinicians differentiate between acute versus chronic skin conditions.',
    yes: 'REDNESS PRESENT',
    no: 'NO REDNESS',
  },
  {
    id: 4,
    text: 'Has the condition lasted more than 2 weeks?',
    subtext: 'Chronic conditions are defined as lasting more than 14 days.',
    insight: 'Conditions lasting over 2 weeks are 3× more likely to require clinical intervention.',
    yes: 'MORE THAN 2 WEEKS',
    no: 'LESS THAN 2 WEEKS',
  },
  {
    id: 5,
    text: 'Does the rash have defined borders?',
    subtext: 'Well-defined borders can indicate fungal infection or psoriasis.',
    insight: 'Defined lesion borders are a key feature used to distinguish psoriasis from eczema in clinical practice.',
    yes: 'CLEAR BORDERS',
    no: 'DIFFUSE SPREAD',
  },
  {
    id: 6,
    text: 'Have you had similar symptoms before?',
    subtext: 'History of recurring symptoms suggests a chronic or recurring condition.',
    insight: 'Recurrence history significantly affects treatment prognosis and diagnostic confidence.',
    yes: 'YES, RECURRING',
    no: 'FIRST OCCURRENCE',
  },
  {
    id: 7,
    text: 'Are you currently on any medication?',
    subtext: 'Drug reactions can cause a range of skin conditions.',
    insight: 'Drug-induced dermatoses account for approximately 2–3% of all skin conditions seen in clinical practice.',
    yes: 'CURRENTLY MEDICATED',
    no: 'NO MEDICATION',
  },
  {
    id: 8,
    text: 'Is the area painful to touch?',
    subtext: 'Pain upon contact may differentiate between dermatitis and nerve involvement.',
    insight: 'Pain vs itch patterns are critical in distinguishing neuropathic skin disorders from inflammatory ones.',
    yes: 'PAINFUL',
    no: 'NOT PAINFUL',
  },
];

export default function SymptomPage() {
  const navigate = useNavigate();
  const [currentIndex, setCurrentIndex] = useState(0);
  const [answers, setAnswers] = useState({});

  const question = QUESTIONS[currentIndex];
  const selected = answers[question.id];
  const progress = ((currentIndex + 1) / QUESTIONS.length) * 100;

  const handleSelect = (answer) => {
    setAnswers((prev) => ({ ...prev, [question.id]: answer }));
  };

  const handleNext = () => {
    if (currentIndex < QUESTIONS.length - 1) {
      setCurrentIndex((i) => i + 1);
    } else {
      // All answered — go to upload or results
      navigate('/result');
    }
  };

  const handleBack = () => {
    if (currentIndex > 0) setCurrentIndex((i) => i - 1);
  };

  return (
    <div className="assess-page">
      <Navbar />

      <div className="assess-body">
        {/* Header */}
        <div className="assess-eyebrow">Symptom Analysis</div>
        <h1 className="assess-title">Initial Assessment</h1>

        {/* Progress Bar */}
        <div className="progress-section">
          <div className="progress-label-row">
            <span className="progress-label">Progress</span>
            <span className="progress-step-label">Step {currentIndex + 1} of {QUESTIONS.length}</span>
          </div>
          <div className="progress-bar-track">
            <div className="progress-bar-fill" style={{ width: `${progress}%` }} />
          </div>
        </div>

        {/* Question Card */}
        <div className="question-card">
          <div className="question-card-accent" />
          <div className="question-card-body">
            <h2 className="question-text">{question.text}</h2>
            <p className="question-subtext">{question.subtext}</p>

            {/* Options */}
            <div className="answer-options">
              <div
                className={`answer-option ${selected === 'yes' ? 'selected' : ''}`}
                onClick={() => handleSelect('yes')}
                id={`answer-yes-${question.id}`}
                role="button"
                tabIndex={0}
                onKeyDown={(e) => e.key === 'Enter' && handleSelect('yes')}
                aria-pressed={selected === 'yes'}
              >
                <div className={`answer-option-icon yes`}>
                  {selected === 'yes' ? (
                    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5">
                      <polyline points="20 6 9 17 4 12" />
                    </svg>
                  ) : (
                    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                      <polyline points="20 6 9 17 4 12" />
                    </svg>
                  )}
                </div>
                <div className="answer-option-label">Yes</div>
                <div className="answer-option-sublabel">{question.yes}</div>
              </div>

              <div
                className={`answer-option ${selected === 'no' ? 'selected' : ''}`}
                onClick={() => handleSelect('no')}
                id={`answer-no-${question.id}`}
                role="button"
                tabIndex={0}
                onKeyDown={(e) => e.key === 'Enter' && handleSelect('no')}
                aria-pressed={selected === 'no'}
              >
                <div className={`answer-option-icon no`}>
                  {selected === 'no' ? (
                    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5">
                      <line x1="18" y1="6" x2="6" y2="18" /><line x1="6" y1="6" x2="18" y2="18" />
                    </svg>
                  ) : (
                    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                      <line x1="18" y1="6" x2="6" y2="18" /><line x1="6" y1="6" x2="18" y2="18" />
                    </svg>
                  )}
                </div>
                <div className="answer-option-label">No</div>
                <div className="answer-option-sublabel">{question.no}</div>
              </div>
            </div>

            {/* Navigation */}
            <div className="question-card-footer">
              <button
                className="btn-back"
                onClick={handleBack}
                disabled={currentIndex === 0}
                id="symptom-back-btn"
                style={{ opacity: currentIndex === 0 ? 0.4 : 1 }}
              >
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5">
                  <polyline points="15 18 9 12 15 6" />
                </svg>
                Back
              </button>
              <button
                className="btn-next"
                onClick={handleNext}
                id="symptom-next-btn"
                disabled={!selected}
                style={{ opacity: !selected ? 0.5 : 1, cursor: !selected ? 'not-allowed' : 'pointer' }}
              >
                {currentIndex < QUESTIONS.length - 1 ? 'Next' : 'Finish'}
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5">
                  <polyline points="9 18 15 12 9 6" />
                </svg>
              </button>
            </div>
          </div>
        </div>

        {/* Bottom Info Row */}
        <div className="assess-info-row">
          <div className="assess-insight-card">
            <div className="assess-insight-icon">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                <rect x="3" y="3" width="7" height="7" rx="1" />
                <rect x="14" y="3" width="7" height="7" rx="1" />
                <rect x="3" y="14" width="7" height="7" rx="1" />
                <path d="M14 14h7v3h-7z" />
                <path d="M14 18h7v3h-7z" />
              </svg>
            </div>
            <div>
              <div className="assess-insight-title">Clinical Insight</div>
              <p className="assess-insight-text">{question.insight}</p>
            </div>
          </div>

          <div className="privacy-lock-card">
            <div className="privacy-lock-label">Privacy Lock</div>
            <div className="privacy-lock-text">
              <svg className="privacy-lock-icon" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                <polyline points="20 6 9 17 4 12" />
              </svg>
              HIPAA Compliant
            </div>
          </div>
        </div>
      </div>

      <Footer />
    </div>
  );
}
