import React, { useState, useEffect } from 'react';
import { BrowserRouter as Router, Routes, Route, useLocation } from 'react-router-dom';
import { motion, AnimatePresence } from 'framer-motion';

import Navbar from './components/Navbar';
import StatusWindow from './components/StatusWindow';
import QuestLog from './components/QuestLog';
import SkillList from './components/SkillList';
import InventoryList from './components/InventoryList';
import InteractiveHero from './components/InteractiveHero';
import QuestCompletionCelebration from './components/QuestCompletionCelebration';
import DeepQuestOverlay from './components/DeepQuestOverlay';
import BootSequence from './components/BootSequence';
import DailyBriefing from './components/DailyBriefing';

const API_BASE = 'http://127.0.0.1:8000/api';

const AnimatedRoutes = ({ user, tasks, skills, inventory, handleCompleteTask, handleCreateTask, handleUpdateTask, handleResetTask, handleDeleteTask, handleAssignStat, handleUpdateProfile, handleCastSkill, handleStartDeepQuest, clearCompletionAndRefresh, handleSystemReset }) => {
  const location = useLocation();

  const pageVariants = {
    initial: {
      opacity: 0,
      scale: 0.95,
      filter: "blur(20px)",
      y: 20
    },
    in: {
      opacity: 1,
      scale: 1,
      filter: "blur(0px)",
      y: 0
    },
    out: {
      opacity: 0,
      scale: 1.05,
      filter: "blur(20px)",
      y: -20
    }
  };

  const pageTransition = {
    type: "spring",
    stiffness: 150,
    damping: 20
  };
  
  return (
    <AnimatePresence mode="wait">
      <Routes location={location} key={location.pathname}>
        <Route path="/" element={
          <motion.div
            initial="initial"
            animate="in"
            exit="out"
            variants={pageVariants}
            transition={pageTransition}
          >
            <StatusWindow user={user} onAssignStat={handleAssignStat} onUpdateProfile={handleUpdateProfile} onSystemReset={handleSystemReset} />
          </motion.div>
        } />
        <Route path="/quests" element={
          <motion.div
            initial="initial"
            animate="in"
            exit="out"
            variants={pageVariants}
            transition={pageTransition}
          >
            <QuestLog 
              tasks={tasks} 
              onCompleteTask={handleCompleteTask} 
              onCreateTask={handleCreateTask} 
              onUpdateTask={handleUpdateTask}
              onResetTask={handleResetTask}
              onDeleteTask={handleDeleteTask}
              onStartDeepQuest={handleStartDeepQuest}
            />
          </motion.div>
        } />
        <Route path="/inventory" element={
          <motion.div
            initial="initial"
            animate="in"
            exit="out"
            variants={pageVariants}
            transition={pageTransition}
          >
            <InventoryList items={inventory} />
          </motion.div>
        } />
        <Route path="/skills" element={
          <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, scale: 0.95 }} transition={{ duration: 0.3 }}>
            <SkillList skills={skills} onCastSkill={handleCastSkill} userMp={user?.mp || 0} />
          </motion.div>
        } />
      </Routes>
    </AnimatePresence>
  );
};

