import React from 'react';
import { Outlet, NavLink } from 'react-router-dom';
import { motion } from 'framer-motion';
import FloatingParticles from './FloatingParticles';

const navItems = [
  { path: '/', label: 'Dashboard', icon: '◈' },
  { path: '/quests', label: 'Quests', icon: '⚔' },
  { path: '/inventory', label: 'Inventory', icon: '◆' },
  { path: '/skills', label: 'Skills', icon: '✦' },
];

export default function Layout() {
  return (
    <div className="min-h-screen relative scanlines">
      <FloatingParticles />
      
      {/* Navigation */}
      <motion.nav
        initial={{ y: -80 }}
        animate={{ y: 0 }}
        transition={{ duration: 0.5 }}
        className="sticky top-0 z-50 bg-black/80 backdrop-blur-xl border-b border-white/10"
      >
        <div className="max-w-6xl mx-auto px-4 py-3 flex items-center justify-between">
          <NavLink to="/" className="font-system text-neon-blue tracking-widest font-bold text-lg hover:opacity-80 transition-opacity">
            SOLO LEVELING
          </NavLink>
          <div className="flex flex-wrap gap-1 justify-end">
            {navItems.map(({ path, label, icon }) => (
              <NavLink
                key={path}
                to={path}
                className={({ isActive }) =>
                  `px-4 py-2 rounded-lg font-system text-sm uppercase tracking-wider transition-all duration-300 ${
                    isActive
                      ? 'bg-neon-blue/20 text-neon-blue border border-neon-blue/50 shadow-[0_0_15px_rgba(0,210,255,0.3)]'
                      : 'text-gray-400 hover:text-white hover:bg-white/5 border border-transparent'
                  }`
                }
              >
                <span className="mr-2 opacity-70">{icon}</span>
                {label}
              </NavLink>
            ))}
          </div>
        </div>
      </motion.nav>

      <main className="relative z-10">
        <Outlet />
      </main>

      <motion.div
        className="fixed bottom-0 left-0 w-full h-1 z-[9998]"
        initial={{ scaleX: 0 }}
        animate={{ scaleX: 1 }}
        transition={{ duration: 1 }}
        style={{ transformOrigin: 'left' }}
      >
        <div className="absolute inset-0 bg-gradient-to-r from-transparent via-neon-blue to-transparent shadow-[0_0_20px_#00d2ff]" />
      </motion.div>
    </div>
  );
}
