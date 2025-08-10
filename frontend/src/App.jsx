import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { useState } from 'react';
import './App.css';

// Pages
import LandingPage from './pages/LandingPage';
import HomePage from './pages/HomePage';

// Components
import Dashboard from './components/Dashboard';

function App() {
  const [isAuthenticated, setIsAuthenticated] = useState(true);

  return (
    <Router>
      <div className="App">
        {isAuthenticated && <Dashboard />}
        <main className={isAuthenticated ? 'main-with-dashboard' : 'main-full'}>
          <Routes>
            <Route 
              path="/" 
              element={
                isAuthenticated ? 
                <Navigate to="/home" replace /> : 
                <LandingPage />
              } 
            />
            <Route 
              path="/home" 
              element={
                <HomePage user={user} />
              } 
            />
          </Routes>
        </main>
      </div>
    </Router>
  );
}

export default App;
