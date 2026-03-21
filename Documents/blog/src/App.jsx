import { Routes, Route } from 'react-router-dom';
import { useState, useEffect } from 'react';
import Navbar from './components/Navbar';
import Footer from './components/Footer';
import Home from './pages/Home';
import Admin from './pages/Admin';
import Post from './pages/Post';
import ClubOfficials from './pages/ClubOfficials';
import OngoingProjects from './pages/OngoingProjects';

function App() {
  const [theme, setTheme] = useState('dark');

  // Global mouse tracker for parallax
  useEffect(() => {
    const handleMouseMove = (e) => {
      // Calculate normalized mouse position from -1 to 1
      const x = (e.clientX / window.innerWidth) * 2 - 1;
      const y = (e.clientY / window.innerHeight) * 2 - 1;
      document.documentElement.style.setProperty('--mouse-x', x);
      document.documentElement.style.setProperty('--mouse-y', y);
    };

    window.addEventListener('mousemove', handleMouseMove);
    return () => window.removeEventListener('mousemove', handleMouseMove);
  }, []);

  useEffect(() => {
    if (theme === 'light') document.body.classList.add('light-theme');
    else document.body.classList.remove('light-theme');
  }, [theme]);

  const toggleTheme = () => setTheme(p => p === 'dark' ? 'light' : 'dark');

  return (
    <div className="App">
      {/* Global Animated Parallax Background Layer */}
      <div className="global-parallax-bg">
        <div className="parallax-layer layer-1"></div>
        <div className="parallax-layer layer-2"></div>
        <div className="parallax-layer layer-3"></div>
      </div>
      
      <Navbar theme={theme} toggleTheme={toggleTheme} />
      <main className="container" style={{ paddingTop: '120px', paddingBottom: '60px', minHeight: '80vh' }}>
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/admin" element={<Admin />} />
          <Route path="/post/:id" element={<Post />} />
          <Route path="/officials" element={<ClubOfficials />} />
          <Route path="/projects" element={<OngoingProjects />} />
        </Routes>
      </main>
      <Footer />
    </div>
  );
}

export default App;
