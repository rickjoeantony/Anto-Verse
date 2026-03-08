import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';

export default function DailyBriefing({ onComplete }) {
  const [step, setStep] = useState(0);
  const [briefingData, setBriefingData] = useState(null);

  useEffect(() => {
    const fetchBriefing = async () => {
      try {
        const res = await fetch('http://127.0.0.1:8000/api/system/briefing');
        if (res.ok) {
          const data = await res.json();
          setBriefingData(data);
        }
      } catch (err) {
        console.error("Failed to fetch briefing:", err);
      }
    };
    fetchBriefing();
  }, []);

  useEffect(() => {
    // Step 0: Analyzing script typing (0-2s)
    const t1 = setTimeout(() => setStep(1), 2000);
    // Step 1: Warning message (2-4s)
    const t2 = setTimeout(() => setStep(2), 4500);
    // Step 2: Show quests and accept button (4.5s+)
    return () => {
      clearTimeout(t1);
      clearTimeout(t2);
    };
  }, []);

  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0, scale: 0.95 }}
      transition={{ duration: 0.5 }}
      className="fixed inset-0 z-[100] bg-black text-white font-system flex flex-col items-center justify-center p-6 overflow-hidden"
    >
      {/* Grid Background */}
      <div className="absolute inset-0 bg-[linear-gradient(rgba(0,210,255,0.05)_1px,transparent_1px),linear-gradient(90deg,rgba(0,210,255,0.05)_1px,transparent_1px)] bg-[size:30px_30px] opacity-20" />
      
      {/* Matrix Digital Script Matrix */}
      {[...Array(25)].map((_, i) => (
        <motion.div
          key={`matrix-${i}`}
          className="absolute text-neon-blue/40 font-mono text-sm whitespace-nowrap opacity-30 pointer-events-none"
          style={{
            left: `${Math.random() * 100}%`,
            top: `-50px`,
          }}
          animate={{
            y: ['0vh', '110vh'],
            opacity: [0, 0.8, 0],
          }}
          transition={{
            duration: Math.random() * 3 + 2,
            repeat: Infinity,
            delay: Math.random() * 2,
            ease: "linear"
          }}
        >
          {[...Array(15)].map(() => 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@#$%^&*'[(Math.floor(Math.random() * 42))]).join('\n')}
        </motion.div>
      ))}

      {/* Scanning line */}
      <motion.div 
        animate={{ y: ['-10vh', '110vh'] }}
        transition={{ duration: 3, ease: "linear", repeat: Infinity }}
        className="absolute w-full h-1 bg-neon-blue/40 shadow-[0_0_20px_rgba(0,210,255,1)] opacity-30 z-0"
      />

      <div className="relative z-10 w-full max-w-2xl">
        <AnimatePresence mode="wait">
          {step === 0 && (
            <motion.div
              key="step0"
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="text-center"
            >
              <h2 className="text-2xl md:text-4xl text-neon-blue tracking-widest uppercase mb-4 animate-[pulse_2s_ease-in-out_infinite]">
                System Initializing
              </h2>
              <p className="text-gray-400 font-mono text-sm uppercase tracking-wider">
                &gt; Analyzing player pattern...<motion.span animate={{ opacity: [0, 1, 0] }} transition={{ repeat: Infinity, duration: 1 }}>_</motion.span>
              </p>
            </motion.div>
          )}

          {step === 1 && briefingData && (
            <motion.div
              key="step1"
              initial={{ opacity: 0, scale: 0.9 }}
              animate={{ opacity: 1, scale: 1 }}
              exit={{ opacity: 0 }}
              className="text-center"
            >
              <motion.div 
                animate={{ rotate: [-5, 5, -5, 5, 0] }}
                transition={{ duration: 0.5 }}
                className="text-6xl text-hp-red mb-6 drop-shadow-[0_0_15px_rgba(255,51,51,0.8)]"
              >
                ⚠️
              </motion.div>
              <h2 className="text-3xl md:text-5xl text-hp-red glow-text-red font-bold uppercase tracking-[0.2em] mb-4">
                Warning
              </h2>
              <p className="text-xl text-gray-300 font-system tracking-wider max-w-lg mx-auto border-t border-b border-hp-red/40 py-4 bg-hp-red/10 shadow-[inset_0_0_20px_rgba(255,51,51,0.2)]">
                {briefingData.message}
              </p>
            </motion.div>
          )}

          {step >= 2 && briefingData && (
            <motion.div
              key="step2"
              initial={{ opacity: 0, y: 30 }}
              animate={{ opacity: 1, y: 0 }}
              className="w-full flex flex-col items-center"
            >
              <h2 className="text-2xl text-neon-blue uppercase tracking-widest mb-6 glow-text text-center">
                System Assigned Quests
              </h2>
              
              <div className="w-full space-y-4 mb-8">
                {briefingData.tasks.map((task, i) => (
                  <motion.div
                    key={i}
                    initial={{ opacity: 0, x: -30 }}
                    animate={{ opacity: 1, x: 0 }}
                    transition={{ delay: 0.5 + i * 0.2, type: 'spring', stiffness: 100 }}
                    className="p-5 border-l-4 border-hp-red bg-black/60 backdrop-blur-md border-y border-r border-y-hp-red/20 border-r-hp-red/20 relative overflow-hidden group hover:shadow-[0_0_25px_rgba(255,51,51,0.2)] transition-shadow"
                    style={{ clipPath: 'polygon(0 0, 100% 0, 100% calc(100% - 15px), calc(100% - 15px) 100%, 0 100%)' }}
                  >
                    <div className="absolute inset-0 bg-gradient-to-r from-hp-red/20 to-transparent -translate-x-full group-hover:translate-x-full transition-transform duration-700" />
                    <div className="flex justify-between items-center relative z-10">
                      <div>
                        <span className="text-[10px] text-hp-red uppercase tracking-widest px-2 py-0.5 border border-hp-red/30 bg-hp-red/10 rounded-sm mb-2 inline-block">
                          Penalty Quest
                        </span>
                        <h4 className="text-lg font-bold text-white tracking-wide">{task.title}</h4>
                      </div>
                      <div className="text-right">
                        <span className="block text-xl text-hp-red glow-text-red font-bold">+{task.exp_reward} EXP</span>
                      </div>
                    </div>
                  </motion.div>
                ))}
              </div>

              <motion.button
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                transition={{ delay: 1.5 }}
                onClick={onComplete}
                whileHover={{ scale: 1.05, boxShadow: '0 0 25px rgba(255,51,51,0.6)' }}
                whileTap={{ scale: 0.95 }}
                className="px-10 py-4 bg-hp-red/10 border-2 border-hp-red text-hp-red font-bold uppercase tracking-[0.2em] relative overflow-hidden group shadow-[0_0_15px_rgba(255,51,51,0.3)] hover:text-white transition-colors"
                style={{ clipPath: 'polygon(15px 0, 100% 0, 100% calc(100% - 15px), calc(100% - 15px) 100%, 0 100%, 0 15px)' }}
              >
                <div className="absolute inset-0 bg-hp-red -translate-x-full group-hover:translate-x-0 transition-transform duration-300 -z-10" />
                <span className="relative z-10">Accept Penalties</span>
              </motion.button>
            </motion.div>
          )}
          
          {step >= 1 && !briefingData && (
             <motion.div key="error" initial={{ opacity: 0 }} animate={{ opacity: 1 }} className="text-center">
               <h2 className="text-xl text-gray-500 uppercase tracking-widest mb-4">No new system messages.</h2>
               <motion.button
                onClick={onComplete}
                className="px-6 py-2 border border-neon-blue text-neon-blue hover:bg-neon-blue hover:text-black rounded uppercase tracking-widest transition-colors font-system text-sm"
              >
                Proceed
              </motion.button>
             </motion.div>
          )}
        </AnimatePresence>
      </div>
    </motion.div>
  );
}
