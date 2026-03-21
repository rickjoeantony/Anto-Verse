import { useState, useEffect } from 'react';
import { useParams, Link } from 'react-router-dom';
import { ChevronLeft, Calendar, User, AlertCircle } from 'lucide-react';
import { getPostById } from '../utils/storage';
import './Post.css';

const Post = () => {
  const { id } = useParams();
  const [post, setPost] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const t = setTimeout(() => { setPost(getPostById(id)); setLoading(false); }, 400);
    return () => clearTimeout(t);
  }, [id]);

  if (loading) return (
    <div className="post-loading">
      <div className="spinner"></div>
      <span className="loading-label">Loading post…</span>
    </div>
  );

  if (!post) return (
    <div className="post-not-found">
      <AlertCircle size={48} style={{ color: 'var(--c-pink)' }} />
      <h2>Post Not Found</h2>
      <p>This post doesn't exist or may have been removed.</p>
      <Link to="/" className="btn btn-outline" style={{ marginTop: '8px' }}>
        <ChevronLeft size={16} /> Back to Home
      </Link>
    </div>
  );

  return (
    <article className="post-detail">
      <Link to="/" className="back-btn">
        <ChevronLeft size={16} /> Back to posts
      </Link>

      <div className="post-header-card">
        {post.imageUrl && (
          <div className="post-hero-img">
            <img src={post.imageUrl} alt={post.title} />
          </div>
        )}
        <div className="post-header-body">
          <div className="post-header-tags">
            {post.tags?.map((tag, i) => <span key={i} className="tag">{tag}</span>)}
          </div>
          <h1 className="post-title-big">{post.title}</h1>
          <div className="post-author-row">
            <span><User size={13} /> {post.author}</span>
            <span><Calendar size={13} /> {new Date(post.createdAt).toLocaleDateString('en-US', { month: 'long', day: 'numeric', year: 'numeric' })}</span>
          </div>
        </div>
      </div>

      <div className="post-content-card">
        <div className="post-text">
          {post.content.split('\n').filter(p => p.trim()).map((p, i) => <p key={i}>{p}</p>)}
        </div>
      </div>
    </article>
  );
};

export default Post;
