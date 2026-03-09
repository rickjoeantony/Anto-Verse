import React from 'react';
import { motion } from 'framer-motion';
import { useApp } from '../context/AppContext';
import FloatingParticles from './FloatingParticles';

export default function LoadingScreen({ children }) {
  const { loading, user } = useApp();

  if (loading && !user) {
    return (
      <div className="min-h-screen flex flex-col items-center justify-center bg-system-bg text-neon-blue font-system relative overflow-hidden">
        <FloatingParticles />
        <motion.div
          initial={{ opacity: 0, scale: 0.9 }}
          animate={{ opacity: 1, scale: 1 }}
          className="relative z-10 flex flex-col items-center gap-6"
        >
          <motion.div
            className="w-16 h-16 border-2 border-neon-blue rounded-full"
            animate={{ rotate: 360 }}
            transition={{ duration: 2, repeat: Infinity, ease: 'linear' }}
            style={{ borderTopColor: 'transparent' }}
          />
          <motion.p className="text-2xl tracking-[0.5em] font-bold glow-text animate-boot">
            INITIALIZING SYSTEM...
          </motion.p>
          <motion.div className="flex gap-1">
            {[0, 1, 2].map((i) => (
              <motion.span
                key={i}
                className="w-2 h-2 bg-neon-blue rounded-full"
                animate={{ scale: [1, 1.3, 1], opacity: [0.5, 1, 0.5] }}
                transition={{ duration: 1, repeat: Infinity, delay: i * 0.2 }}
              />
            ))}
          </motion.div>
        </motion.div>
      </div>
    );
  }

  return children;
}
