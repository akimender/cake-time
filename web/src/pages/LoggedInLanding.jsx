import { useAuth } from '../context/AuthContext'
import './LoggedInLanding.css'

export default function LoggedInLanding() {
  const { user, logout } = useAuth()
  const username = user?.username ?? 'there'

  return (
    <div className="logged-in-landing">
      <header className="logged-in-header">
        <div className="logged-in-brand">
          <span className="logged-in-logo">🎂</span>
          <span className="logged-in-name">CakeTime</span>
        </div>
        <nav className="logged-in-nav">
          <button type="button" onClick={logout} className="logged-in-logout">
            Log out
          </button>
        </nav>
      </header>

      <main className="logged-in-main">
        <h1 className="logged-in-title">Home</h1>
        <p className="logged-in-lead">
          Welcome, {username}. Your birthday list will go here.
        </p>
      </main>

      <footer className="logged-in-footer">
        <p>© {new Date().getFullYear()} CakeTime</p>
      </footer>
    </div>
  )
}
