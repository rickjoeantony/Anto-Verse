import React from 'react';
import { motion } from 'framer-motion';
import { useApp } from '../context/AppContext';
import QuestLog from '../components/QuestLog';
import Notification from '../components/Notification';

export default function Quests() {
  const {
    tasks,
    handleCompleteTask,
    handleCreateTask,
    handleUpdateTask,
    handleDeleteTask,
  } = useApp();

  return (
    <div className="max-w-6xl mx-auto p-4 md:p-8">
      <motion.header
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        className="text-center mb-10"
      >
        <h1 className="text-4xl font-system text-white tracking-widest mb-2">QUEST LOG</h1>
        <p className="text-gray-500 font-system text-sm tracking-wider">Create, Edit & Complete Quests</p>
      </motion.header>

      <Notification />

      <QuestLog
        tasks={tasks}
        onCompleteTask={handleCompleteTask}
        onCreateTask={handleCreateTask}
        onUpdateTask={handleUpdateTask}
        onDeleteTask={handleDeleteTask}
        compact={false}
      />
    </div>
  );
}
