import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';

const CATEGORIES = [
  { value: 'workout', label: 'Workout', stat: '+STR, VIT' },
  { value: 'coding', label: 'Coding', stat: '+INT' },
  { value: 'studying', label: 'Studying', stat: '+INT' },
  { value: 'reading', label: 'Reading', stat: '+PER' },
  { value: 'meditating', label: 'Meditating', stat: '+PER' },
  { value: 'creative', label: 'Creative', stat: '+INT, PER' },
  { value: 'social', label: 'Social', stat: '+PER' },
];

export default function QuestLog({
  tasks,
  onCompleteTask,
  onCreateTask,
  onUpdateTask,
  onDeleteTask,
  onStartDeepQuest,
  compact = false,
}) {
  const [newTask, setNewTask] = useState({
    title: '',
    description: '',
    category: 'coding',
    exp_reward: 50,
    is_daily: false,
  });
  const [editingId, setEditingId] = useState(null);
  const [editForm, setEditForm] = useState({});
  const [completingId, setCompletingId] = useState(null);

  const handleCreate = (e) => {
    e.preventDefault();
    if (!newTask.title.trim()) return;
    onCreateTask(newTask);
    setNewTask({ title: '', description: '', category: 'coding', exp_reward: 50, is_daily: false });
  };

  const handleEdit = (task) => {
    setEditingId(task.id);
    setEditForm({
      title: task.title,
      description: task.description || '',
      category: task.category,
      exp_reward: task.exp_reward,
      is_daily: task.is_daily,
    });
  };

  const handleSaveEdit = async () => {
    if (!editingId) return;
    await onUpdateTask?.(editingId, editForm);
    setEditingId(null);
  };

  const handleComplete = async (taskId) => {
    setCompletingId(taskId);
    await onCompleteTask(taskId);
    setCompletingId(null);
  };

  const dailyQuests = tasks.filter(t => t.is_daily);
  const standardQuests = tasks.filter(t => !t.is_daily);

  const QuestItem = ({ task, index }) => {
    // Basic 3D effect calculation states
    const [rotateX, setRotateX] = useState(0);
    const [rotateY, setRotateY] = useState(0);

    const handleMouseMove = (e) => {
      if (task.completed) return;
      const rect = e.currentTarget.getBoundingClientRect();
      const x = e.clientX - rect.left;
      const y = e.clientY - rect.top;
      const centerX = rect.width / 2;
      const centerY = rect.height / 2;
      const rotateX = ((y - centerY) / centerY) * -10;
      const rotateY = ((x - centerX) / centerX) * 10;
      setRotateX(rotateX);
      setRotateY(rotateY);
    };

    const handleMouseLeave = () => {
      setRotateX(0);
      setRotateY(0);
    };

    return (
      <motion.div
        layout
      initial={{ opacity: 0, y: 20, scale: 0.95 }}
      animate={{ opacity: 1, y: 0, scale: 1 }}
        transition={{ delay: index * 0.05 }}
        exit={{ opacity: 0, scale: 0.9 }}
        onMouseMove={handleMouseMove}
        onMouseLeave={handleMouseLeave}
        className={`card-3d relative rounded-xl transition-all duration-300 ${
          task.completed ? 'bg-black/40 border-gray-800/80 opacity-70 border' : 'bg-transparent'
        }`}
      >
        <motion.div 
          className={`relative p-4 flex flex-col xl:flex-row justify-between items-start xl:items-center gap-4 rounded-xl border z-10 ${
             task.completed ? 'border-transparent' : 'bg-white/[0.04] border-neon-blue/25 card-3d-inner'
          }`}
          animate={{
            rotateX: rotateX,
            rotateY: rotateY,
            boxShadow: rotateX || rotateY ? `0 20px 40px rgba(0,210,255,0.15), inset 0 0 20px rgba(0,210,255,0.05)` : `0 0 0 rgba(0,0,0,0)`
          }}
          style={{ transformPerspective: 1000 }}
        >
          {/* Background Layer with Overflow Hidden */}
          <div className="absolute inset-0 rounded-xl overflow-hidden z-0 pointer-events-none">
          {/* subtle background glow */}
          {!task.completed && (rotateX !== 0 || rotateY !== 0) && (
            <div 
              className="absolute inset-0 z-0 opacity-50"
              style={{
                background: `radial-gradient(circle at ${50 + rotateY * 2}% ${50 - rotateX * 2}%, rgba(0,210,255,0.15) 0%, transparent 60%)`
              }}
            />
          )}
          </div>

          <div className="flex-1 min-w-0 relative z-10 transition-transform duration-200" style={{ transform: (rotateX || rotateY) ? 'translateZ(20px)' : 'none' }}>
          <h4 className={`font-system text-lg ${task.completed ? 'text-gray-500 line-through' : 'text-white'}`}>
            {task.title}
          </h4>
          {task.description && (
            <p className="text-gray-500 text-sm mt-1 line-clamp-2">{task.description}</p>
          )}
          <div className="flex gap-2 mt-2 flex-wrap">
            <span className="text-xs uppercase text-glow-purple bg-glow-purple/10 px-2 py-0.5 rounded font-system border border-glow-purple/20">
              {task.category}
            </span>
            <span className="text-xs text-gold-accent font-system">+{task.exp_reward} EXP</span>
          </div>
        </div>
        <div className="flex flex-wrap gap-2 shrink-0 relative z-10 w-full xl:w-auto mt-2 xl:mt-0 justify-start xl:justify-end border-t xl:border-none border-white/5 pt-3 xl:pt-0">
          {!task.completed && onUpdateTask && !compact && (
            <motion.button
              whileHover={{ scale: 1.05, filter: 'brightness(1.2)' }}
              whileTap={{ scale: 0.95 }}
              onClick={() => handleEdit(task)}
              className="relative group px-4 py-1.5 text-xs font-system uppercase tracking-wider text-gray-400 bg-transparent border border-gray-600 skew-x-[-15deg] hover:border-neon-blue hover:text-white transition-all overflow-hidden"
            >
              <div className="absolute inset-0 bg-neon-blue/10 -translate-x-full group-hover:translate-x-0 transition-transform duration-300 pointer-events-none" />
              <span className="block skew-x-[15deg] relative z-10">Edit</span>
            </motion.button>
          )}
          {!task.completed && onDeleteTask && !compact && (
            <motion.button
              whileHover={{ scale: 1.05, filter: 'brightness(1.2)', boxShadow: '0 0 15px rgba(255, 0, 0, 0.3)' }}
              whileTap={{ scale: 0.95 }}
              onClick={() => onDeleteTask(task.id)}
              className="relative group px-4 py-1.5 text-xs font-system uppercase tracking-wider text-red-400 bg-transparent border border-red-500/50 skew-x-[-15deg] hover:border-red-500 hover:text-white transition-all overflow-hidden"
            >
              <div className="absolute inset-0 bg-red-500/20 -translate-x-full group-hover:translate-x-0 transition-transform duration-300 pointer-events-none" />
              <span className="block skew-x-[15deg] relative z-10">Delete</span>
            </motion.button>
          )}
          {!task.completed && onStartDeepQuest && !compact && (
            <motion.button
              whileHover={{ scale: 1.05, boxShadow: '0 0 20px rgba(255, 51, 51, 0.6)' }}
              whileTap={{ scale: 0.95 }}
              onClick={() => onStartDeepQuest(task)}
              className="relative group px-5 py-1.5 text-xs font-system font-bold uppercase tracking-widest text-hp-red bg-hp-red/10 border-2 border-hp-red skew-x-[-15deg] hover:bg-hp-red hover:text-white transition-all overflow-hidden flex items-center gap-2"
            >
              <div className="absolute inset-0 bg-white/20 -translate-x-full group-hover:translate-x-full transition-transform duration-500 pointer-events-none" />
              <span className="block skew-x-[15deg] relative z-10 flex items-center gap-1.5">
                <svg className="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 10V3L4 14h7v7l9-11h-7z" /></svg>
                DEEP QUEST
              </span>
            </motion.button>
          )}
          {!task.completed && (
            <motion.button
              onClick={() => handleComplete(task.id)}
              disabled={completingId === task.id}
              whileHover={{ scale: 1.05, filter: 'drop-shadow(0 0 8px rgba(0, 210, 255, 0.8))' }}
              whileTap={{ scale: 0.95 }}
              className="relative group px-6 py-2 bg-black/50 border-2 border-neon-blue skew-x-[-15deg] disabled:opacity-50 overflow-hidden"
            >
              <div className="absolute inset-0 bg-neon-blue opacity-0 group-hover:opacity-10 transition-opacity pointer-events-none" />
              <div className="absolute left-0 top-0 w-1 h-full bg-neon-blue group-hover:w-full transition-all duration-300 ease-out z-0" />
              <span className="block skew-x-[15deg] relative z-10 text-neon-blue group-hover:text-black font-system font-bold text-xs uppercase tracking-widest transition-colors duration-300">
                {completingId === task.id ? (
                  <motion.span
                    animate={{ rotate: 360 }}
                    transition={{ duration: 1, repeat: Infinity, ease: 'linear' }}
                    className="inline-block w-4 h-4 border-2 border-current border-t-transparent rounded-full"
                  />
                ) : (
                  'Complete'
                )}
              </span>
            </motion.button>
          )}
          {task.completed && (
            <span className="text-neon-blue font-system text-sm uppercase flex items-center gap-1.5 skew-x-[-15deg] border border-neon-blue/30 bg-neon-blue/5 px-4 py-1.5 backdrop-blur-sm">
              <span className="block skew-x-[15deg] flex items-center gap-1.5">
                <svg className="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                  <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clipRule="evenodd" />
                </svg>
                Cleared
              </span>
            </span>
          )}
        </div>
      </motion.div>
    </motion.div>
  );
};

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      className={`w-full max-w-6xl mx-auto mt-8 flex flex-col ${compact ? '' : 'md:flex-row'} gap-8 pb-12`}
    >
      <div className="flex-1">
        <h3 className="text-xl text-hp-red font-system uppercase tracking-widest mb-4 glow-text">Daily Quests</h3>
        <div className="mb-8 space-y-3">
          <AnimatePresence mode="popLayout">
            {dailyQuests.length === 0 ? (
              <p className="text-gray-500 font-system italic text-sm py-4">No daily quests assigned.</p>
            ) : (
              dailyQuests.map((task, i) => <QuestItem key={task.id} task={task} index={i} />)
            )}
          </AnimatePresence>
        </div>

        <h3 className="text-xl text-white font-system uppercase tracking-widest mb-4">Standard Quests</h3>
        <div className="space-y-3">
          <AnimatePresence mode="popLayout">
            {standardQuests.length === 0 ? (
              <p className="text-gray-500 font-system italic text-sm py-4">No standard quests available.</p>
            ) : (
              standardQuests.map((task, i) => <QuestItem key={task.id} task={task} index={i + dailyQuests.length} />)
            )}
          </AnimatePresence>
        </div>
      </div>

      {!compact && onCreateTask && (
        <motion.div
          initial={{ opacity: 0, x: 20 }}
          animate={{ opacity: 1, x: 0 }}
          className="w-full md:w-96"
        >
          <div className="system-panel p-6 sticky top-24">
            <h3 className="text-lg text-neon-blue font-system uppercase mb-4 tracking-wider">Assign / Edit Quest</h3>

            {editingId ? (
              <div className="space-y-4">
                <div>
                  <label className="block text-xs text-gray-400 font-system uppercase mb-1">Objective</label>
                  <input
                    type="text"
                    value={editForm.title}
                    onChange={e => setEditForm({ ...editForm, title: e.target.value })}
                    className="w-full bg-black/50 border border-white/20 rounded-lg px-3 py-2.5 text-white"
                  />
                </div>
                <div>
                  <label className="block text-xs text-gray-400 font-system uppercase mb-1">Description (optional)</label>
                  <textarea
                    value={editForm.description}
                    onChange={e => setEditForm({ ...editForm, description: e.target.value })}
                    rows={2}
                    className="w-full bg-black/50 border border-white/20 rounded-lg px-3 py-2.5 text-white resize-none"
                  />
                </div>
                <div>
                  <label className="block text-xs text-gray-400 font-system uppercase mb-1">Category</label>
                  <select
                    value={editForm.category}
                    onChange={e => setEditForm({ ...editForm, category: e.target.value })}
                    className="w-full bg-black/50 border border-white/20 rounded-lg px-3 py-2.5 text-white"
                  >
                    {CATEGORIES.map(c => (
                      <option key={c.value} value={c.value}>{c.label} ({c.stat})</option>
                    ))}
                  </select>
                </div>
                <div>
                  <label className="block text-xs text-gray-400 font-system uppercase mb-1">EXP Reward</label>
                  <input
                    type="number"
                    min={5}
                    max={500}
                    value={editForm.exp_reward}
                    onChange={e => setEditForm({ ...editForm, exp_reward: +e.target.value || 10 })}
                    className="w-full bg-black/50 border border-white/20 rounded-lg px-3 py-2.5 text-white"
                  />
                </div>
                <div className="flex items-center gap-2">
                  <input
                    type="checkbox"
                    id="editDaily"
                    checked={editForm.is_daily}
                    onChange={e => setEditForm({ ...editForm, is_daily: e.target.checked })}
                    className="accent-neon-blue w-4 h-4"
                  />
                  <label htmlFor="editDaily" className="text-sm text-gray-300">Recurring Daily</label>
                </div>
                <div className="flex gap-2">
                  <motion.button
                    type="button"
                    onClick={() => setEditingId(null)}
                    whileTap={{ scale: 0.95 }}
                    className="flex-1 py-2 border border-gray-500 text-gray-400 rounded-lg"
                  >
                    Cancel
                  </motion.button>
                  <motion.button
                    type="button"
                    onClick={handleSaveEdit}
                    whileTap={{ scale: 0.95 }}
                    className="flex-1 py-2 bg-neon-blue text-black font-system uppercase rounded-lg"
                  >
                    Save
                  </motion.button>
                </div>
              </div>
            ) : (
              <form onSubmit={handleCreate} className="space-y-4">
                <div>
                  <label className="block text-xs text-gray-400 font-system uppercase mb-1">Objective *</label>
                  <input
                    type="text"
                    value={newTask.title}
                    onChange={e => setNewTask({ ...newTask, title: e.target.value })}
                    placeholder="E.g., 100 Pushups"
                    className="w-full bg-black/50 border border-white/20 rounded-lg px-3 py-2.5 text-white"
                    required
                  />
                </div>
                <div>
                  <label className="block text-xs text-gray-400 font-system uppercase mb-1">Description (optional)</label>
                  <textarea
                    value={newTask.description}
                    onChange={e => setNewTask({ ...newTask, description: e.target.value })}
                    placeholder="Add details..."
                    rows={2}
                    className="w-full bg-black/50 border border-white/20 rounded-lg px-3 py-2.5 text-white resize-none"
                  />
                </div>
                <div>
                  <label className="block text-xs text-gray-400 font-system uppercase mb-1">Category</label>
                  <select
                    value={newTask.category}
                    onChange={e => setNewTask({ ...newTask, category: e.target.value })}
                    className="w-full bg-black/50 border border-white/20 rounded-lg px-3 py-2.5 text-white"
                  >
                    {CATEGORIES.map(c => (
                      <option key={c.value} value={c.value}>{c.label} ({c.stat})</option>
                    ))}
                  </select>
                </div>
                <div>
                  <label className="block text-xs text-gray-400 font-system uppercase mb-1">EXP Reward</label>
                  <input
                    type="number"
                    min={5}
                    max={500}
                    value={newTask.exp_reward}
                    onChange={e => setNewTask({ ...newTask, exp_reward: +e.target.value || 10 })}
                    className="w-full bg-black/50 border border-white/20 rounded-lg px-3 py-2.5 text-white"
                  />
                </div>
                <div className="flex items-center gap-2">
                  <input
                    type="checkbox"
                    id="isDaily"
                    checked={newTask.is_daily}
                    onChange={e => setNewTask({ ...newTask, is_daily: e.target.checked })}
                    className="accent-neon-blue w-4 h-4"
                  />
                  <label htmlFor="isDaily" className="text-sm text-gray-300">Recurring Daily Quest</label>
                </div>
                <motion.button
                  type="submit"
                  whileHover={{ scale: 1.02 }}
                  whileTap={{ scale: 0.98 }}
                  className="w-full py-3 bg-neon-blue/10 border-2 border-neon-blue text-neon-blue hover:bg-neon-blue hover:text-black font-system uppercase rounded-lg transition-all"
                >
                  System.Register()
                </motion.button>
              </form>
            )}
          </div>
        </motion.div>
      )}
    </motion.div>
  );
}
