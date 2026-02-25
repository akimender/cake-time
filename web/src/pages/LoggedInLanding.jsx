import { useState, useEffect } from 'react'
import { useAuth } from '../context/AuthContext'
import { listBirthdays, createBirthday, updateBirthday, deleteBirthday } from '../api/birthdays'
import './LoggedInLanding.css'

const MONTHS = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']

function formatDate(birth_month, birth_day, birth_year) {
  const month = MONTHS[Number(birth_month) - 1] || birth_month
  const day = Number(birth_day)
  if (birth_year) return `${month} ${day}, ${birth_year}`
  return `${month} ${day}`
}

function emptyForm() {
  return { name: '', birth_day: 1, birth_month: 1, birth_year: '', notes: '' }
}

function birthdayToForm(b) {
  return {
    name: b.name || '',
    birth_day: b.birth_day ?? 1,
    birth_month: b.birth_month ?? 1,
    birth_year: b.birth_year ?? '',
    notes: b.notes || '',
  }
}

export default function LoggedInLanding() {
  const { user, logout } = useAuth()
  const username = user?.username ?? 'there'

  const [birthdays, setBirthdays] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)
  const [addOpen, setAddOpen] = useState(false)
  const [editing, setEditing] = useState(null)
  const [deleting, setDeleting] = useState(null)
  const [form, setForm] = useState(emptyForm())
  const [submitError, setSubmitError] = useState(null)

  const loadBirthdays = async () => {
    setLoading(true)
    setError(null)
    try {
      const data = await listBirthdays()
      setBirthdays(data)
    } catch (err) {
      setError(err.error || 'Failed to load birthdays.')
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    loadBirthdays()
  }, [])

  const openAdd = () => {
    setForm(emptyForm())
    setSubmitError(null)
    setAddOpen(true)
  }

  const openEdit = (b) => {
    setForm(birthdayToForm(b))
    setSubmitError(null)
    setEditing(b)
  }

  const closeModals = () => {
    setAddOpen(false)
    setEditing(null)
    setDeleting(null)
    setSubmitError(null)
  }

  const handleAddSubmit = async (e) => {
    e.preventDefault()
    setSubmitError(null)
    if (!form.name.trim()) {
      setSubmitError('Name is required.')
      return
    }
    try {
      await createBirthday({
        name: form.name.trim(),
        birth_day: Number(form.birth_day),
        birth_month: Number(form.birth_month),
        birth_year: form.birth_year ? Number(form.birth_year) : null,
        notes: form.notes?.trim() || '',
      })
      closeModals()
      loadBirthdays()
    } catch (err) {
      setSubmitError(err.error || err.detail || 'Failed to create birthday.')
    }
  }

  const handleEditSubmit = async (e) => {
    e.preventDefault()
    if (!editing) return
    setSubmitError(null)
    if (!form.name.trim()) {
      setSubmitError('Name is required.')
      return
    }
    try {
      await updateBirthday(editing.id, {
        name: form.name.trim(),
        birth_day: Number(form.birth_day),
        birth_month: Number(form.birth_month),
        birth_year: form.birth_year ? Number(form.birth_year) : null,
        notes: form.notes?.trim() || '',
      })
      closeModals()
      loadBirthdays()
    } catch (err) {
      setSubmitError(err.error || err.detail || 'Failed to update birthday.')
    }
  }

  const handleDeleteConfirm = async () => {
    if (!deleting) return
    try {
      await deleteBirthday(deleting.id)
      closeModals()
      loadBirthdays()
    } catch (err) {
      setSubmitError(err.error || err.detail || 'Failed to delete.')
    }
  }

  const renderForm = (onSubmit, submitLabel) => (
    <form onSubmit={onSubmit} className="birthday-form">
      <label className="birthday-form-label">
        Name
        <input
          type="text"
          value={form.name}
          onChange={(e) => setForm((f) => ({ ...f, name: e.target.value }))}
          className="birthday-form-input"
          placeholder="Name"
          required
        />
      </label>
      <div className="birthday-form-row">
        <label className="birthday-form-label">
          Month
          <select
            value={form.birth_month}
            onChange={(e) => setForm((f) => ({ ...f, birth_month: e.target.value }))}
            className="birthday-form-input"
          >
            {MONTHS.map((m, i) => (
              <option key={m} value={i + 1}>{m}</option>
            ))}
          </select>
        </label>
        <label className="birthday-form-label">
          Day
          <input
            type="number"
            min={1}
            max={31}
            value={form.birth_day}
            onChange={(e) => setForm((f) => ({ ...f, birth_day: e.target.value }))}
            className="birthday-form-input"
          />
        </label>
        <label className="birthday-form-label">
          Year <span className="birthday-form-optional">(optional)</span>
          <input
            type="number"
            min={1900}
            max={2100}
            value={form.birth_year}
            onChange={(e) => setForm((f) => ({ ...f, birth_year: e.target.value }))}
            className="birthday-form-input"
            placeholder="e.g. 1990"
          />
        </label>
      </div>
      <label className="birthday-form-label">
        Notes <span className="birthday-form-optional">(optional)</span>
        <textarea
          value={form.notes}
          onChange={(e) => setForm((f) => ({ ...f, notes: e.target.value }))}
          className="birthday-form-input birthday-form-notes"
          placeholder="Notes"
          rows={2}
        />
      </label>
      {submitError && <p className="birthday-form-error">{submitError}</p>}
      <div className="birthday-form-actions">
        <button type="button" onClick={closeModals} className="birthday-form-btn secondary">
          Cancel
        </button>
        <button type="submit" className="birthday-form-btn primary">
          {submitLabel}
        </button>
      </div>
    </form>
  )

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
          Welcome, {username}. Manage your birthday list below.
        </p>

        <div className="birthday-toolbar">
          <button type="button" onClick={openAdd} className="birthday-add-btn">
            + Add Birthday
          </button>
        </div>

        {loading && <p className="birthday-status">Loading…</p>}
        {error && <p className="birthday-status error">{error}</p>}
        {!loading && !error && birthdays.length === 0 && (
          <p className="birthday-status">No birthdays yet. Add one above.</p>
        )}
        {!loading && !error && birthdays.length > 0 && (
          <ul className="birthday-list">
            {birthdays.map((b) => (
              <li key={b.id} className="birthday-item">
                <div className="birthday-item-main">
                  <span className="birthday-item-name">{b.name}</span>
                  <span className="birthday-item-date">
                    {formatDate(b.birth_month, b.birth_day, b.birth_year)}
                  </span>
                  {b.notes && (
                    <span className="birthday-item-notes">{b.notes}</span>
                  )}
                </div>
                <div className="birthday-item-actions">
                  <button
                    type="button"
                    onClick={() => openEdit(b)}
                    className="birthday-item-btn edit"
                  >
                    Edit
                  </button>
                  <button
                    type="button"
                    onClick={() => setDeleting(b)}
                    className="birthday-item-btn delete"
                  >
                    Delete
                  </button>
                </div>
              </li>
            ))}
          </ul>
        )}
      </main>

      {addOpen && (
        <div className="modal-overlay" onClick={closeModals}>
          <div className="modal" onClick={(e) => e.stopPropagation()}>
            <h2 className="modal-title">Add Birthday</h2>
            {renderForm(handleAddSubmit, 'Add')}
          </div>
        </div>
      )}

      {editing && (
        <div className="modal-overlay" onClick={closeModals}>
          <div className="modal" onClick={(e) => e.stopPropagation()}>
            <h2 className="modal-title">Edit Birthday</h2>
            {renderForm(handleEditSubmit, 'Save')}
          </div>
        </div>
      )}

      {deleting && (
        <div className="modal-overlay" onClick={closeModals}>
          <div className="modal modal-sm" onClick={(e) => e.stopPropagation()}>
            <h2 className="modal-title">Delete birthday?</h2>
            <p className="modal-text">
              Delete <strong>{deleting.name}</strong>? This cannot be undone.
            </p>
            {submitError && <p className="birthday-form-error">{submitError}</p>}
            <div className="birthday-form-actions">
              <button type="button" onClick={closeModals} className="birthday-form-btn secondary">
                Cancel
              </button>
              <button
                type="button"
                onClick={handleDeleteConfirm}
                className="birthday-form-btn delete"
              >
                Delete
              </button>
            </div>
          </div>
        </div>
      )}

      <footer className="logged-in-footer">
        <p>© {new Date().getFullYear()} CakeTime</p>
      </footer>
    </div>
  )
}
