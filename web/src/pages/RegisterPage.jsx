import { Link } from 'react-router-dom'
import './PlaceholderPage.css'

export default function RegisterPage() {
  return (
    <div className="placeholder">
      <h1>Get started</h1>
      <p>Registration will connect to the CakeTime API. Coming soon.</p>
      <Link to="/" className="placeholder-link">← Back to home</Link>
    </div>
  )
}
