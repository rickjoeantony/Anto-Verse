import { useState, useEffect, useMemo, useRef } from 'react';
import { Link } from 'react-router-dom';
import { ArrowRight, Calendar, User, BookOpen, Search, Clock, Sparkles, X } from 'lucide-react';
import { getPosts, initializeData } from '../utils/storage';
import { getReadingTime } from '../utils/reading';
import './Home.css';

const ParallaxLink = ({ to, className, children }) => {
  const ref = useRef(null);
  const [style, setStyle] = useState({});

  const handleMouseMove = (e) => {
    if (!ref.current) return;
    const rect = ref.current.getBoundingClientRect();
    const x = e.clientX - rect.left;
    const y = e.clientY - rect.top;
    const centerX = rect.width / 2;
    const centerY = rect.height / 2;
    const rotateX = ((y - centerY) / centerY) * -10;
    const rotateY = ((x - centerX) / centerX) * 10;
    setStyle({
      transform: `perspective(1000px) rotateX(${rotateX}deg) rotateY(${rotateY}deg) scale3d(1.02, 1.02, 1.02) translateZ(5px)`,
      transition: 'transform 0.1s ease-out'
    });
  };

  const handleMouseLeave = () => {
    setStyle({ transform: '', transition: 'all 0.5s ease' });
  };

  return (
    <Link to={to} className={className} ref={ref} onMouseMove={handleMouseMove} onMouseLeave={handleMouseLeave} style={style}>
      {children}
    </Link>
  );
};

