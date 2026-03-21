import React, { useRef, useState } from 'react';
import '../components/FuturisticPages.css';

import { Linkedin } from 'lucide-react';

const TreeNodeCard = ({ name, role, desc, linkedin, image, imageStyle, founderCompany }) => {
  const imgUrl = image || `https://api.dicebear.com/7.x/adventurer/svg?seed=${encodeURIComponent(name)}&backgroundColor=transparent`;
  const [transformStyle, setTransformStyle] = useState('');
  const cardRef = useRef(null);

  const handleMouseMove = (e) => {
    if (!cardRef.current) return;
    const rect = cardRef.current.getBoundingClientRect();
    const x = e.clientX - rect.left;
    const y = e.clientY - rect.top;
    const centerX = rect.width / 2;
    const centerY = rect.height / 2;
    const rotateX = ((y - centerY) / centerY) * -12;
    const rotateY = ((x - centerX) / centerX) * 12;
    setTransformStyle(`perspective(1000px) rotateX(${rotateX}deg) rotateY(${rotateY}deg) scale3d(1.03, 1.03, 1.03) translateZ(10px)`);
  };

  const handleMouseLeave = () => {
    setTransformStyle('');
  };

  return (
    <a
      href={linkedin}
      target="_blank"
      rel="noopener noreferrer"
      className={`futuristic-card portrait-card ${founderCompany ? 'founder-card' : ''}`}
      ref={cardRef}
      onMouseMove={handleMouseMove}
      onMouseLeave={handleMouseLeave}
      style={{
        transform: transformStyle || undefined,
        transition: transformStyle ? 'transform 0.1s ease-out' : 'all 0.5s cubic-bezier(0.16, 1, 0.3, 1)'
      }}
    >
      <div className="card-top-info">
        <h3 className="card-name">{name.toUpperCase()}</h3>
        <p className="card-role">{role}</p>
      </div>

      <div className="card-image-wrapper">
        {founderCompany && <div className="founder-badge">FOUNDER • {founderCompany.toUpperCase()}</div>}
        <img src={imgUrl} alt={name} className="person-image" style={imageStyle} />
      </div>

      <div className="linkedin-overlay">
        <div className="linkedin-header">
          <Linkedin color="#0a66c2" size={32} />
          <span>LinkedIn ID</span>
        </div>
        <div className="linkedin-content">
          <h4 className="overlay-name">{name}</h4>
          <p className="overlay-role">{role}</p>
          {desc && <p className="card-desc">{desc}</p>}
          <div className="view-profile-btn">View Profile</div>
        </div>
      </div>
    </a>
  );
};

const ClubOfficials = () => {
  return (
    <div className="futuristic-container fade-in">
      <h1 className="futuristic-title">Club Officials</h1>

      <div className="tree-container">

        {/* LEVEL 1: Staff Coordinators */}
        <div className="tree-level level-1 has-children-center">
          <div className="tree-sibling-connector" style={{ width: 'calc(100% - var(--tree-card-width))', top: '2rem' }}></div>
          <div className="tree-node" style={{ zIndex: 1, marginTop: '2rem' }}>
            <TreeNodeCard
              name="Mrs. E. Yuvabharathi"
              role="JIT IEEE CS Advisor & AP-IT"
              linkedin="#"
              image="/images/yuvabharathi.png"
            />
          </div>
          <div className="tree-node" style={{ zIndex: 1, marginTop: '2rem' }}>
            <TreeNodeCard
              name="Mrs. R. Ruthshobitha"
              role="JIT IEEE CS Mentor & AP-IT"
              linkedin="#"
              image="/images/ruthshobitha.png"
            />
          </div>
          <div className="tree-node" style={{ zIndex: 1, marginTop: '2rem' }}>
            <TreeNodeCard
              name="Mrs. M. Surudhi"
              role="JIT IEEE CS Counsellor & AP-IT"
              linkedin="#"
              image="/images/surudhi.png"
            />
          </div>
        </div>

        {/* Level 2: Chairperson */}
        <div className="tree-level level-2">
          <div className="tree-node has-children" style={{ zIndex: 1 }}>
            <TreeNodeCard
              name="Vishnu Prasad A"
              role="Chairperson"
              desc="Founder at Crewplay"
              linkedin="https://www.linkedin.com/in/vishnuprasad-sde"
              image="/images/vishnu.png"
              imageStyle={{ objectFit: 'contain', objectPosition: 'center center', transform: 'scale(1.4)' }}
              founderCompany="Crewplay"
            />
          </div>
        </div>

        {/* Level 3: Secretary */}
        <div className="tree-level level-3">
          <div className="tree-node has-children" style={{ zIndex: 1 }}>
            <TreeNodeCard
              name="Rickjoe Antony J"
              role="Secretary"
              desc="Founder at Leukquant"
              linkedin="https://www.linkedin.com/in/rickjoe-antony-j-83208b37a"
              image="/images/rickjoe.png"
              imageStyle={{ objectFit: 'contain', objectPosition: 'center 75%', transform: 'scale(1.15)' }}
              founderCompany="Leukquant"
            />
          </div>
        </div>

        {/* Level 4: Core Committee */}
        <div className="tree-level level-4">
          <div className="tree-sibling-connector" style={{ width: 'calc(100% - var(--tree-card-width))', top: '0' }}></div>
          <div className="tree-node" style={{ zIndex: 1 }}>
            <TreeNodeCard
              name="Thriya .S"
              role="Social Media Handling"
              linkedin="https://www.linkedin.com/in/thriya-senthil-24924a328"
              image="/images/thriya.png"
            />
          </div>
          <div className="tree-node" style={{ zIndex: 1 }}>
            <TreeNodeCard
              name="Lakshmi Prabha G"
              role="Member Development Committee"
              linkedin="https://www.linkedin.com/in/lakshmiprabhag29"
              image="/images/lakshmiprabha.png"
            />
          </div>
          <div className="tree-node" style={{ zIndex: 1 }}>
            <TreeNodeCard
              name="Shanmugam A"
              role="Design Head"
              linkedin="https://www.linkedin.com/in/shanmugam-a-b9535a380"
              image="/images/shanmugam.png"
            />
          </div>
          <div className="tree-node" style={{ zIndex: 1 }}>
            <TreeNodeCard
              name="Rahul Karthikeyan.T"
              role="Tech Admin"
              linkedin="https://www.linkedin.com/in/ragul-karthikeyan-t-7948633b6"
              image="/images/rahul.png"
            />
          </div>
        </div>

      </div>
    </div>
  );
};

export default ClubOfficials;
