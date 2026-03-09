import React, { useState } from 'react';
import { motion } from 'framer-motion';

export default function InteractiveHero({ user }) {
  const [rotateX, setRotateX] = useState(0);
  const [rotateY, setRotateY] = useState(0);

  if (!user) return null;

  const expPercent = Math.min((user.exp / user.required_exp) * 100, 100);
  const level = user.level;
  const totalStats = user.strength + user.agility + user.sense + user.vitality + user.intelligence;

  const handleMouseMove = (e) => {
    const rect = e.currentTarget.getBoundingClientRect();
    const x = e.clientX - rect.left;
    const y = e.clientY - rect.top;
    const centerX = rect.width / 2;
    const centerY = rect.height / 2;
    const rX = ((y - centerY) / centerY) * -15;
    const rY = ((x - centerX) / centerX) * 15;
    setRotateX(rX);
    setRotateY(rY);
  };

  const handleMouseLeave = () => {
    setRotateX(0);
    setRotateY(0);
  };

  return (
    <motion.div
      initial={{ opacity: 0, scale: 0.8 }}
      animate={{ opacity: 1, scale: 1 }}
      className="flex flex-col items-center justify-center py-8 md:py-12"
    >
      <motion.div
        className="relative cursor-pointer select-none"
        whileHover={{ scale: 1.05 }}
        whileTap={{ scale: 0.98 }}
        animate={{
          filter: [
            `drop-shadow(0 0 20px rgba(0, 210, 255, 0.4))`,
            `drop-shadow(0 0 40px rgba(176, 38, 255, 0.5))`,
            `drop-shadow(0 0 20px rgba(0, 210, 255, 0.4))`,
          ],
        }}
        transition={{ duration: 3, repeat: Infinity }}
      >
        {/* Level badge */}
        <motion.div
          className="absolute -top-2 -right-2 w-14 h-14 rounded-full bg-gold-accent/20 border-2 border-gold-accent flex items-center justify-center font-system font-bold text-gold-accent text-lg z-10"
          animate={{ rotate: [0, 5, -5, 0], scale: [1, 1.05, 1] }}
          transition={{ duration: 2, repeat: Infinity }}
        >
          {level}
        </motion.div>

        <motion.div
          className="relative w-40 h-56 md:w-56 md:h-72"
          animate={{
            y: [0, -10, 0],
          }}
          transition={{
            duration: 4,
            repeat: Infinity,
            ease: "easeInOut"
          }}
          style={{ transformStyle: 'preserve-3d' }}
        >
          {/* Summoning Portal Background */}
          <div className="absolute inset-0 flex items-center justify-center pointer-events-none" style={{ transform: 'translateZ(-50px)' }}>
            {/* Inner glowing core */}
            <motion.div 
              className="absolute w-48 h-48 md:w-64 md:h-64 rounded-full bg-neon-blue/20 blur-2xl mix-blend-screen"
              animate={{ scale: [1, 1.2, 1], opacity: [0.3, 0.6, 0.3] }}
              transition={{ duration: 3, repeat: Infinity, ease: "easeInOut" }}
            />
            {/* Magic Circle Ring 1 - Dashed expanding */}
            <motion.div 
              className="absolute w-56 h-56 md:w-80 md:h-80 rounded-full border-[3px] border-dashed border-neon-blue/40"
              animate={{ rotate: 360, scale: [1, 1.05, 1] }}
              transition={{ rotate: { duration: 20, repeat: Infinity, ease: "linear" }, scale: { duration: 4, repeat: Infinity, ease: "easeInOut" } }}
            />
            {/* Magic Circle Ring 2 - Outer reverse trace */}
            <motion.div 
              className="absolute w-64 h-64 md:w-96 md:h-96 rounded-full border-t-[4px] border-r-[4px] border-neon-blue/20"
              animate={{ rotate: -360 }}
              transition={{ duration: 15, repeat: Infinity, ease: "linear" }}
            />
            {/* Rising Mana Particles */}
            {[...Array(8)].map((_, i) => (
              <motion.div
                key={`mana-${i}`}
                className="absolute w-1.5 h-1.5 bg-neon-blue rounded-full filter drop-shadow-[0_0_5px_rgba(0,210,255,1)]"
                initial={{ y: 100, x: (Math.random() - 0.5) * 150, opacity: 0 }}
                animate={{ 
                  y: -150 - Math.random() * 100, 
                  x: (Math.random() - 0.5) * 200,
                  opacity: [0, 1, 0] 
                }}
                transition={{ 
                  duration: 2 + Math.random() * 2, 
                  repeat: Infinity, 
                  delay: Math.random() * 2,
                  ease: "easeOut"
                }}
              />
            ))}
          </div>

          {/* Holographic Core Avatar container with 3D tilt */}
          <motion.div 
            className="absolute inset-0 flex items-center justify-center filter drop-shadow-[0_0_20px_rgba(0,210,255,0.6)]"
            onMouseMove={handleMouseMove}
            onMouseLeave={handleMouseLeave}
            animate={{
              rotateX: rotateX,
              rotateY: rotateY,
            }}
            transition={{ type: "spring", stiffness: 300, damping: 20 }}
            style={{ transformStyle: 'preserve-3d' }}
          >
            {/* The Generated 3D Image */}
            <motion.div
              className="w-full h-full relative"
              style={{ transform: 'translateZ(30px)' }}
            >
               <img 
                 src="/shadow_monarch.png" 
                 alt="Shadow Monarch" 
                 className="w-full h-full object-contain filter drop-shadow-[0_0_15px_rgba(176,38,255,0.4)]"
               />
               
               {/* Internal breathing over-glow removed as requested (replaced by portal) */}
            </motion.div>
          </motion.div>
        </motion.div>

        {/* Deep pulse aura - intensity based on total stats */}
        <motion.div
          className="absolute inset-0 -z-10 rounded-full blur-3xl pointer-events-none"
          style={{
            background: `radial-gradient(circle, rgba(0, 210, 255, ${0.15 + totalStats * 0.003}) 0%, transparent 60%)`,
            width: '250%',
            height: '250%',
            left: '-75%',
            top: '-75%',
          }}
          animate={{ scale: [1, 1.3, 1], opacity: [0.5, 1, 0.5] }}
          transition={{ duration: 2.5, repeat: Infinity }}
        />

        {/* Secondary ring aura array */}
        <motion.div
          className="absolute inset-0 -z-10 rounded-full border border-neon-blue/20 pointer-events-none"
          animate={{ scale: [1, 2], opacity: [0.5, 0] }}
          transition={{ duration: 2, repeat: Infinity, ease: "easeOut" }}
          style={{ width: '150%', height: '150%', left: '-25%', top: '-25%' }}
        />
      </motion.div>

      {/* Name & progress */}
      <motion.p
        className="mt-4 font-system text-white text-xl tracking-widest"
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 0.3 }}
      >
        {user.name}
      </motion.p>
      <motion.div
        className="mt-2 w-48 h-1.5 bg-black/50 rounded-full overflow-hidden border border-white/10"
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 0.4 }}
      >
        <motion.div
          className="h-full bg-gradient-to-r from-gold-accent to-yellow-400 rounded-full"
          initial={{ width: 0 }}
          animate={{ width: `${expPercent}%` }}
          transition={{ duration: 0.8 }}
        />
      </motion.div>
      <motion.span
        className="text-xs text-gray-500 font-system mt-1"
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 0.5 }}
      >
        {Math.round(expPercent)}% to next level
      </motion.span>
    </motion.div>
  );
}
