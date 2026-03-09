import React, { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { Radar, RadarChart, PolarGrid, PolarAngleAxis, PolarRadiusAxis, ResponsiveContainer } from 'recharts';

const AnimatedBar = ({ percentage, labelColor, barColor, shadowColor, label, value, max }) => (
  <div className="mb-4">
    <div className="flex justify-between mb-1.5">
      <span className={labelColor}>{label}</span>
      <span className="text-white font-system text-sm">{value} / {max}</span>
    </div>
    <div className="w-full bg-black/50 rounded-full h-2.5 overflow-hidden border border-white/5">
      <motion.div
        className={`h-full rounded-full relative ${barColor}`}
        style={{
          width: `${percentage}%`,
          boxShadow: `0 0 15px ${shadowColor}`,
        }}
        initial={{ width: 0 }}
        animate={{ width: `${percentage}%` }}
        transition={{ duration: 1, ease: [0.22, 1, 0.36, 1] }}
      >
        <div className="absolute inset-0 bg-gradient-to-r from-transparent via-white/20 to-transparent animate-pulse" />
      </motion.div>
    </div>
  </div>
);

export default function StatusWindow({ user, onAssignStat, onUpdateProfile, onSystemReset }) {
  const [isEditing, setIsEditing] = useState(false);
  const [showResetConfirm, setShowResetConfirm] = useState(false);
  const [editForm, setEditForm] = useState({ name: '', title: '', job_class: '' });

  useEffect(() => {
    if (user) {
      // eslint-disable-next-line react-hooks/set-state-in-effect
      setEditForm({ name: user.name, title: user.title, job_class: user.job_class });
    }
  }, [user]);

  if (!user) return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      className="text-neon-blue font-system animate-pulse"
    >
      SYSTEM LOADING...
    </motion.div>
  );

  const handleSaveProfile = () => {
    onUpdateProfile?.(editForm);
    setIsEditing(false);
  };

  const expPercentage = Math.min((user.exp / user.required_exp) * 100, 100);
  const hpPercentage = Math.min((user.hp / user.max_hp) * 100, 100);
  const mpPercentage = Math.min((user.mp / user.max_mp) * 100, 100);

  return (
    <motion.div
      initial={{ opacity: 0, y: 30 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.5, delay: 0.2 }}
      className="system-panel p-6 w-full max-w-4xl mx-auto mt-8 flex flex-col md:flex-row gap-8"
    >
      {/* Left Column: Profile */}
      <div className="flex-1 border-r border-neon-blue/20 pr-0 md:pr-8 relative">
        <div className="flex justify-between items-start mb-4">
          <motion.h2
            initial={{ opacity: 0, x: -10 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ delay: 0.3 }}
            className="text-3xl glow-text text-neon-blue uppercase tracking-[0.2em]"
          >
            Status
          </motion.h2>
          {!isEditing ? (
            <motion.button
              whileHover={{ scale: 1.05 }}
              whileTap={{ scale: 0.95 }}
              onClick={() => setIsEditing(true)}
              className="text-xs text-neon-blue/60 hover:text-neon-blue underline font-system uppercase transition-colors"
            >
              Edit
            </motion.button>
          ) : (
            <motion.button
              whileHover={{ scale: 1.05 }}
              whileTap={{ scale: 0.95 }}
              onClick={handleSaveProfile}
              className="text-xs text-gold-accent hover:text-white glow-text-gold font-system uppercase bg-black/50 px-2 py-1 rounded border border-gold-accent/50"
            >
              Save
            </motion.button>
          )}
        </div>
        
        <div className="space-y-3 mb-8 text-gray-300 font-system text-sm relative z-10">
          {[
            { key: 'name', label: 'Name', value: user.name, editValue: editForm.name, editKey: 'name' },
            { key: 'level', label: 'Level', value: user.level, isStatic: true },
            { key: 'job_class', label: 'Class', value: user.job_class, editValue: editForm.job_class, editKey: 'job_class' },
            { key: 'title', label: 'Title', value: user.title, editValue: editForm.title, editKey: 'title' },
          ].map((item, i) => (
            <motion.div
              key={item.key}
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ delay: 0.1 * i }}
              className="flex justify-between items-center bg-black/20 hover:bg-black/40 transition-all duration-300 p-2.5 rounded-lg border border-white/5 hover:border-neon-blue/20"
            >
              <span className="text-gray-500 uppercase tracking-wider text-xs">{item.label}</span>
              {isEditing && !item.isStatic && item.editKey ? (
                <input
                  type="text"
                  value={item.editValue}
                  onChange={e => setEditForm({ ...editForm, [item.editKey]: e.target.value })}
                  className="bg-transparent border-b border-neon-blue text-white text-right focus:outline-none focus:shadow-[0_2px_10px_rgba(0,210,255,0.3)] w-32 transition-all"
                />
              ) : (
                <span className={`${item.key === 'level' ? 'text-gold-accent text-xl glow-text-gold font-bold' : 'text-white'} ${item.key === 'name' ? 'text-lg glow-text font-bold' : 'uppercase tracking-wider'}`}>
                  {item.value}
                </span>
              )}
            </motion.div>
          ))}
        </div>

        {/* Animated Bars */}
        <div className="space-y-4 font-system text-xs uppercase">
          <AnimatedBar percentage={hpPercentage} labelColor="text-hp-red" barColor="bg-hp-red" shadowColor="#ff3333" label="HP" value={user.hp} max={user.max_hp} />
          <AnimatedBar percentage={mpPercentage} labelColor="text-mp-blue" barColor="bg-mp-blue" shadowColor="#3388ff" label="MP" value={user.mp} max={user.max_mp} />
          <AnimatedBar percentage={expPercentage} labelColor="text-gold-accent" barColor="bg-gold-accent" shadowColor="#ffd700" label="EXP" value={user.exp} max={user.required_exp} />
        </div>
      </div>

      {/* Right Column: Stats */}
      <div className="flex-1">
        <div className="flex justify-between items-end mb-4">
          <motion.h2
            initial={{ opacity: 0, x: -10 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ delay: 0.4 }}
            className="text-2xl text-white font-system tracking-widest uppercase"
          >
            Stats
          </motion.h2>
          <motion.span
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ delay: 0.5 }}
            className="text-sm font-system text-gray-400"
          >
            Available Points:{' '}
            <span className={`ml-2 text-lg font-bold ${user.available_stat_points > 0 ? 'text-neon-blue glow-text' : 'text-gray-500'}`}>
              {user.available_stat_points}
            </span>
          </motion.span>
        </div>

        <div className="space-y-3 font-system text-sm">
          {[
            { key: 'strength', label: 'STR' },
            { key: 'agility', label: 'AGI' },
            { key: 'sense', label: 'PER' },
            { key: 'vitality', label: 'VIT' },
            { key: 'intelligence', label: 'INT' },
          ].map((stat, i) => (
            <motion.div
              key={stat.key}
              initial={{ opacity: 0, x: 20 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ delay: 0.1 * i + 0.3 }}
              whileHover={{ x: 4, borderColor: 'rgba(0, 210, 255, 0.3)' }}
              className="flex justify-between items-center bg-black/40 p-3 rounded-lg border border-white/5 transition-all duration-300"
            >
              <span className="text-gray-400 w-12">{stat.label}</span>
              <span className="text-white flex-1 text-right mr-4 text-lg font-bold">{user[stat.key]}</span>
              {user.available_stat_points > 0 && (
                <div className="relative group/stat">
                  <motion.button
                    whileHover={{ scale: 1.15, filter: 'drop-shadow(0 0 10px rgba(0, 210, 255, 0.8))' }}
                    whileTap={{ scale: 0.9 }}
                    onClick={() => onAssignStat?.(stat.key)}
                    className="w-8 h-8 rounded-none border border-neon-blue bg-black text-neon-blue flex items-center justify-center font-bold text-lg relative z-10 transition-colors duration-300 overflow-hidden"
                  >
                    <div className="absolute inset-0 bg-neon-blue opacity-0 group-hover/stat:opacity-20 transition-opacity" />
                    +
                  </motion.button>
                  {/* Rotating targeting reticle on hover */}
                  <motion.div 
                    className="absolute -inset-2 border border-neon-blue/0 group-hover/stat:border-neon-blue/50 border-dashed rounded-full pointer-events-none opacity-0 group-hover/stat:opacity-100"
                    animate={{ rotate: 360 }}
                    transition={{ duration: 4, repeat: Infinity, ease: "linear" }}
                  />
                </div>
              )}
            </motion.div>
          ))}
        </div>

        {/* Radar Chart for Stats */}
        <motion.div
          initial={{ opacity: 0, scale: 0.9 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ delay: 0.8, duration: 0.5 }}
          className="mt-8 h-64 w-full relative"
        >
          {/* Subtle background glow for chart */}
          <div className="absolute inset-0 bg-neon-blue/5 rounded-full blur-2xl z-0" />
          
          <ResponsiveContainer width="100%" height="100%" className="relative z-10">
            <RadarChart cx="50%" cy="50%" outerRadius="70%" data={[
              { stat: 'STR', value: user.strength, fullMark: Math.max(20, user.strength + 10) },
              { stat: 'AGI', value: user.agility, fullMark: Math.max(20, user.agility + 10) },
              { stat: 'PER', value: user.sense, fullMark: Math.max(20, user.sense + 10) },
              { stat: 'VIT', value: user.vitality, fullMark: Math.max(20, user.vitality + 10) },
              { stat: 'INT', value: user.intelligence, fullMark: Math.max(20, user.intelligence + 10) },
            ]}>
              <PolarGrid stroke="rgba(0, 210, 255, 0.2)" />
              <PolarAngleAxis dataKey="stat" tick={{ fill: '#00d2ff', fontSize: 10, fontFamily: 'monospace' }} />
              <PolarRadiusAxis angle={30} domain={[0, 'auto']} tick={false} axisLine={false} />
              <Radar
                name="Stats"
                dataKey="value"
                stroke="#00d2ff"
                fill="#00d2ff"
                fillOpacity={0.4}
                isAnimationActive={true}
                animationDuration={1500}
                animationEasing="ease-out"
              />
            </RadarChart>
          </ResponsiveContainer>
        </motion.div>

        {/* System Reawaken (Reset) Button */}
        <div className="mt-12 flex justify-end">
          {!showResetConfirm ? (
            <motion.button
              whileHover={{ scale: 1.05, filter: 'drop-shadow(0 0 15px rgba(255, 51, 51, 0.8))' }}
              whileTap={{ scale: 0.95 }}
              onClick={() => setShowResetConfirm(true)}
              className="relative group px-8 py-2.5 border-2 border-hp-red text-hp-red font-system font-bold uppercase text-sm tracking-widest skew-x-[-15deg] overflow-hidden bg-black/60"
            >
              <div className="absolute inset-0 bg-hp-red opacity-0 group-hover:opacity-10 transition-opacity pointer-events-none" />
              <div className="absolute left-0 top-0 w-1 h-full bg-hp-red group-hover:w-full transition-all duration-300 ease-out z-0" />
              <span className="block skew-x-[15deg] relative z-10 group-hover:text-white transition-colors duration-300">
                SYSTEM REAWAKEN
              </span>
            </motion.button>
          ) : (
            <motion.div 
              initial={{ opacity: 0, x: 20 }}
              animate={{ opacity: 1, x: 0 }}
              className="flex items-center gap-4 bg-black/80 p-3 border border-hp-red/50 shadow-[0_0_20px_rgba(255,51,51,0.2)] backdrop-blur-md"
            >
              <span className="text-hp-red font-system font-bold text-xs uppercase tracking-wider animate-pulse">
                [WARNING] CONFIRM ANNIHILATION?
              </span>
              <button 
                onClick={() => { setShowResetConfirm(false); onSystemReset?.(); }}
                className="px-5 py-2 bg-hp-red text-white font-system font-bold text-xs uppercase hover:bg-red-600 transition-colors skew-x-[-10deg]"
              >
                <span className="block skew-x-[10deg]">ANNIHILATE</span>
              </button>
              <button 
                onClick={() => setShowResetConfirm(false)}
                className="px-5 py-2 border border-gray-500 text-gray-400 font-system text-xs uppercase hover:text-white hover:border-white transition-colors skew-x-[-10deg]"
              >
                <span className="block skew-x-[10deg]">CANCEL</span>
              </button>
            </motion.div>
          )}
        </div>
      </div>
    </motion.div>
  );
}
