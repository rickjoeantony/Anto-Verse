import React, { useState } from 'react';
import { motion } from 'framer-motion';

const SkillList = ({ skills, onCastSkill, userMp }) => {
  const [castingId, setCastingId] = useState(null);

  const handleCast = async (skillId) => {
    setCastingId(skillId);
    await onCastSkill(skillId);
    setCastingId(null);
  };

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.5, delay: 0.4 }}
      className="w-full max-w-4xl mx-auto mt-8 mb-12"
    >
      <motion.h3
        initial={{ opacity: 0, x: -10 }}
        animate={{ opacity: 1, x: 0 }}
        transition={{ delay: 0.45 }}
        className="text-2xl text-glow-purple font-system uppercase tracking-[0.2em] mb-6 glow-text"
      >
        Skills & Abilities
      </motion.h3>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {skills.map((skill, i) => {
          const canCast = userMp >= skill.mp_cost;
          const isCasting = castingId === skill.id;

          return (
            <motion.div
              key={skill.id}
              initial={{ opacity: 0, y: 20, rotateY: -10 }}
              animate={{ opacity: 1, y: 0, rotateY: 0 }}
              transition={{ duration: 0.4, delay: 0.1 * i }}
              whileHover={canCast ? {
                y: -5,
                scale: 1.02,
                boxShadow: '0 0 40px rgba(176, 38, 255, 0.3), 0 20px 40px rgba(0,0,0,0.4)',
                transition: { duration: 0.2 },
              } : {}}
              className={`system-panel p-5 border-glow-purple/30 group relative overflow-hidden ${
                canCast ? 'hover:border-glow-purple/60' : 'opacity-75'
              }`}
            >
              {/* Animated background orb */}
              <motion.div
                className="absolute -right-8 -top-8 w-32 h-32 bg-glow-purple/10 rounded-full blur-2xl"
                animate={{
                  scale: [1, 1.2, 1],
                  opacity: [0.3, 0.6, 0.3],
                }}
                transition={{ duration: 3, repeat: Infinity, ease: 'easeInOut' }}
              />
              {/* Scan line effect on hover */}
              {canCast && (
                <motion.div
                  className="absolute inset-0 bg-gradient-to-b from-transparent via-glow-purple/5 to-transparent pointer-events-none"
                  initial={{ y: '-100%' }}
                  whileHover={{ y: '100%' }}
                  transition={{ duration: 0.6 }}
                />
              )}

              <div className="relative z-10">
                <div className="flex justify-between items-start mb-2">
                  <h4 className="text-white font-system text-lg tracking-wider group-hover:text-glow-purple transition-colors duration-300">
                    {skill.name}
                  </h4>
                  <motion.div
                    className="text-mp-blue font-system text-xs bg-mp-blue/20 px-2 py-1 rounded-md border border-mp-blue/30"
                    animate={canCast ? {} : { opacity: [1, 0.6, 1] }}
                    transition={{ duration: 1.5, repeat: Infinity }}
                  >
                    {skill.mp_cost} MP
                  </motion.div>
                </div>

                <p className="text-gray-400 text-sm font-body mb-5 min-h-[40px] leading-relaxed">
                  {skill.description}
                </p>

                <motion.button
                  onClick={() => canCast && handleCast(skill.id)}
                  disabled={!canCast || isCasting}
                  whileHover={canCast && !isCasting ? { scale: 1.05, filter: 'drop-shadow(0 0 10px rgba(176, 38, 255, 0.8))' } : {}}
                  whileTap={canCast && !isCasting ? { scale: 0.95 } : {}}
                  className={`w-full py-2.5 font-system font-bold uppercase tracking-widest text-sm transition-all duration-300 border-2 skew-x-[-15deg] relative group/skill overflow-hidden ${
                    canCast && !isCasting
                      ? 'border-glow-purple text-glow-purple bg-black/50 hover:text-black'
                      : 'border-gray-700 text-gray-600 cursor-not-allowed bg-black/40'
                  }`}
                >
                  {canCast && !isCasting && (
                    <>
                      <div className="absolute inset-0 bg-glow-purple opacity-0 group-hover/skill:opacity-10 transition-opacity pointer-events-none" />
                      <div className="absolute left-0 top-0 w-1 h-full bg-glow-purple group-hover/skill:w-full transition-all duration-300 ease-out z-0" />
                    </>
                  )}
                  <span className={`block skew-x-[15deg] relative z-10 transition-colors duration-300 ${isCasting ? '' : 'group-hover/skill:text-black'}`}>
                    {isCasting ? (
                      <motion.span
                        animate={{ rotate: 360 }}
                        transition={{ duration: 1, repeat: Infinity, ease: 'linear' }}
                        className="inline-flex items-center justify-center gap-2"
                      >
                        <span className="w-4 h-4 border-2 border-current border-t-transparent rounded-full" />
                        CASTING...
                      </motion.span>
                    ) : (
                      'CAST ABILITY'
                    )}
                  </span>
                </motion.button>
              </div>
            </motion.div>
          );
        })}

        {skills.length === 0 && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ delay: 0.3 }}
            className="col-span-full border-2 border-dashed border-gray-600 p-12 text-center text-gray-500 font-system rounded-xl bg-black/20"
          >
            <p className="text-lg mb-2">No active skills acquired yet.</p>
            <p className="text-sm">Level up stats to unlock powerful abilities.</p>
          </motion.div>
        )}
      </div>
    </motion.div>
  );
};

export default SkillList;
