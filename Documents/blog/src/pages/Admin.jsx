import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { PenLine, Save, Tags, Image, FileText, User, Lock, LogOut, ShieldCheck, Trash2 } from 'lucide-react';
import { savePost, getPosts, deletePost } from '../utils/storage';
import './Admin.css';

const ADMIN_ID = 'industry5admin';
const ADMIN_PASS = 'ClubAccess2026!';

const Admin = () => {
  const navigate = useNavigate();
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [loginForm, setLoginForm] = useState({ userid: '', password: '' });
  const [loginError, setLoginError] = useState('');
  const [formData, setFormData] = useState({ title: '', author: 'System Admin', tags: '', imageUrl: '', content: '' });
  const [posts, setPosts] = useState([]);

  useEffect(() => {
    if (localStorage.getItem('clubIndustryAdminAuth') === 'true') {
      setIsAuthenticated(true);
      setPosts(getPosts());
    }
  }, []);

  const handleLogin = (e) => {
    e.preventDefault();
    if (loginForm.userid === ADMIN_ID && loginForm.password === ADMIN_PASS) {
      localStorage.setItem('clubIndustryAdminAuth', 'true');
      setIsAuthenticated(true);
      setPosts(getPosts());
    } else {
      setLoginError('Invalid credentials. Please try again.');
    }
  };

  const handleLogout = () => {
    localStorage.removeItem('clubIndustryAdminAuth');
    setIsAuthenticated(false);
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    const tags = formData.tags.split(',').map(t => t.trim()).filter(Boolean);
    savePost({ ...formData, tags: tags.length ? tags : ['General'] });
    navigate('/');
  };

  const handleDeletePost = (id) => {
    if (window.confirm("Are you sure you want to permanently delete this post?")) {
      deletePost(id);
      setPosts(getPosts());
    }
  };

  if (!isAuthenticated) {
    return (
      <div className="admin-page login-view">
        <div className="page-header">
          <div className="page-eyebrow"><Lock size={14} /> Secure Admin Access</div>
          <h1 className="page-title">Security <span>Gateway</span></h1>
          <p className="page-sub">Enter your credentials to access the admin dashboard.</p>
          <div className="header-divider"></div>
        </div>

        <div className="form-card">
          <form onSubmit={handleLogin}>
            {loginError && <div className="error-message">{loginError}</div>}
            <div className="field">
              <label htmlFor="userid"><User size={14} /> User ID</label>
              <input id="userid" type="text" placeholder="Enter user ID" value={loginForm.userid}
                onChange={e => setLoginForm(p => ({ ...p, userid: e.target.value }))} required />
            </div>
            <div className="field">
              <label htmlFor="password"><Lock size={14} /> Passphrase</label>
              <input id="password" type="password" placeholder="Enter password" value={loginForm.password}
                onChange={e => setLoginForm(p => ({ ...p, password: e.target.value }))} required />
            </div>
            <div className="form-actions">
              <button type="submit" className="btn btn-primary"><ShieldCheck size={16} /> Authenticate</button>
            </div>
          </form>
        </div>
      </div>
    );
  }

  return (
    <div className="admin-page">
      <div className="page-header">
        <div className="header-row">
          <div>
            <div className="page-eyebrow"><PenLine size={14} /> Admin Portal</div>
            <h1 className="page-title">New <span>Transmission</span></h1>
            <p className="page-sub">Craft and publish your blog post to the mainframe.</p>
          </div>
          <button onClick={handleLogout} className="btn btn-danger"><LogOut size={15} /> Log Out</button>
        </div>
        <div className="header-divider"></div>
      </div>

      <div className="form-card">
        <form onSubmit={handleSubmit}>
          <div className="field">
            <label htmlFor="title"><FileText size={14} /> Post Title</label>
            <input id="title" name="title" type="text" placeholder="Enter a compelling title…" required
              value={formData.title} onChange={e => setFormData(p => ({ ...p, title: e.target.value }))} />
          </div>
          <div className="field-row">
            <div className="field">
              <label htmlFor="author"><User size={14} /> Author</label>
              <input id="author" name="author" type="text" required
                value={formData.author} onChange={e => setFormData(p => ({ ...p, author: e.target.value }))} />
            </div>
            <div className="field">
              <label htmlFor="tags"><Tags size={14} /> Tags (comma separated)</label>
              <input id="tags" name="tags" type="text" placeholder="AI, Robotics, Future…"
                value={formData.tags} onChange={e => setFormData(p => ({ ...p, tags: e.target.value }))} />
            </div>
          </div>
          <div className="field">
            <label htmlFor="imageUrl"><Image size={14} /> Cover Image URL</label>
            <input id="imageUrl" name="imageUrl" type="url" placeholder="https://…"
              value={formData.imageUrl} onChange={e => setFormData(p => ({ ...p, imageUrl: e.target.value }))} />
          </div>
          <div className="field">
            <label htmlFor="content"><FileText size={14} /> Content</label>
            <textarea id="content" name="content" placeholder="Write your post here…" required
              value={formData.content} onChange={e => setFormData(p => ({ ...p, content: e.target.value }))} />
          </div>
          <div className="form-actions">
            <button type="submit" className="btn btn-primary"><Save size={16} /> Publish Post</button>
          </div>
        </form>
      </div>

      <div className="form-card" style={{ marginTop: '2rem' }}>
        <h3 style={{ color: '#fff', borderBottom: '1px solid rgba(255,255,255,0.1)', paddingBottom: '0.8rem', marginBottom: '1rem' }}>Manage Posts</h3>
        {posts.length === 0 ? (
          <p style={{ color: '#94A3B8' }}>No posts published yet.</p>
        ) : (
          <div className="admin-posts-list">
            {posts.map(post => (
              <div key={post.id} style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '1rem', background: 'rgba(255,255,255,0.05)', borderRadius: '8px', marginBottom: '0.8rem', border: '1px solid rgba(255,255,255,0.05)' }}>
                <div>
                  <h4 style={{ color: '#fff', margin: '0 0 0.4rem 0', fontSize: '1.1rem' }}>{post.title}</h4>
                  <p style={{ color: '#94A3B8', fontSize: '0.85rem', margin: 0 }}>By {post.author} • {new Date(post.createdAt).toLocaleDateString()}</p>
                </div>
                <button onClick={() => handleDeletePost(post.id)} className="btn btn-danger" style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', padding: '0.5rem 1rem' }}>
                  <Trash2 size={14} /> Remove
                </button>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
};

export default Admin;
