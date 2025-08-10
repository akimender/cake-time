import { Link } from 'react-router-dom';
import './LandingPage.css';

const LandingPage = () => {
  return (
    <div className="landing-page">
      <div className="landing-hero">
        <h1>Welcome to Cake Time</h1>
        <p>Your delicious journey starts here</p>
        <div className="landing-actions">
          <Link to="/login" className="btn btn-primary">
            Login
          </Link>
          <Link to="/register" className="btn btn-secondary">
            Register
          </Link>
        </div>
      </div>
      
      <div className="landing-features">
        <div className="feature">
          <h3>🍰 Delicious Cakes</h3>
          <p>Browse our collection of mouth-watering cakes</p>
        </div>
        <div className="feature">
          <h3>📝 Easy Management</h3>
          <p>Simple CRUD operations for all your cake needs</p>
        </div>
        <div className="feature">
          <h3>🚀 Fast & Reliable</h3>
          <p>Built with modern React for the best experience</p>
        </div>
      </div>
    </div>
  );
};

export default LandingPage;
