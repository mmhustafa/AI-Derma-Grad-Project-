import Navbar from '../components/Navbar';
import Footer from '../components/Footer';
import '../assets/styles/profile.css';
import '../assets/styles/components.css';

export default function ProfilePage() {
  return (
    <div className="profile-page">
      <Navbar />

      <main className="profile-body">
        <div className="profile-card">
          <div className="profile-avatar" aria-hidden="true">YJ</div>
          <div>
            <div className="profile-name">Yousef</div>
            <div className="profile-meta">Clinical portal account • Privacy lock enabled</div>
          </div>

          <div className="divider" style={{ margin: '18px 0' }} />

          <div className="profile-grid">
            <div className="profile-item">
              <div className="profile-item-label">Email</div>
              <div className="profile-item-value">yousef@example.com</div>
            </div>
            <div className="profile-item">
              <div className="profile-item-label">Role</div>
              <div className="profile-item-value">Patient</div>
            </div>
            <div className="profile-item">
              <div className="profile-item-label">Plan</div>
              <div className="profile-item-value">Clinical Sanctuary</div>
            </div>
            <div className="profile-item">
              <div className="profile-item-label">Status</div>
              <div className="profile-item-value">
                <span className="badge badge-success">Active</span>
              </div>
            </div>
          </div>
        </div>
      </main>

      <Footer />
    </div>
  );
}

