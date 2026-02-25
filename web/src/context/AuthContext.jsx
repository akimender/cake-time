import { createContext, useContext, useState, useEffect } from 'react'
import { getStoredAuth, clearStoredAuth, login as apiLogin } from '../api/auth'

const AuthContext = createContext(null)

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null)

  useEffect(() => {
    setUser(getStoredAuth())
  }, [])

  const login = async (credentials) => {
    await apiLogin(credentials)
    setUser(getStoredAuth())
  }

  const logout = () => {
    clearStoredAuth()
    setUser(null)
  }

  const value = {
    user,
    isAuthenticated: user != null,
    login,
    logout,
  }

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  )
}

export function useAuth() {
  const ctx = useContext(AuthContext)
  if (!ctx) {
    throw new Error('useAuth must be used within AuthProvider')
  }
  return ctx
}
