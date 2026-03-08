import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';

export default function DeepQuestOverlay({ task, onComplete, onAbandon }) {
  const [phase, setPhase] = useState('target'); // 'target' or 'active'
  const [targetDomain, setTargetDomain] = useState('');
  const [secondsElapsed, setSecondsElapsed] = useState(0);
  const [isFinishing, setIsFinishing] = useState(false);

  useEffect(() => {
    let interval;
    if (phase === 'active') {
      interval = setInterval(() => {
        setSecondsElapsed((prev) => prev + 1);
      }, 1000);
    }
    return () => clearInterval(interval);
  }, [phase]);

  const formatTime = (totalSeconds) => {
    const m = Math.floor(totalSeconds / 60).toString().padStart(2, '0');
    const s = (totalSeconds % 60).toString().padStart(2, '0');
    return `${m}:${s}`;
  };

  const handleAction = (action) => {
    setIsFinishing(true);
    setTimeout(() => {
      if (action === 'complete') onComplete(task.id);
      else onAbandon();
    }, 1000);
  };

  // Matrix digital rain characters
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@#$%^&*';

  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0, transition: { duration: 0.8 } }}
      className="fixed inset-0 z-[20000] flex flex-col items-center justify-center bg-black overflow-hidden pointer-events-auto"
    >
      {/* Background Deep Pulse */}
      <motion.div
        className="absolute inset-0 bg-red-900/10 mix-blend-screen"
        animate={{ opacity: [0.1, 0.4, 0.1] }}
        transition={{ duration: 4, repeat: Infinity, ease: "easeInOut" }}
      />

      {/* Domain Expansion Radial Gradients */}
      <div className="absolute inset-0 bg-[radial-gradient(circle_at_center,rgba(255,0,0,0.15)_0%,transparent_60%)] animate-pulse" />
      <div className="absolute inset-0 bg-[radial-gradient(circle_at_center,rgba(0,210,255,0.05)_0%,transparent_80%)]" />

      {/* Floating Matrix Digital Script (Subtle) */}
      {[...Array(40)].map((_, i) => (
        <motion.div
          key={i}
          className="absolute text-neon-blue/20 font-mono text-xl whitespace-nowrap opacity-20 pointer-events-none"
          style={{
            left: `${Math.random() * 100}%`,
            top: `-20px`,
          }}
          animate={{
            y: ['0vh', '120vh'],
            opacity: [0, 0.3, 0],
          }}
          transition={{
            duration: Math.random() * 5 + 5,
            repeat: Infinity,
            delay: Math.random() * 5,
            ease: "linear"
          }}
        >
          {[...Array(10)].map(() => chars[Math.floor(Math.random() * chars.length)]).join('\n')}
        </motion.div>
      ))}

      <AnimatePresence mode="wait">
        {phase === 'target' && (
          <motion.div
            key="target-phase"
            className="relative z-10 flex flex-col items-center max-w-xl w-full px-6 text-center system-panel p-8"
            initial={{ scale: 0.9, y: 50, opacity: 0 }}
            animate={{ scale: 1, y: 0, opacity: 1 }}
            exit={{ scale: 1.1, blur: "10px", opacity: 0, transition: { duration: 0.4 } }}
          >
            <h3 className="text-neon-blue font-system text-xl font-bold tracking-[0.3em] mb-2 uppercase glow-text">
              Target Acquisition
            </h3>
            <p className="text-gray-400 font-system text-sm mb-8 uppercase tracking-wider">
              System requires a designated target for Deep Quest:
              <br/>
              <span className="text-white font-bold">{task.title}</span>
            </p>

            <form 
              onSubmit={(e) => { e.preventDefault(); if (targetDomain.trim()) setPhase('active'); }}
              className="w-full flex justify-center mb-8"
            >
              <input
                type="text"
                autoFocus
                placeholder="e.g. github.com, Visual Studio..."
                value={targetDomain}
                onChange={(e) => setTargetDomain(e.target.value)}
                className="w-full bg-black/60 border border-neon-blue text-white font-mono text-center px-4 py-3 rounded outline-none focus:shadow-[0_0_20px_rgba(0,210,255,0.5)] transition-all"
              />
            </form>

            <div className="flex gap-4 w-full justify-center">
              <motion.button
                type="button"
                whileHover={{ scale: 1.05 }}
                whileTap={{ scale: 0.95 }}
                onClick={() => onAbandon()}
                className="px-6 py-3 border border-gray-500 text-gray-400 font-system text-sm uppercase rounded hover:text-white"
              >
                Cancel
              </motion.button>
              <motion.button
                type="button"
                whileHover={{ scale: 1.05, boxShadow: '0 0 20px rgba(0,210,255,0.6)' }}
                whileTap={{ scale: 0.95 }}
                onClick={() => { if (targetDomain.trim()) setPhase('active'); }}
                className="px-6 py-3 bg-neon-blue text-black font-system font-bold uppercase tracking-wider rounded disabled:opacity-50"
                disabled={!targetDomain.trim()}
              >
                Lock Target
              </motion.button>
            </div>
          </motion.div>
        )}

        {phase === 'active' && (
          <motion.div
            key="active-phase"
            className="relative z-10 flex flex-col items-center max-w-2xl w-full px-6 text-center"
            initial={{ scale: 0.9, blur: "10px", opacity: 0 }}
            animate={isFinishing ? { scale: 1.1, blur: "20px", opacity: 0, transition: { duration: 0.8 } } : { scale: 1, blur: "0px", opacity: 1 }}
            transition={{ type: 'spring', damping: 20 }}
          >
        <motion.h3
          className="text-red-500 font-system text-xl font-bold tracking-[0.5em] mb-4 uppercase drop-shadow-[0_0_15px_rgba(255,0,0,0.8)]"
          animate={{ scale: [1, 1.02, 1], opacity: [0.8, 1, 0.8] }}
          transition={{ duration: 2, repeat: Infinity, ease: "easeInOut" }}
        >
          [ DOMAIN LOCKED ]
        </motion.h3>

        <h1 className="text-4xl md:text-6xl font-system text-white font-black tracking-widest uppercase mb-4 glow-text drop-shadow-[0_5px_5px_rgba(0,0,0,1)]">
          {task.title}
        </h1>

        <motion.div 
          className="mb-12 bg-neon-blue/10 border border-neon-blue/30 px-6 py-2 rounded-full inline-block backdrop-blur-md"
          animate={{ boxShadow: ['0 0 10px rgba(0,210,255,0.2)', '0 0 30px rgba(0,210,255,0.4)', '0 0 10px rgba(0,210,255,0.2)'] }}
          transition={{ duration: 3, repeat: Infinity }}
        >
          <span className="text-neon-blue font-mono text-sm uppercase tracking-widest">
            Target Locked: <span className="text-white font-bold ml-2">{targetDomain}</span>
          </span>
        </motion.div>

        {/* Timer Box */}
        <div className="relative mb-16">
          <motion.div
            className="absolute inset-0 border-2 border-gold-accent rounded-3xl"
            animate={{ rotate: 360, scale: [1, 1.05, 1] }}
            transition={{ duration: 10, repeat: Infinity, ease: "linear" }}
            style={{ borderRadius: "30% 70% 70% 30% / 30% 30% 70% 70%" }}
          />
          <motion.div
            className="absolute inset-0 border-2 border-neon-blue rounded-3xl"
            animate={{ rotate: -360, scale: [1.05, 1, 1.05] }}
            transition={{ duration: 15, repeat: Infinity, ease: "linear" }}
            style={{ borderRadius: "70% 30% 30% 70% / 70% 70% 30% 30%" }}
          />
          
          <div className="bg-black/80 backdrop-blur-xl w-64 h-64 rounded-full flex flex-col items-center justify-center border border-white/10 shadow-[0_0_50px_rgba(0,210,255,0.2)]">
            <span className="text-gray-400 font-system uppercase tracking-[0.3em] text-sm mb-2 font-bold">Time Elapsed</span>
            <span className="text-6xl font-mono text-neon-blue glow-text tracking-wider">{formatTime(secondsElapsed)}</span>
          </div>
        </div>

        {/* Action Buttons */}
        <div className="flex gap-6 w-full justify-center">
          <motion.button
            whileHover={{ scale: 1.05, boxShadow: '0 0 30px rgba(255, 51, 51, 0.4)' }}
            whileTap={{ scale: 0.95 }}
            onClick={() => handleAction('abandon')}
            disabled={isFinishing}
            className="px-8 py-4 bg-transparent border-2 border-hp-red text-hp-red font-system font-bold uppercase tracking-widest hover:bg-hp-red hover:text-white transition-colors disabled:opacity-50"
          >
            Tactical Retreat
          </motion.button>
          
          <motion.button
            whileHover={{ scale: 1.05, boxShadow: '0 0 40px rgba(0, 210, 255, 0.6)' }}
            whileTap={{ scale: 0.95 }}
            onClick={() => handleAction('complete')}
            disabled={isFinishing}
            className="px-8 py-4 bg-neon-blue/20 border-2 border-neon-blue text-white font-system font-black uppercase tracking-widest hover:bg-neon-blue hover:text-black transition-colors disabled:opacity-50 relative overflow-hidden group"
          >
            <span className="relative z-10 drop-shadow-md">Annihilate Target</span>
            <div className="absolute inset-0 bg-gradient-to-r from-transparent via-white/40 to-transparent -translate-x-[150%] group-hover:animate-[strike_1s_ease-in-out_infinite]" />
          </motion.button>
        </div>
      </motion.div>
      )}
      </AnimatePresence>

      {/* Scanline overlay */}
      <div className="absolute inset-0 pointer-events-none bg-[linear-gradient(rgba(18,16,16,0)_50%,rgba(0,0,0,0.25)_50%),linear-gradient(90deg,rgba(255,0,0,0.06),rgba(0,255,0,0.02),rgba(0,0,255,0.06))] bg-[length:100%_4px,3px_100%] z-50 opacity-30" />
    </motion.div>
  );
}
