import { useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import { register } from '../api/auth'
import './RegisterPage.css'

export default function RegisterPage() {
  const navigate = useNavigate()
  const [username, setUsername] = useState('')
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [confirmPassword, setConfirmPassword] = useState('')
  const [errors, setErrors] = useState({})
  const [submitting, setSubmitting] = useState(false)

  const handleSubmit = async (e) => {
    e.preventDefault()
    const next = {}

    if (!username.trim()) next.username = 'Required.'
    if (!password) next.password = 'Required.'
    else if (password.length < 8) next.password = 'Password must be at least 8 characters.'
    if (password !== confirmPassword) next.confirmPassword = 'Passwords do not match.'

    setErrors(next)
    if (Object.keys(next).length) return

    setSubmitting(true)
    setErrors({})
    try {
      await register({ username: username.trim(), email: email.trim() || undefined, password })
      navigate('/login', { state: { message: 'Account created. Please log in.' } })
    } catch (err) {
      const details = err.details || {}
      setErrors({
        username: details.username || (err.error && !details.password ? err.error : null),
        password: details.password || null,
      })
    } finally {
      setSubmitting(false)
    }
  }

  return (
    <div className="register-page">
      <div className="register-card">
        <Link to="/" className="register-back">← Back to home</Link>
        <h1>Create your account</h1>
        <p className="register-lead">Use your new account to log in and manage birthdays.</p>

        <form onSubmit={handleSubmit} className="register-form" noValidate>
          <label className="register-label">
            Username
            <input
              type="text"
              autoComplete="username"
              value={username}
              onChange={(e) => setUsername(e.target.value)}
              className={errors.username ? 'register-input is-invalid' : 'register-input'}
              placeholder="e.g. alex"
            />
            {errors.username && <span className="register-error">{errors.username}</span>}
          </label>

          <label className="register-label">
            Email <span className="register-optional">(optional)</span>
            <input
              type="email"
              autoComplete="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              className="register-input"
              placeholder="you@example.com"
            />
          </label>

          <label className="register-label">
            Password
            <input
              type="password"
              autoComplete="new-password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              className={errors.password ? 'register-input is-invalid' : 'register-input'}
              placeholder="At least 8 characters"
            />
            {errors.password && <span className="register-error">{errors.password}</span>}
          </label>

          <label className="register-label">
            Confirm password
            <input
              type="password"
              autoComplete="new-password"
              value={confirmPassword}
              onChange={(e) => setConfirmPassword(e.target.value)}
              className={errors.confirmPassword ? 'register-input is-invalid' : 'register-input'}
              placeholder="Same as above"
            />
            {errors.confirmPassword && <span className="register-error">{errors.confirmPassword}</span>}
          </label>

          <button type="submit" className="register-submit" disabled={submitting}>
            {submitting ? 'Creating account…' : 'Create account'}
          </button>
        </form>

        <p className="register-footer">
          Already have an account? <Link to="/login">Log in</Link>
        </p>
      </div>
    </div>
  )
}
