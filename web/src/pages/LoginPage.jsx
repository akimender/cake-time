import { Link } from 'react-router-dom'
import './PlaceholderPage.css'

export default function LoginPage() {
  return (
    <div className="placeholder">
      <h1>Log in</h1>
      <p>This page will connect to the CakeTime API. Coming soon.</p>
      <Link to="/" className="placeholder-link">← Back to home</Link>
    </div>
  )
}
