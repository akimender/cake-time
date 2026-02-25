import { getAuthHeaders } from './auth'

const API_BASE = '/api'

/**
 * Run an authenticated request. Throws with { status, ...body } on non-2xx.
 */
async function authFetch(url, options = {}) {
  const headers = getAuthHeaders()
  if (!headers) {
    throw { status: 401, error: 'Not authenticated. Please log in.' }
  }
  const res = await fetch(url, {
    ...options,
    headers: { ...headers, ...options.headers },
  })
  const data = await res.json().catch(() => ({}))
  if (!res.ok) {
    throw { status: res.status, ...data }
  }
  return data
}

/**
 * List all birthdays for the current user.
 * Returns: [{ id, name, birth_day, birth_month, birth_year, notes }, ...]
 */
export async function listBirthdays() {
  return authFetch(`${API_BASE}/birthdays/`)
}

/**
 * Create a birthday.
 * Body: { name, birth_day, birth_month, birth_year?, notes? }
 * Returns: { id, name, birth_day, birth_month, birth_year, notes }
 */
export async function createBirthday({ name, birth_day, birth_month, birth_year, notes }) {
  return authFetch(`${API_BASE}/birthdays/create/`, {
    method: 'POST',
    body: JSON.stringify({
      name,
      birth_day,
      birth_month,
      ...(birth_year != null && { birth_year }),
      ...(notes != null && { notes: notes || '' }),
    }),
  })
}

/**
 * Update a birthday.
 * Body: { name?, birth_day?, birth_month?, birth_year?, notes? }
 * Returns: { id, name, birth_day, birth_month, birth_year, notes, message }
 */
export async function updateBirthday(birthdayId, { name, birth_day, birth_month, birth_year, notes }) {
  const body = {}
  if (name !== undefined) body.name = name
  if (birth_day !== undefined) body.birth_day = birth_day
  if (birth_month !== undefined) body.birth_month = birth_month
  if (birth_year !== undefined) body.birth_year = birth_year
  if (notes !== undefined) body.notes = notes

  return authFetch(`${API_BASE}/birthdays/update/${birthdayId}/`, {
    method: 'PATCH',
    body: JSON.stringify(body),
  })
}

/**
 * Delete a birthday.
 * Returns: { message }
 */
export async function deleteBirthday(birthdayId) {
  return authFetch(`${API_BASE}/birthdays/delete/${birthdayId}/`, {
    method: 'DELETE',
  })
}
