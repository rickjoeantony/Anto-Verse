import { useState } from 'react';
import { Link } from 'react-router-dom';
import { ShieldAlert, Sun, Moon, Menu, X } from 'lucide-react';
import './Navbar.css';

const Navbar = ({ theme, toggleTheme }) => {
  const [isOpen, setIsOpen] = useState(false);

  return (
    <nav className="navbar">
      <div className="nav-content">
        <Link to="/" className="nav-logo" onClick={() => setIsOpen(false)}>
          <img src="/industry-5-logo.jpg" alt="Club Industry 5.0" className="logo-image" />
          <span className="logo-text">Club Industry <span className="version">5.0</span></span>
        </Link>
        <div className={`nav-links ${isOpen ? 'active' : ''}`}>
          <button className="theme-toggle" onClick={toggleTheme} title="Toggle theme">
            {theme === 'dark' ? <Sun size={17} /> : <Moon size={17} />}
          </button>
          <Link to="/" className="nav-link" onClick={() => setIsOpen(false)}>Home</Link>
          <Link to="/officials" className="nav-link" onClick={() => setIsOpen(false)}>Officials</Link>
          <Link to="/projects" className="nav-link" onClick={() => setIsOpen(false)}>Projects</Link>
          <Link to="/admin" className="nav-link admin-link" onClick={() => setIsOpen(false)}>
            <ShieldAlert size={15} /> Admin
          </Link>
        </div>
        
        <button className="mobile-menu-btn" onClick={() => setIsOpen(!isOpen)}>
          {isOpen ? <X size={24} /> : <Menu size={24} />}
        </button>
      </div>
    </nav>
  );
};

export default Navbar;
