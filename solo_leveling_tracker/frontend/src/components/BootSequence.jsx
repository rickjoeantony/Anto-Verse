import React, { useEffect, useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';

const API_BASE = 'http://127.0.0.1:8000/api';

const BootSequence = ({ onComplete }) => {
  const [tasks, setTasks] = useState([]);
  const [stage, setStage] = useState(0);

  useEffect(() => {
    // Fetch active tasks for the briefing
    const fetchTasks = async () => {
      try {
        const res = await fetch(`${API_BASE}/tasks`);
        const data = await res.json();
        setTasks(data.filter(t => !t.completed));
      } catch (e) {
        console.error("Failed to fetch tasks for boot sequence", e);
      }
    };
    fetchTasks();

    // Stage timings
    const timers = [
      setTimeout(() => setStage(1), 1000), // Auth
      setTimeout(() => setStage(2), 2500), // Welcome
      setTimeout(() => setStage(3), 4000), // Briefing Header
      setTimeout(() => setStage(4), 5500), // Quest List
      setTimeout(() => setStage(5), 8000), // Proceed Button
    ];

    return () => timers.forEach(clearTimeout);
  }, []);

  return (
    <AnimatePresence>
      <motion.div
        key="boot-sequence"
        initial={{ opacity: 1 }}
        exit={{ opacity: 0, scale: 1.1, filter: 'blur(10px)' }}
        transition={{ duration: 0.8, ease: 'easeIn' }}
        className="fixed inset-0 z-[100] bg-black flex flex-col items-center justify-center overflow-hidden font-mono"
      >
        {/* Background Grid Scanline Effect */}
        <div className="absolute inset-0 z-0 opacity-20 pointer-events-none"
             style={{
               backgroundImage: 'linear-gradient(rgba(0, 210, 255, 0.2) 1px, transparent 1px)',
               backgroundSize: '100% 4px',
               animation: 'scanline 10s linear infinite'
             }} 
        />
        
        <div className="relative z-10 w-full max-w-3xl p-6 md:p-12 text-neon-blue drop-shadow-[0_0_8px_rgba(0,210,255,0.8)]">
          <div className="space-y-4 text-sm md:text-base">
            <AnimatePresence>
              {stage >= 0 && (
                <motion.div key="stage0" initial={{ opacity: 0 }} animate={{ opacity: 1 }}>
                  &gt; SYSTEM_INITIALIZATION_SEQUENCE_STARTED...
                </motion.div>
              )}
              {stage >= 1 && (
                <motion.div key="stage1" initial={{ opacity: 0 }} animate={{ opacity: 1 }}>
                  &gt; AUTHENTICATING_MONARCH... <span className="text-green-400">SUCCESS</span>
                </motion.div>
              )}
              {stage >= 2 && (
                <motion.div 
                  key="stage2"
                  initial={{ opacity: 0, x: -20 }} 
                  animate={{ opacity: 1, x: 0 }}
                  className="py-4 my-4 border-y border-neon-blue/40 font-system text-2xl md:text-4xl text-center text-white glow-text mb-8 tracking-[0.2em] uppercase"
                >
                  <TypewriterText text="WELCOME BACK, RICKJOE" speed={30} />
                </motion.div>
              )}
              {stage >= 3 && (
                <motion.div key="stage3" initial={{ opacity: 0 }} animate={{ opacity: 1 }}>
                  <div className="text-hp-red glow-text-red mb-2">&gt; [WARNING] DAILY SYSTEM BRIEFING REQUIRED</div>
                  <div>&gt; ANALYZING_PATTERNS...</div>
                </motion.div>
              )}
              {stage >= 4 && (
                <motion.div key="stage4" initial={{ opacity: 0 }} animate={{ opacity: 1 }} className="mt-4 border border-neon-blue/20 bg-neon-blue/5 p-4 rounded backdrop-blur-sm">
                  <div className="text-white mb-2 underline tracking-widest font-system uppercase">Active Objectives</div>
                  {tasks.length === 0 ? (
                    <div className="text-gray-400 italic">No pending objectives detected.</div>
                  ) : (
                    <div className="space-y-3">
                      {tasks.slice(0, 5).map((task, i) => (
                        <motion.div 
                          key={task.id}
                          initial={{ opacity: 0, x: -10 }}
                          animate={{ opacity: 1, x: 0 }}
                          transition={{ delay: i * 0.3 }}
                          className="flex flex-col"
                        >
                          <div className="flex justify-between items-start">
                            <span className="text-white font-bold tracking-wide">
                              [{task.is_daily ? 'DAILY' : 'QUEST'}] {task.title}
                            </span>
                            <span className="text-gold-accent shrink-0 text-xs mt-1">+{task.exp_reward} EXP</span>
                          </div>
                          {task.description && (
                            <span className="text-gray-400 text-xs mt-0.5 ml-1 pl-2 border-l border-neon-blue/30 italic">
                              {task.description}
                            </span>
                          )}
                        </motion.div>
                      ))}
                      {tasks.length > 5 && (
                        <div className="text-gray-500 text-xs italic mt-2">...and {tasks.length - 5} more hidden objectives.</div>
                      )}
                    </div>
                  )}
                </motion.div>
              )}
            </AnimatePresence>

            {stage >= 5 && (
              <motion.div 
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                className="mt-12 flex justify-center"
              >
                <button
                  onClick={onComplete}
                  className="relative group px-8 py-3 bg-neon-blue/10 border-2 border-neon-blue text-neon-blue font-system uppercase tracking-widest hover:bg-neon-blue hover:text-black transition-all duration-300 rounded overflow-hidden"
                >
                  <div className="absolute inset-0 w-full h-full bg-white/20 -translate-x-full group-hover:translate-x-full transition-transform duration-500 z-0" />
                  <span className="relative z-10 flex items-center gap-2">
                    Accept Quests & Proceed
                    <svg className="w-5 h-5 group-hover:translate-x-1 transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 5l7 7-7 7M5 5l7 7-7 7" /></svg>
                  </span>
                </button>
              </motion.div>
            )}
          </div>
        </div>
      </motion.div>
    </AnimatePresence>
  );
};

// Helper component for glitchy typewriter effect
const TypewriterText = ({ text, speed = 50 }) => {
  const [displayText, setDisplayText] = useState('');
  
  useEffect(() => {
    let index = 0;
    const interval = setInterval(() => {
      if (index <= text.length) {
        setDisplayText(text.slice(0, index));
        index++;
      } else {
        clearInterval(interval);
      }
    }, speed);
    
    return () => clearInterval(interval);
  }, [text, speed]);

  return <span>{displayText}</span>;
}

export default BootSequence;