const Home = () => {
  const [posts, setPosts] = useState([]);
  const [search, setSearch] = useState('');
  const [activeTag, setActiveTag] = useState('All');
  const [mousePos, setMousePos] = useState({ x: 0, y: 0 });

  const handleMouseMove = (e) => {
    const { clientX, clientY } = e;
    const x = (clientX / window.innerWidth - 0.5) * 20;
    const y = (clientY / window.innerHeight - 0.5) * 20;
    setMousePos({ x, y });
  };

  useEffect(() => {
    initializeData();
    setPosts(getPosts());
  }, []);

  // Get all unique tags
  const allTags = useMemo(() => {
    const tags = new Set();
    posts.forEach(p => p.tags?.forEach(t => tags.add(t)));
    return ['All', ...Array.from(tags)];
  }, [posts]);

  // Filter posts
  const filtered = useMemo(() => {
    return posts.filter(p => {
      const matchSearch = !search || p.title.toLowerCase().includes(search.toLowerCase()) || p.content.toLowerCase().includes(search.toLowerCase());
      const matchTag = activeTag === 'All' || p.tags?.includes(activeTag);
      return matchSearch && matchTag;
    });
  }, [posts, search, activeTag]);

  const featured = posts[0]; // Latest post is featured
  const rest = filtered.slice(filtered[0]?.id === featured?.id ? 1 : 0);
  const showFeatured = !search && activeTag === 'All' && featured;

  return (
    <div className="home-page">
      {/* HERO */}
      <section className="hero-section" onMouseMove={handleMouseMove}>
        <div className="hero-content">
          <div className="hero-eyebrow">
            <span className="eyebrow-dot"></span>
            IEEE COMPUTER SOCIETY · JEPPIAAR INSTITUTE
          </div>
          <h1 className="hero-title">
            <span className="line1">Club</span>
            <span className="line2">Industry 5.0</span>
          </h1>
          <p className="hero-desc">
            Where human ingenuity meets machine intelligence. Explore cyber-physical systems, AI frontiers, and sustainable technology.
          </p>
          <div className="hero-actions">
            <button className="btn btn-primary" onClick={() => document.getElementById('posts').scrollIntoView({ behavior: 'smooth' })}>
              Explore Posts <ArrowRight size={16} />
            </button>
            <Link to="/admin" className="btn btn-outline">Write a Post</Link>
          </div>
          <div className="hero-stats">
            <div className="stat-card"><span className="stat-num">5.0</span><div className="stat-label">INDUSTRY ERA</div></div>
            <div className="stat-card"><span className="stat-num">IEEE</span><div className="stat-label">BACKED BY</div></div>
            <div className="stat-card"><span className="stat-num">JIT</span><div className="stat-label">INSTITUTE</div></div>
          </div>
        </div>
        <div className="hero-graphic">
          <div className="hero-glow"></div>
          <div className="orbit-ring ring-a" style={{ transform: `translate(${mousePos.x * 2}px, ${mousePos.y * 2}px)` }}></div>
          <div className="orbit-ring ring-b" style={{ transform: `translate(${mousePos.x * -1}px, ${mousePos.y * -1}px)` }}></div>
          <div className="orbit-dot orbit-dot-a"></div>
          <div className="orbit-dot orbit-dot-b"></div>
          <img
            src="/industry-5-logo.jpg"
            alt="Club Industry 5.0"
            className="hero-logo-center"
            style={{ transform: `translate(${mousePos.x * 3}px, ${mousePos.y * 3}px)` }}
          />
        </div>
      </section>

      {/* SPONSORS / PARTNERS */}
      <section className="sponsors-section">
        <p className="sponsors-label">SUPPORTED & BACKED BY</p>
        <div className="sponsors-row">
          <img src="/logo-jit.png" alt="Jeppiaar Institute of Technology" className="sponsor-logo" />
          <img src="/logo-jit-ieee.png" alt="JIT IEEE Student Branch" className="sponsor-logo" />
          <img src="/logo-ieee-cs.png" alt="IEEE Computer Society" className="sponsor-logo" />
        </div>
      </section>

      {/* VISION & MISSION */}
      <section className="mission-section">
        <div className="glass-panel mission-container">
          <div className="mission-glow"></div>
          
          <div className="mission-content">
            <div className="mission-header">
              <Sparkles className="mission-icon" size={32} />
              <h2>Vision & Mission</h2>
              <div className="mission-line"></div>
            </div>
            
            <div className="mission-text">
              <p className="highlight-text">
                The Industry 5.0 Club under IEEE Computer Society aims to bridge the gap between academic learning and modern industry demands.
              </p>
              <p>
                It focuses on developing skills in human-centric technologies such as AI, IoT, cloud, and cybersecurity. The club encourages students to work on real-world, scalable, and impactful projects. It provides early industry exposure through expert talks, mentorship, and industrial visits. 
              </p>
              <p>
                Students are guided to think beyond coding and build problem-solving and innovation skills. The club promotes research, product development, and startup-oriented thinking. It also emphasizes ethical technology, data privacy, and responsible innovation.
              </p>
              <p className="highlight-text emphasis">
                Overall, the club prepares students to become future-ready engineers aligned with Industry 5.0.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* FEATURED POST */}
      {showFeatured && (
        <section className="featured-section">
          <div className="section-head">
            <div className="section-label"><Sparkles size={13} /> FEATURED</div>
            <h2 className="section-title">Top Story</h2>
            <div className="section-line"></div>
          </div>
          <ParallaxLink to={`/post/${featured.id}`} className="featured-card">
            <div className="featured-img-wrap">
              <img src={featured.imageUrl || 'https://images.unsplash.com/photo-1620712943543-bcc4688e7485?q=80&w=1965'} alt={featured.title} />
              <div className="featured-img-overlay"></div>
            </div>
            <div className="featured-body">
              <div className="post-meta">
                <span><User size={12} /> {featured.author}</span>
                <span><Calendar size={12} /> {new Date(featured.createdAt).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })}</span>
                <span><Clock size={12} /> {getReadingTime(featured.content)}</span>
              </div>
              <h3 className="featured-title">{featured.title}</h3>
              <p className="featured-excerpt">{featured.content.substring(0, 200)}...</p>
              <div className="featured-footer">
                <div className="post-tags-row">
                  {featured.tags?.slice(0, 3).map((tag, i) => <span key={i} className="tag">{tag}</span>)}
                </div>
                <div className="read-btn">Read Story <ArrowRight size={15} /></div>
              </div>
            </div>
          </ParallaxLink>
        </section>
      )}

      {/* SEARCH + POSTS */}
      <section id="posts" className="section">
        <div className="section-head">
          <div className="section-label">ALL POSTS</div>
          <h2 className="section-title">Blog</h2>
          <div className="section-line"></div>
        </div>

        {/* Search & Filter */}
        <div className="blog-controls">
          <div className="search-wrap">
            <Search size={16} className="search-icon" />
            <input
              className="search-input"
              type="text"
              placeholder="Search posts…"
              value={search}
              onChange={e => setSearch(e.target.value)}
            />
            {search && <button className="search-clear" onClick={() => setSearch('')}><X size={14} /></button>}
          </div>
          <div className="tag-filters">
            {allTags.map(tag => (
              <button key={tag} className={`tag-filter-btn ${activeTag === tag ? 'active' : ''}`} onClick={() => setActiveTag(tag)}>
                {tag}
              </button>
            ))}
          </div>
        </div>

        <div className="posts-grid">
          {filtered.map((post) => (
            <ParallaxLink to={`/post/${post.id}`} key={post.id} className="post-card">
              <div className="post-img-wrap">
                <img src={post.imageUrl || 'https://images.unsplash.com/photo-1620712943543-bcc4688e7485?q=80&w=1965'} alt={post.title} />
                <div className="post-img-overlay"></div>
              </div>
              <div className="post-body">
                <div className="post-meta">
                  <span><Calendar size={12} /> {new Date(post.createdAt).toLocaleDateString('en-US', { month: 'short', day: 'numeric' })}</span>
                  <span><Clock size={12} /> {getReadingTime(post.content)}</span>
                </div>
                <h3 className="post-title">{post.title}</h3>
                <p className="post-excerpt">{post.content.substring(0, 120)}...</p>
                <div className="post-footer-row">
                  <div className="post-tags-row">
                    {post.tags?.slice(0, 2).map((tag, i) => <span key={i} className="tag">{tag}</span>)}
                  </div>
                  <div className="read-btn">Read <ArrowRight size={14} /></div>
                </div>
              </div>
            </ParallaxLink>
          ))}

          {filtered.length === 0 && (
            <div className="no-posts">
              <BookOpen size={32} style={{ margin: '0 auto 12px', display: 'block', opacity: 0.3 }} />
              {search ? `No posts found for "${search}"` : 'No posts yet — be the first to write one.'}
            </div>
          )}
        </div>
      </section>
    </div>
  );
};

export default Home;
