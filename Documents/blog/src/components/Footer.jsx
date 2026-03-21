import { Github, Twitter, Linkedin } from 'lucide-react';
import './Footer.css';

const Footer = () => (
  <footer className="footer">
    <div className="container">
      <div className="footer-main">
        <div className="footer-brand">
          <div className="footer-logo">
            <img src="/industry-5-logo.jpg" alt="Club Industry 5.0" />
            <div className="footer-logo-name">Club Industry 5.0</div>
          </div>
          <p className="footer-desc">
            Pioneering the cyber-physical frontier at Jeppiaar Institute of Technology together with IEEE Computer Society.
          </p>
          <div className="footer-badges">
            <div className="badge"><div className="badge-dot"></div>IEEE Computer Society</div>
            <div className="badge"><div className="badge-dot"></div>Jeppiaar Institute of Technology</div>
          </div>
        </div>

        <div className="footer-col">
          <h4>Navigate</h4>
          <a href="/" className="footer-link">Home</a>
          <a href="/admin" className="footer-link">Admin Portal</a>
        </div>

        <div className="footer-col">
          <h4>Topics</h4>
          <a href="#" className="footer-link">AI & Automation</a>
          <a href="#" className="footer-link">Robotics</a>
          <a href="#" className="footer-link">Sustainability</a>
        </div>

        <div className="footer-col">
          <h4>Connect</h4>
          <div className="social-links">
            <a href="#" className="social-btn"><Github size={17} /></a>
            <a href="#" className="social-btn"><Twitter size={17} /></a>
            <a href="#" className="social-btn"><Linkedin size={17} /></a>
          </div>
        </div>
      </div>

      <div className="footer-bottom">
        <div className="status-dot">
          <div className="ping-wrap"><div className="ping-core"></div><div className="ping-wave"></div></div>
          System Online
        </div>
        <span>&copy; 2026 Club Industry 5.0 · All rights reserved.</span>
      </div>
    </div>
  </footer>
);

export default Footer;
