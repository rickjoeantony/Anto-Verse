import React from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { useApp } from '../context/AppContext';

export default function Notification() {
  const { notification } = useApp();

  return (
    <AnimatePresence>
      {notification && (
        <motion.div
          initial={{ opacity: 0, y: -20, scale: 0.95 }}
          animate={{ opacity: 1, y: 0, scale: 1 }}
          exit={{ opacity: 0, y: -20 }}
          className="fixed top-24 left-1/2 -translate-x-1/2 z-[10000]"
        >
          <motion.div
            className="bg-black/80 backdrop-blur-xl border border-neon-blue/60 text-white font-system font-bold px-6 py-3 rounded-lg shadow-[0_0_30px_rgba(0,210,255,0.5)] uppercase tracking-wider text-sm flex items-center gap-3"
            animate={{ boxShadow: ['0 0 30px rgba(0, 210, 255, 0.5)', '0 0 45px rgba(0, 210, 255, 0.7)', '0 0 30px rgba(0, 210, 255, 0.5)'] }}
            transition={{ duration: 1.5, repeat: Infinity }}
          >
            <motion.span
              className="w-2 h-2 rounded-full bg-neon-blue"
              animate={{ scale: [1, 1.5, 1], opacity: [1, 0.5, 1] }}
              transition={{ duration: 0.8, repeat: Infinity }}
            />
            {notification}
          </motion.div>
        </motion.div>
      )}
    </AnimatePresence>
  );
}
