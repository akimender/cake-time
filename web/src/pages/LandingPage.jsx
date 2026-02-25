import { Link } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'
import LoggedInLanding from './LoggedInLanding'
import './LandingPage.css'

export default function LandingPage() {
  const { isAuthenticated } = useAuth()

  if (isAuthenticated) {
    return <LoggedInLanding />
  }

  return (
    <div className="landing">
      <header className="landing-header">
        <div className="landing-brand">
          <span className="landing-logo">🎂</span>
          <span className="landing-name">CakeTime</span>
        </div>
        <nav className="landing-nav">
          <Link to="/login" className="landing-nav-link">Log in</Link>
          <Link to="/register" className="landing-nav-cta">Get started</Link>
        </nav>
      </header>

      <main className="landing-main">
        <div className="landing-hero">
          <h1 className="landing-title">
            Never miss a birthday
          </h1>
          <p className="landing-lead">
            Track friends and family in one place. Get reminders so you’re always ready to celebrate.
          </p>
          <div className="landing-actions">
            <Link to="/register" className="landing-btn landing-btn-primary">
              Get started free
            </Link>
            <Link to="/login" className="landing-btn landing-btn-secondary">
              Log in
            </Link>
          </div>
        </div>

        <section className="landing-features">
          <div className="landing-feature">
            <span className="landing-feature-icon">📅</span>
            <h3>One place for everyone</h3>
            <p>Add birthdays and see who’s coming up next.</p>
          </div>
          <div className="landing-feature">
            <span className="landing-feature-icon">🔔</span>
            <h3>Reminders that work</h3>
            <p>We’ll nudge you in time so you can plan ahead.</p>
          </div>
          <div className="landing-feature">
            <span className="landing-feature-icon">✨</span>
            <h3>Simple and private</h3>
            <p>Your list stays yours. No clutter, no ads.</p>
          </div>
        </section>
      </main>

      <footer className="landing-footer">
        <p>© {new Date().getFullYear()} CakeTime</p>
      </footer>
    </div>
  )
}
