import React from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { useApp } from '../context/AppContext';
import StatusWindow from '../components/StatusWindow';
import QuestLog from '../components/QuestLog';
import Notification from '../components/Notification';

export default function Dashboard() {
  const { user, tasks, loading, handleCompleteTask, handleCreateTask } = useApp();

  if (loading && !user) {
    return (
      <div className="min-h-[80vh] flex items-center justify-center">
        <motion.div
          animate={{ rotate: 360 }}
          transition={{ duration: 2, repeat: Infinity, ease: 'linear' }}
          className="w-16 h-16 border-2 border-neon-blue border-t-transparent rounded-full"
        />
      </div>
    );
  }

  return (
    <div className="max-w-6xl mx-auto p-4 md:p-8">
      <motion.header
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        className="text-center mb-10"
      >
        <h1 className="text-4xl font-system text-white tracking-widest mb-2">
          DASHBOARD
        </h1>
        <p className="text-gray-500 font-system text-sm tracking-wider">Status & Active Quests</p>
      </motion.header>

      <Notification />
      
      <StatusWindow />
      <QuestLog tasks={tasks} onCompleteTask={handleCompleteTask} onCreateTask={handleCreateTask} compact />
    </div>
  );
}
