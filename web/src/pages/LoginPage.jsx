import { useState } from 'react'
import { Link, useNavigate, useLocation } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'
import './LoginPage.css'

export default function LoginPage() {
  const navigate = useNavigate()
  const { state } = useLocation()
  const { login } = useAuth()

  const [username, setUsername] = useState('')
  const [password, setPassword] = useState('')
  const [errors, setErrors] = useState({})
  const [submitting, setSubmitting] = useState(false)

  const handleSubmit = async (e) => {
    e.preventDefault()
    const next = {}
    if (!username.trim()) next.username = 'Required.'
    if (!password) next.password = 'Required.'
    setErrors(next)
    if (Object.keys(next).length) return

    setSubmitting(true)
    setErrors({})
    try {
      await login({ username: username.trim(), password })
      navigate('/', { replace: true })
    } catch (err) {
      const details = err.details || {}
      const message = err.detail || err.error || 'Login failed.'
      setErrors({
        username: details.username || (details.non_field_errors && details.non_field_errors[0]) || message,
        password: details.password || (!details.username && !details.password ? message : null),
      })
    } finally {
      setSubmitting(false)
    }
  }

  return (
    <div className="login-page">
      <div className="login-card">
        <Link to="/" className="login-back">← Back to home</Link>
        <h1>Log in</h1>
        {state?.message && <p className="login-message">{state.message}</p>}
        <p className="login-lead">Use your CakeTime account to continue.</p>

        <form onSubmit={handleSubmit} className="login-form" noValidate>
          <label className="login-label">
            Username
            <input
              type="text"
              autoComplete="username"
              value={username}
              onChange={(e) => setUsername(e.target.value)}
              className={errors.username ? 'login-input is-invalid' : 'login-input'}
              placeholder="Your username"
            />
            {errors.username && <span className="login-error">{errors.username}</span>}
          </label>

          <label className="login-label">
            Password
            <input
              type="password"
              autoComplete="current-password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              className={errors.password ? 'login-input is-invalid' : 'login-input'}
              placeholder="Your password"
            />
            {errors.password && <span className="login-error">{errors.password}</span>}
          </label>

          <button type="submit" className="login-submit" disabled={submitting}>
            {submitting ? 'Logging in…' : 'Log in'}
          </button>
        </form>

        <p className="login-footer">
          Don’t have an account? <Link to="/register">Get started</Link>
        </p>
      </div>
    </div>
  )
}
