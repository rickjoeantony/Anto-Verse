import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { useNavigate } from 'react-router-dom';

const staticConfetti = [...Array(50)].map((_, i) => ({
  size: [8, 12, 6][i % 3],
  x: (Math.random() - 0.5) * 1000,
  y: (Math.random() - 0.5) * 800,
  rotate: (Math.random() - 0.5) * 720,
}));

export default function QuestCompletionCelebration({ result, onClose }) {
  const navigate = useNavigate();
  const [expDisplay, setExpDisplay] = useState(0);
  const [showContent, setShowContent] = useState(false);

  useEffect(() => {
    if (!result) return;
    // eslint-disable-next-line react-hooks/set-state-in-effect
    setShowContent(false);
    const target = result.exp_gained || 0;
    const duration = 1000;
    const steps = 30;
    const stepVal = target / steps;
    const stepTime = duration / steps;
    let current = 0;
    const timer = setInterval(() => {
      current += stepVal;
      if (current >= target) {
        setExpDisplay(target);
        clearInterval(timer);
      } else {
        setExpDisplay(Math.floor(current));
      }
    }, stepTime);
    return () => clearInterval(timer);
  }, [result]);

  useEffect(() => {
    if (!result) return;
    const t = setTimeout(() => setShowContent(true), 200);
    return () => clearTimeout(t);
  }, [result]);

  if (!result) return null;

  const hasDrop = result.drop_message;
  const dropMatch = hasDrop && result.drop_message.match(/\[([^\]]+)\]\s*([^!]+)/);
  const colors = ['#00d2ff', '#ffd700', '#b026ff', '#ff3333', '#00ff88'];

  return (
    <AnimatePresence>
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        exit={{ opacity: 0, transition: { duration: 0.3 } }}
        className="fixed inset-0 z-[10001] flex items-center justify-center overflow-hidden cursor-pointer"
        onClick={() => {
          navigate('/inventory');
          if (onClose) onClose();
        }}
      >
        {/* Massive Screen Shake Container */}
          <motion.div
          className="absolute inset-0"
          initial={{ x: 0, y: 0 }}
          animate={{ x: [-30, 30, -40, 40, -20, 20, -10, 10, 0], y: [-30, 30, -40, 40, -20, 20, -10, 10, 0] }}
          transition={{ duration: 1.2, ease: "easeInOut" }}
        >
          {/* Intense Screen flash */}
          <motion.div
            className="absolute inset-0 bg-white"
            initial={{ opacity: 1 }}
            animate={{ opacity: 0 }}
            transition={{ duration: 0.8, ease: "easeOut" }}
          />

          {/* Dark overlay */}
          <div className="absolute inset-0 bg-black/90 backdrop-blur-xl" />

          {/* Fire particles rising from bottom */}
          {[...Array(120)].map((_, i) => (
            <motion.div
              key={`fire-${i}`}
              className="absolute bottom-0 w-3 rounded-full"
              style={{
                left: `${Math.random() * 100}%`,
                height: Math.random() * 150 + 50,
                background: `linear-gradient(to top, rgba(255, 50, 0, 0.9), rgba(255, 150, 0, 0.4), transparent)`,
                filter: 'blur(3px)',
                zIndex: Math.random() > 0.5 ? 5 : 15,
              }}
              initial={{ y: 200, opacity: 0 }}
              animate={{ 
                y: -1200 - Math.random() * 800,
                opacity: [0, 1, 0.8, 0]
              }}
              transition={{ duration: 1.2 + Math.random() * 2, ease: "easeOut" }}
            />
          ))}

          {/* Vertical Energy Pillar */}
          <motion.div
            className="absolute left-1/2 bottom-0 w-80 -ml-40 h-[200vh] bg-gradient-to-t from-neon-blue/80 via-gold-accent/50 to-transparent mix-blend-screen"
            style={{ filter: 'blur(10px)' }}
            initial={{ scaleY: 0, opacity: 0 }}
            animate={{ scaleY: 1, opacity: [0, 0.8, 0] }}
            transition={{ duration: 1.5, ease: "easeOut" }}
          />

          {/* Confetti burst - 50 particles */}
          {[...Array(50)].map((_, i) => (
            <motion.div
              key={i}
              className="absolute rounded-sm"
              style={{
                left: '50%',
                top: '50%',
                width: [8, 12, 6][i % 3],
                height: [8, 12, 6][i % 3],
                background: colors[i % colors.length],
                boxShadow: `0 0 10px ${colors[i % colors.length]}`,
              }}
              initial={{ scale: 0, x: 0, y: 0, opacity: 1, rotate: 0 }}
              animate={{
                scale: [0, 1.2, 0],
                x: (Math.random() - 0.5) * 1000,
                y: (Math.random() - 0.5) * 800,
                opacity: [1, 1, 0],
                rotate: (Math.random() - 0.5) * 720,
              }}
              transition={{ duration: 2, delay: i * 0.015, ease: 'easeOut' }}
            />
          ))}

          {/* Radial burst rings */}
          {[0, 1, 2].map((i) => (
            <motion.div
              key={`ring-${i}`}
              className="absolute w-32 h-32 rounded-full border-2 border-gold-accent/50"
              style={{ left: '50%', top: '50%', marginLeft: -64, marginTop: -64 }}
              initial={{ scale: 0, opacity: 0.8 }}
              animate={{ scale: 6, opacity: 0 }}
              transition={{ duration: 1.2, delay: i * 0.2 }}
            />
          ))}

          <motion.div
            className="relative text-center max-w-md mx-4 z-10 pointer-events-none"
            initial={{ scale: 0.3, opacity: 0 }}
            animate={showContent ? { scale: 1, opacity: 1 } : {}}
            transition={{ type: 'spring', stiffness: 260, damping: 20 }}
          >
            {/* Glow orb behind content */}
            <motion.div
              className="absolute inset-0 -m-24 rounded-full bg-neon-blue/30 blur-3xl"
              initial={{ scale: 0 }}
              animate={{ scale: 1.5 }}
              transition={{ duration: 0.8 }}
            />

            {/* QUEST CLEARED! - Big impactful text */}
            <motion.div
              initial={{ scale: 0, rotate: -15 }}
              animate={{ scale: 1, rotate: 0 }}
              transition={{ type: 'spring', stiffness: 200, damping: 12, delay: 0.1 }}
              className="mb-6"
            >
              <motion.span
                className="text-5xl md:text-7xl font-system font-black tracking-[0.15em] block"
                animate={{
                  textShadow: [
                    '0 0 30px #00d2ff, 0 0 60px #00d2ff',
                    '0 0 50px #ffd700, 0 0 100px #ffd700',
                    '0 0 30px #00d2ff, 0 0 60px #00d2ff',
                  ],
                  color: ['#00d2ff', '#ffd700', '#00d2ff'],
                }}
                transition={{ duration: 0.6, repeat: Infinity }}
              >
                QUEST CLEARED!
              </motion.span>
            </motion.div>

            {/* Shockwave expanding from text */}
            <motion.div
              className="absolute top-1/2 left-1/2 w-32 h-32 -ml-16 -mt-16 border-4 border-neon-blue/80 rounded-full"
              initial={{ scale: 0, opacity: 1 }}
              animate={{ scale: 20, opacity: 0 }}
              transition={{ duration: 0.8, ease: "easeOut" }}
            />

            {/* Success checkmark - satisfying pop */}
            <motion.div
              initial={{ scale: 0 }}
              animate={{ scale: 1 }}
              transition={{ type: 'spring', stiffness: 400, damping: 10, delay: 0.2 }}
              className="text-8xl mb-6 text-gold-accent"
            >
              <motion.span
                animate={{ scale: [1, 1.15, 1] }}
                transition={{ duration: 0.5, repeat: 2, repeatDelay: 0.3 }}
              >
                ✓
              </motion.span>
            </motion.div>

            {/* EXP gained - counting up dopamine */}
            <motion.div
              initial={{ y: 30, opacity: 0 }}
              animate={{ y: 0, opacity: 1 }}
              transition={{ delay: 0.3 }}
              className="mb-6"
            >
              <span className="text-gray-400 font-system text-xs uppercase tracking-[0.3em]">EXP Gained</span>
              <motion.span
                key={expDisplay}
                className="block text-5xl md:text-6xl font-system font-black text-gold-accent mt-1"
                initial={{ scale: 1.4 }}
                animate={{ scale: 1 }}
                style={{ textShadow: '0 0 30px rgba(255, 215, 0, 0.8)' }}
              >
                +{expDisplay}
              </motion.span>
            </motion.div>

            {/* Item drop - dramatic reveal */}
            {hasDrop && dropMatch && (
              <motion.div
                initial={{ scale: 0, opacity: 0, y: 30 }}
                animate={{ scale: 1, opacity: 1, y: 0 }}
                transition={{ delay: 0.7, type: 'spring', stiffness: 200 }}
                className="mt-6 p-5 rounded-2xl bg-gradient-to-br from-gold-accent/20 to-transparent border-2 border-gold-accent/60 relative overflow-hidden"
              >
                <motion.div
                  className="absolute inset-0 bg-gradient-to-r from-transparent via-white/20 to-transparent"
                  animate={{ x: ['-100%', '200%'] }}
                  transition={{ duration: 1.5, repeat: 2, repeatDelay: 0.5 }}
                />
                <span className="text-gold-accent font-system text-sm uppercase tracking-widest block mb-2">
                  🎁 Item Obtained!
                </span>
                <span className="text-xl font-system text-white font-medium">
                  [{dropMatch[1]}] {dropMatch[2]}
                </span>
              </motion.div>
            )}

            {/* Tap to continue */}
            <motion.p
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              transition={{ delay: 2 }}
              className="mt-10 text-gray-500 text-sm font-system animate-pulse"
            >
              Tap anywhere to view Inventory
            </motion.p>
          </motion.div>
        </motion.div>
      </motion.div>
    </AnimatePresence>
  );
}
