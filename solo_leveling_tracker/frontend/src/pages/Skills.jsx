import React, { useState } from 'react';
import { motion } from 'framer-motion';
import { useApp } from '../context/AppContext';
import Notification from '../components/Notification';

export default function Skills() {
  const { skills, user, handleCastSkill } = useApp();
  const userMp = user?.mp ?? 0;
  const maxMp = user?.max_mp ?? 50;
  const [castingId, setCastingId] = useState(null);
  const [selectedSkill, setSelectedSkill] = useState(null);

  const handleCast = async (skillId) => {
    setCastingId(skillId);
    await handleCastSkill(skillId);
    setCastingId(null);
  };

  return (
    <div className="max-w-6xl mx-auto p-4 md:p-8 min-h-[80vh]">
      <Notification />

      <motion.header
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        className="text-center mb-12"
      >
        <motion.h1
          className="text-4xl md:text-5xl font-system text-glow-purple tracking-widest mb-2 glow-text"
          animate={{ opacity: [1, 0.9, 1], textShadow: ['0 0 20px rgba(176,38,255,0.5)', '0 0 40px rgba(176,38,255,0.8)', '0 0 20px rgba(176,38,255,0.5)'] }}
          transition={{ duration: 2, repeat: Infinity }}
        >
          SKILLS & ABILITIES
        </motion.h1>
        <p className="text-gray-500 font-system text-sm tracking-wider">MP: {userMp} / {maxMp}</p>
        <motion.div
          className="mt-4 h-1 w-48 mx-auto bg-gradient-to-r from-transparent via-glow-purple to-transparent rounded-full"
          animate={{ opacity: [0.5, 1, 0.5] }}
          transition={{ duration: 2, repeat: Infinity }}
        />
      </motion.header>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {skills.map((skill, i) => {
          const canCast = userMp >= skill.mp_cost;
          const isCasting = castingId === skill.id;

          return (
            <motion.div
              key={skill.id}
              initial={{ opacity: 0, y: 40, rotateX: -20 }}
              animate={{ opacity: 1, y: 0, rotateX: 0 }}
              transition={{ duration: 0.5, delay: 0.08 * i, type: 'spring', stiffness: 80 }}
              whileHover={canCast ? { scale: 1.03, y: -8 } : {}}
              onClick={() => canCast && setSelectedSkill(selectedSkill?.id === skill.id ? null : skill)}
              className={`system-panel p-6 border-2 rounded-2xl cursor-pointer transition-all ${
                canCast
                  ? 'border-glow-purple/50 hover:border-glow-purple hover:shadow-[0_0_50px_rgba(176,38,255,0.3)]'
                  : 'border-gray-700 opacity-75'
              }`}
              style={{ perspective: 1000 }}
            >
              <motion.div
                className="absolute -right-10 -top-10 w-40 h-40 bg-glow-purple/20 rounded-full blur-3xl"
                animate={{ scale: [1, 1.3, 1], opacity: [0.3, 0.6, 0.3] }}
                transition={{ duration: 4, repeat: Infinity }}
              />
              <motion.div
                className="absolute inset-0 bg-gradient-to-b from-glow-purple/5 to-transparent rounded-2xl"
                animate={selectedSkill?.id === skill.id ? { opacity: 1 } : { opacity: 0 }}
              />

              <div className="relative z-10">
                <div className="flex justify-between items-start mb-3">
                  <h3 className="text-xl font-system text-white tracking-wider group-hover:text-glow-purple">
                    {skill.name}
                  </h3>
                  <motion.div
                    className="px-3 py-1 rounded-lg font-system text-sm bg-mp-blue/20 border border-mp-blue/50 text-mp-blue"
                    animate={!canCast ? { opacity: [1, 0.5, 1] } : {}}
                    transition={{ duration: 1.5, repeat: Infinity }}
                  >
                    {skill.mp_cost} MP
                  </motion.div>
                </div>

                <p className="text-gray-400 text-sm mb-6 min-h-[3rem] leading-relaxed">
                  {skill.description}
                </p>

                <motion.button
                  onClick={(e) => {
                    e.stopPropagation();
                    canCast && handleCast(skill.id);
                  }}
                  disabled={!canCast || isCasting}
                  whileHover={canCast && !isCasting ? { scale: 1.05, boxShadow: '0 0 30px rgba(176, 38, 255, 0.5)' } : {}}
                  whileTap={canCast && !isCasting ? { scale: 0.95 } : {}}
                  className={`w-full py-3 font-system uppercase tracking-widest rounded-xl border-2 transition-all ${
                    canCast && !isCasting
                      ? 'border-glow-purple text-glow-purple hover:bg-glow-purple hover:text-black'
                      : 'border-gray-700 text-gray-600 cursor-not-allowed bg-black/40'
                  }`}
                >
                  {isCasting ? (
                    <motion.span
                      animate={{ rotate: 360 }}
                      transition={{ duration: 1, repeat: Infinity, ease: 'linear' }}
                      className="inline-flex items-center justify-center gap-2"
                    >
                      <span className="w-5 h-5 border-2 border-glow-purple border-t-transparent rounded-full" />
                      Casting...
                    </motion.span>
                  ) : (
                    'Cast Skill'
                  )}
                </motion.button>
              </div>
            </motion.div>
          );
        })}
      </div>

      {skills.length === 0 && (
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          className="border-2 border-dashed border-gray-600 rounded-2xl p-16 text-center"
        >
          <motion.span
            animate={{ scale: [1, 1.2, 1], rotate: [0, 10, -10, 0] }}
            transition={{ duration: 3, repeat: Infinity }}
            className="text-6xl block mb-4"
          >
            ✦
          </motion.span>
          <p className="text-xl text-gray-500 font-system">No skills unlocked</p>
          <p className="text-sm text-gray-600 mt-2">Level up and allocate stat points to unlock abilities.</p>
        </motion.div>
      )}
    </div>
  );
}
