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

const OngoingProjects = () => {
  const projects = [
    {
      id: 1,
      title: "Leukquant",
      desc: "A cybersecurity-based project developing an Antivirus software that goes beyond signature and AI. It analyzes and predicts malware using behavioral anomaly scoring, making it safer than traditional antivirus solutions.",
      leader: {
        name: "Rickjoe Antony J",
        role: "Team Leader",
        linkedin: "https://www.linkedin.com/in/rickjoe-antony-j-83208b37a",
        image: "/images/rickjoe.png",
        imageStyle: { objectFit: 'contain', objectPosition: 'center 75%', transform: 'scale(1.15)' },
        founderCompany: "Leukquant"
      },
      members: [
        { name: "Pooja Lakshmi D", role: "Quality Analyst", linkedin: "https://www.linkedin.com/in/pooja-dhayalan-3775a6379", image: "/images/pooja.png" },
        { name: "Rahul Karthikeyan T", role: "Developer", linkedin: "https://www.linkedin.com/in/ragul-karthikeyan-t-7948633b6", image: "/images/rahul.png" },
        { name: "Shanmugam A", role: "UI/UX Designer", linkedin: "https://www.linkedin.com/in/shanmugam-a-b9535a380", image: "/images/shanmugam.png" },
        { name: "Priyadarshini.s", role: "Frontend Developer", linkedin: "https://www.linkedin.com/in/priyadharshini-s-607a61327", image: "/images/priyadarshini.png" }
      ]
    },
    {
      id: 2,
      title: "Paradiz",
      desc: "Smart AquaHealth is an IoT-based system monitoring water quality in real-time using TDS, pH, and turbidity sensors connected to an ESP32. Data is cloud-analyzed for safety. Users can input symptoms via an app to predict potential water-borne diseases.",
      leader: {
        name: "Lakshmi Prabha G",
        role: "Team Leader",
        linkedin: "https://www.linkedin.com/in/lakshmiprabhag29",
        image: "/images/lakshmiprabha.png"
      },
      members: [
        { name: "Raghavi M", role: "Front-end Developer", linkedin: "https://www.linkedin.com/in/raghavi-mohan-b45010328", image: "/images/raghavi.png" },
        { name: "Thanisha Alria Paul", role: "IoT-Hardware", linkedin: "https://www.linkedin.com/in/thanisha-alria-paul-525789333", image: "/images/thanisha.png" },
        { name: "Santhosh kumar P", role: "Back-end Developer", linkedin: "https://www.linkedin.com/in/santhosh-kumar-p-763934305", image: "/images/santhosh.png" }
      ]
    },
    {
      id: 3,
      title: "Tech Frontiers",
      desc: "Automated Documentation System with Time Tracking and Productivity Analysis. A software project automating document creation while tracking user activity to calculate productivity scores. Features include auth, attendance, APIs, DB, and dashboard integration.",
      leader: {
        name: "S.karthikeyan",
        role: "Team Leader",
        linkedin: "https://www.linkedin.com/in/karthikeyan-s-45a821364",
        image: "/images/karthikeyan.png"
      },
      members: [
        { name: "Vaishnavi.S", role: "Front-end Developer", linkedin: "https://www.linkedin.com/in/vaishnavi-s-18a363396", image: "/images/vaishnavi.png" },
        { name: "Vijayalakshmi.S", role: "Front-end Developer", linkedin: "https://www.linkedin.com/in/vijayalakshmi-s-987664328", image: "/images/vijayalakshmi.png" },
        { name: "Bharath", role: "Backend Developer", linkedin: "https://www.linkedin.com/in/bharath-kothandan-767186327", image: "/images/bharath.png" },
        { name: "Thriya .S", role: "Database Administrator", linkedin: "https://www.linkedin.com/in/thriya-senthil-24924a328", image: "/images/thriya.png" }
      ]
    }
  ];

  return (
    <div className="futuristic-container fade-in">
      <h1 className="futuristic-title">Ongoing Projects</h1>

      <div className="projects-grid">
        {projects.map(project => (
          <div key={project.id} className="glass-panel project-section">
            <div className="project-header">
              <h2 className="project-title">{project.title}</h2>
              <p className="project-desc">{project.desc}</p>
            </div>

            <div className="tree-container">
              {/* Leader Level */}
              <div className="tree-level level-1">
                <div className="tree-node has-children" style={{ zIndex: 1 }}>
                  <TreeNodeCard
                    name={project.leader.name}
                    role={project.leader.role}
                    linkedin={project.leader.linkedin}
                    image={project.leader.image}
                    imageStyle={project.leader.imageStyle}
                    founderCompany={project.leader.founderCompany}
                  />
                </div>
              </div>

              {/* Members Level */}
              <div className="tree-level">
                {project.members.length > 1 && (
                  <div className="tree-sibling-connector" style={{ width: 'calc(100% - var(--tree-card-width))', top: '0' }}></div>
                )}
                {project.members.map((member, i) => (
                  <div key={i} className="tree-node" style={{ zIndex: 1 }}>
                    <TreeNodeCard
                      name={member.name}
                      role={member.role}
                      linkedin={member.linkedin}
                      image={member.image}
                      imageStyle={member.imageStyle}
                    />
                  </div>
                ))}
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

export default OngoingProjects;