function App() {
  const [user, setUser] = useState(null);
  const [tasks, setTasks] = useState([]);
  const [skills, setSkills] = useState([]);
  const [inventory, setInventory] = useState([]);
  const [loading, setLoading] = useState(true);
  const [notification, setNotification] = useState(null);
  
  const [completionResult, setCompletionResult] = useState(null);
  const [activeDeepQuest, setActiveDeepQuest] = useState(null);
  const [showBoot, setShowBoot] = useState(true);
  const [briefingComplete, setBriefingComplete] = useState(false);

  const fetchAllData = async () => {
    try {
      setLoading(true);
      const [userRes, tasksRes, skillsRes, invRes] = await Promise.all([
        fetch(`${API_BASE}/user`),
        fetch(`${API_BASE}/tasks`),
        fetch(`${API_BASE}/skills`),
        fetch(`${API_BASE}/inventory`)
      ]);
      const userData = await userRes.json();
      const tasksData = await tasksRes.json();
      const skillsData = await skillsRes.json();
      const invData = await invRes.json();
      setUser(userData);
      setTasks(tasksData);
      setSkills(skillsData);
      setInventory(invData);
    } catch (err) {
      console.error("Failed to fetch:", err);
      showNotification("SYSTEM ERROR: Cannot connect to server.");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchAllData();
  }, []);

  const showNotification = (msg) => {
    setNotification(msg);
    setTimeout(() => setNotification(null), 3000);
  };

  const clearCompletionAndRefresh = () => {
    setCompletionResult(null);
    fetchAllData();
  };

  const handleSystemReset = async () => {
    try {
      const res = await fetch(`${API_BASE}/system/reset`, { method: 'POST' });
      if (res.ok) {
        setShowBoot(true);
        setBriefingComplete(false);
        await fetchAllData();
        showNotification("SYSTEM REBOOT INITIATED");
      }
    } catch (err) {
      console.error(err);
      showNotification("SYSTEM ERROR: Failed to reset.");
    }
  };

  const handleAssignStat = async (statName) => {
    try {
      const res = await fetch(`${API_BASE}/user/assign_stats`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ [statName]: 1 })
      });
      if (res.ok) {
        const updatedUser = await res.json();
        setUser(updatedUser);
        showNotification(`Stat point assigned to ${statName.toUpperCase()}`);
      }
    } catch (err) {
        showNotification("SYSTEM ERROR: Failed to assign stat.");
    }
  };

  const handleUpdateProfile = async (profileData) => {
    try {
      const res = await fetch(`${API_BASE}/user/profile`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(profileData)
      });
      if (res.ok) {
        const updatedUser = await res.json();
        setUser(updatedUser);
        showNotification("Profile updated successfully.");
      }
    } catch (err) {
        showNotification("SYSTEM ERROR: Failed to update profile.");
    }
  };

  const handleCreateTask = async (taskData) => {
    try {
      const res = await fetch(`${API_BASE}/tasks`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(taskData)
      });
      if (res.ok) {
        await fetchAllData();
        showNotification("New Quest Registered.");
      }
    } catch (err) {
        showNotification("SYSTEM ERROR: Failed to create quest.");
    }
  };

  const handleUpdateTask = async (taskId, taskData) => {
    try {
      const res = await fetch(`${API_BASE}/tasks/${taskId}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(taskData)
      });
      if (res.ok) {
        await fetchAllData();
        showNotification("Quest Updated.");
      }
    } catch (err) {
      showNotification("SYSTEM ERROR: Failed to update quest.");
    }
  };

  const handleResetTask = async (taskId) => {
    try {
      const res = await fetch(`${API_BASE}/tasks/${taskId}/reset`, { method: 'POST' });
      if (res.ok) {
        await fetchAllData();
        showNotification("Quest Reset.");
      } else {
        showNotification("Failed to reset quest.");
      }
    } catch (err) {
      showNotification("SYSTEM ERROR: Failed to reset quest.");
    }
  };

  const handleDeleteTask = async (taskId) => {
    try {
      const res = await fetch(`${API_BASE}/tasks/${taskId}`, { method: 'DELETE' });
      if (res.ok) {
        await fetchAllData();
        showNotification("Quest Removed.");
      } else {
        showNotification("Failed to delete quest.");
      }
    } catch (err) {
      showNotification("SYSTEM ERROR: Failed to delete quest.");
    }
  };

  const handleCompleteTask = async (taskId) => {
    try {
      const res = await fetch(`${API_BASE}/tasks/${taskId}/complete`, { method: 'POST' });
      if (res.ok) {
        const data = await res.json();
        setCompletionResult(data);
      } else {
        const errData = await res.json();
        showNotification(errData.detail || "Failed to complete quest.");
      }
    } catch (err) {
      showNotification("SYSTEM ERROR: Failed to complete quest.");
    }
  };

  const handleCastSkill = async (skillId) => {
    try {
      const res = await fetch(`${API_BASE}/skills/${skillId}/cast`, { method: 'POST' });
      if (res.ok) {
        const data = await res.json();
        setUser(prev => ({ ...prev, mp: data.mp_remaining }));
        showNotification(`SYSTEM: ${data.message}`);
      } else {
        const errData = await res.json();
        showNotification(`FAIL: ${errData.detail}`);
      }
    } catch (err) {
      showNotification("SYSTEM ERROR: Failed to cast skill.");
    }
  };

  if (loading && !user) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-system-bg text-neon-blue font-system text-2xl tracking-[0.5em] animate-pulse">
        INITIALIZING SYSTEM...
      </div>
    );
  }

  return (
    <Router>
      <div className="min-h-screen relative flex flex-col hide-scrollbar">
        <AnimatePresence>
          {completionResult && (
            <QuestCompletionCelebration 
              key="quest-celebration" 
              result={completionResult} 
              onClose={clearCompletionAndRefresh} 
            />
          )}
          {activeDeepQuest && (
            <DeepQuestOverlay
              key="deep-quest-overlay"
              task={activeDeepQuest}
              onComplete={(id) => {
                setActiveDeepQuest(null);
                handleCompleteTask(id);
              }}
              onAbandon={() => setActiveDeepQuest(null)}
            />
          )}
        </AnimatePresence>

        {showBoot && <BootSequence onComplete={() => setShowBoot(false)} />}
        
        {!showBoot && !briefingComplete && (
          <DailyBriefing onComplete={() => setBriefingComplete(true)} />
        )}

        {(!showBoot && briefingComplete) && (
          <>
            <Navbar user={user} onSystemReset={handleSystemReset} />

            <div className="flex-1 w-full max-w-7xl mx-auto pt-20 px-4 md:px-8 pb-24 relative overflow-y-auto hide-scrollbar z-0 pointer-events-none">
              
              {notification && (
                <div className="fixed top-24 left-1/2 -translate-x-1/2 z-50 pointer-events-none">
                  <div className="bg-black/80 backdrop-blur-md border border-neon-blue text-white font-system font-bold px-6 py-3 rounded shadow-[0_0_20px_rgba(0,210,255,0.6)] uppercase tracking-wider text-sm flex items-center gap-3">
                    <span className="w-2 h-2 rounded-full bg-neon-blue animate-ping" />
                    {notification}
                  </div>
                </div>
              )}



              {/* Header with interactive hero */}
              <header className="text-center mb-8 mt-4 relative z-0 pointer-events-none">
                <motion.h1
                  initial={{ opacity: 0, y: -10 }}
                  animate={{ opacity: 1, y: 0 }}
                  className="text-4xl md:text-5xl font-system text-white tracking-[0.2em] font-bold mb-2 glow-text pointer-events-auto relative z-10"
                >
                  S O L O <span className="text-neon-blue">L E V E L I N G</span>
                </motion.h1>
                <div className="pointer-events-auto w-40 md:w-56 mx-auto relative z-10">
                  <InteractiveHero user={user} />
                </div>
              </header>

              <div className="relative z-20 pointer-events-auto">
                <AnimatedRoutes 
                  user={user}
                  tasks={tasks}
                  skills={skills}
                  inventory={inventory}
                  handleCompleteTask={handleCompleteTask}
                  handleCreateTask={handleCreateTask}
                  handleUpdateTask={handleUpdateTask}
                  handleResetTask={handleResetTask}
                  handleDeleteTask={handleDeleteTask}
                  handleAssignStat={handleAssignStat}
                  handleUpdateProfile={handleUpdateProfile}
                  handleCastSkill={handleCastSkill}
                  handleSystemReset={handleSystemReset}
                  handleStartDeepQuest={(task) => setActiveDeepQuest(task)}
                />
              </div>

            </div>
            {/* Global blue bottom accent bar */}
            <div className="fixed bottom-0 left-0 w-full h-1 bg-gradient-to-r from-transparent via-neon-blue to-transparent shadow-[0_0_15px_#00d2ff] z-50 pointer-events-none" />
          </>
        )}
      </div>
    </Router>
  );
}

export default App;
