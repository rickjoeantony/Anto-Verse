import React, { useMemo } from 'react';
import { motion } from 'framer-motion';
import { useApp } from '../context/AppContext';
import Notification from '../components/Notification';

const ITEM_ICONS = {
  weapon: '⚔',
  stone: '◆',
  consumable: '✦',
  material: '◎',
};

function getRarityStyles(rarity) {
  const styles = {
    Common: { border: 'border-gray-500', text: 'text-gray-300', glow: 'shadow-[0_0_15px_rgba(107,114,128,0.2)]', pulse: null },
    Rare: { border: 'border-blue-400', text: 'text-blue-300', glow: 'shadow-[0_0_20px_rgba(96,165,250,0.3)]', pulse: null },
    Epic: { border: 'border-purple-500', text: 'text-purple-400', glow: 'shadow-[0_0_25px_rgba(168,85,247,0.4)]', pulse: null },
    Legendary: { border: 'border-orange-500', text: 'text-orange-400', glow: 'shadow-[0_0_30px_rgba(249,115,22,0.5)]', pulse: '249, 115, 22' },
    'S-Rank': { border: 'border-red-500', text: 'text-red-500', glow: 'shadow-[0_0_35px_rgba(239,68,68,0.6)]', pulse: '239, 68, 68' },
  };
  return styles[rarity] || styles.Common;
}

function categorizeItems(items) {
  const type = (item) => item.item_type || 'material';
  const groups = { weapon: [], stone: [], consumable: [], material: [] };
  items.forEach((item) => {
    const t = type(item);
    if (groups[t]) groups[t].push(item);
    else groups.material.push(item);
  });
  return groups;
}

export default function Inventory() {
  const { inventory } = useApp();
  const categorized = useMemo(() => categorizeItems(inventory), [inventory]);

  const typeLabels = {
    weapon: 'Weapons & Arms',
    stone: 'Stones & Crystals',
    consumable: 'Consumables',
    material: 'Materials',
  };

  return (
    <div className="max-w-6xl mx-auto p-4 md:p-8">
      <Notification />

      <motion.header
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        className="text-center mb-12"
      >
        <motion.h1
          className="text-4xl md:text-5xl font-system text-gold-accent tracking-widest mb-2 glow-text-gold"
          animate={{ textShadow: ['0 0 20px rgba(255,215,0,0.5)', '0 0 40px rgba(255,215,0,0.8)', '0 0 20px rgba(255,215,0,0.5)'] }}
          transition={{ duration: 2, repeat: Infinity }}
        >
          INVENTORY
        </motion.h1>
        <p className="text-gray-500 font-system text-sm tracking-wider">Weapons • Stones • Consumables • Materials</p>
      </motion.header>

      <div className="space-y-12">
        {(['weapon', 'stone', 'consumable', 'material']).map((typeKey, sectionIndex) => {
          const items = categorized[typeKey] || [];
          if (items.length === 0) return null;

          return (
            <motion.section
              key={typeKey}
              initial={{ opacity: 0, y: 30 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.1 * sectionIndex }}
            >
              <h2 className="text-xl font-system uppercase tracking-widest mb-6 text-neon-blue flex items-center gap-3">
                <span className="text-2xl">{ITEM_ICONS[typeKey]}</span>
                {typeLabels[typeKey]}
              </h2>
              <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 gap-4">
                {items.map((item, i) => {
                  const styles = getRarityStyles(item.rarity);
                  return (
                    <motion.div
                      key={item.id}
                      initial={{ opacity: 0, scale: 0.8, rotateY: -15 }}
                      animate={{ opacity: 1, scale: 1, rotateY: 0 }}
                      transition={{ delay: 0.05 * i, type: 'spring', stiffness: 100 }}
                      whileHover={{ y: -10, scale: 1.05, rotateY: 5 }}
                      className={`system-panel p-4 border-2 ${styles.border} ${styles.glow} group relative overflow-hidden cursor-default`}
                    >
                      {styles.pulse && (
                        <motion.div
                          className="absolute inset-0 rounded-xl pointer-events-none"
                          animate={{
                            boxShadow: [
                              `0 0 20px rgba(${styles.pulse}, 0.3)`,
                              `0 0 40px rgba(${styles.pulse}, 0.6)`,
                              `0 0 20px rgba(${styles.pulse}, 0.3)`,
                            ],
                          }}
                          transition={{ duration: 2, repeat: Infinity }}
                        />
                      )}
                      <div className="relative z-10 text-center">
                        <motion.span
                          className="text-4xl block mb-2"
                          animate={{ scale: [1, 1.1, 1], rotate: [0, 5, -5, 0] }}
                          transition={{ duration: 3, repeat: Infinity }}
                        >
                          {ITEM_ICONS[item.item_type] || ITEM_ICONS.material}
                        </motion.span>
                        <span className={`text-xs uppercase font-bold ${styles.text}`}>{item.rarity}</span>
                        <h3 className="text-white font-system font-medium mt-1 line-clamp-2 min-h-[2.5rem]">{item.name}</h3>
                        <span className="text-neon-blue font-system text-sm mt-2 inline-block bg-black/40 px-2 py-0.5 rounded">
                          ×{item.quantity}
                        </span>
                        <motion.p
                          initial={{ opacity: 0 }}
                          className="absolute inset-2 flex items-center justify-center bg-black/95 p-3 rounded-lg text-gray-300 text-xs opacity-0 group-hover:opacity-100 transition-opacity duration-300 z-20 border border-white/10"
                        >
                          {item.description}
                        </motion.p>
                      </div>
                    </motion.div>
                  );
                })}
              </div>
            </motion.section>
          );
        })}
      </div>

      {inventory.length === 0 && (
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          className="border-2 border-dashed border-gray-600 rounded-2xl p-16 text-center"
        >
          <motion.span
            animate={{ y: [0, -10, 0] }}
            transition={{ duration: 2, repeat: Infinity }}
            className="text-6xl block mb-4"
          >
            🎒
          </motion.span>
          <p className="text-xl text-gray-500 font-system">Inventory is empty</p>
          <p className="text-sm text-gray-600 mt-2">Complete quests to loot weapons, stones & more!</p>
        </motion.div>
      )}
    </div>
  );
}
