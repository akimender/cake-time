import { Link } from 'react-router-dom';
import './Dashboard.css';

const Dashboard = () => {
  return (
    <nav className="dashboard">
      <div className="dashboard-container">
        <div className="dashboard-brand">
          <Link to="/home" className="brand-link">
            <span className="brand-icon">🍰</span>
            <span className="brand-text">Cake Time</span>
          </Link>
        </div>

        <div className="dashboard-nav">
          <Link to="/home" className="nav-link">
            Home
          </Link>
          <Link to="/home" className="nav-link">
            My Cakes
          </Link>
          <Link to="/home" className="nav-link">
            Orders
          </Link>
        </div>
      </div>
    </nav>
  );
};

export default Dashboard;
