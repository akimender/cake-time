const API_BASE = '/api'
const AUTH_STORAGE_KEY = 'cake_time_auth'

/**
 * Decode JWT payload (no verification; used for exp/username only).
 */
function parseJwt(token) {
  try {
    const base64 = token.split('.')[1].replace(/-/g, '+').replace(/_/g, '/')
    return JSON.parse(atob(base64))
  } catch {
    return null
  }
}

/**
 * Check if access token exists and is not expired (with 60s buffer).
 */
function isAccessTokenValid(accessToken) {
  if (!accessToken) return false
  const payload = parseJwt(accessToken)
  if (!payload || payload.exp == null) return false
  return Date.now() / 1000 < payload.exp - 60
}

/**
 * Get stored auth data. Returns { accessToken, refreshToken, username } or null if not logged in / expired.
 */
export function getStoredAuth() {
  try {
    const raw = localStorage.getItem(AUTH_STORAGE_KEY)
    if (!raw) return null
    const { accessToken, refreshToken, username } = JSON.parse(raw)
    if (!isAccessTokenValid(accessToken)) {
      localStorage.removeItem(AUTH_STORAGE_KEY)
      return null
    }
    return { accessToken, refreshToken, username: username || null }
  } catch {
    return null
  }
}

/**
 * Store tokens and username after login.
 */
export function setStoredAuth({ accessToken, refreshToken, username }) {
  localStorage.setItem(AUTH_STORAGE_KEY, JSON.stringify({
    accessToken,
    refreshToken,
    username: username || null,
  }))
}

/**
 * Clear stored auth (logout).
 */
export function clearStoredAuth() {
  localStorage.removeItem(AUTH_STORAGE_KEY)
}

/**
 * Register a new user account via the CakeTime API.
 */
export async function register({ username, email, password }) {
  const res = await fetch(`${API_BASE}/register/`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ username, email: email || '', password }),
  })
  const data = await res.json().catch(() => ({}))
  if (!res.ok) {
    throw { status: res.status, ...data }
  }
  return data
}

/**
 * Headers for authenticated API requests (Bearer JWT). Returns null if not logged in or token expired.
 */
export function getAuthHeaders() {
  const auth = getStoredAuth()
  if (!auth?.accessToken) return null
  return {
    'Content-Type': 'application/json',
    Authorization: `Bearer ${auth.accessToken}`,
  }
}

/**
 * Log in with username and password. Returns { access, refresh } from API and stores auth.
 */
export async function login({ username, password }) {
  const res = await fetch(`${API_BASE}/token/`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ username, password }),
  })
  const data = await res.json().catch(() => ({}))
  if (!res.ok) {
    throw { status: res.status, ...data }
  }
  setStoredAuth({
    accessToken: data.access,
    refreshToken: data.refresh,
    username,
  })
  return data
}
