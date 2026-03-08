import React from 'react';
import { motion } from 'framer-motion';

// Item-specific emojis for visual appeal
const ITEM_EMOJIS = {
  weapon: { default: '🗡️', sword: '⚔️', blade: '🗡️', scythe: '🔱', dagger: '🔪', longsword: '⚔️' },
  stone: { default: '💎', mana: '💠', crystal: '💠', enhancement: '💎' },
  consumable: { default: '✦', potion: '🧪', elixir: '✨', bread: '🍞' },
  material: { default: '◎', tooth: '🦷', horn: '📯', feather: '🪶', ore: '⛏️' },
};

function getItemEmoji(item) {
  const name = (item.name || '').toLowerCase();
  const type = item.item_type || 'material';
  const typeMap = ITEM_EMOJIS[type] || ITEM_EMOJIS.material;
  if (name.includes('blade') || name.includes('sword')) return typeMap.sword || typeMap.default;
  if (name.includes('scythe')) return typeMap.scythe || typeMap.default;
  if (name.includes('dagger')) return typeMap.dagger || typeMap.default;
  if (name.includes('stone') || name.includes('crystal')) return ITEM_EMOJIS.stone?.mana || '💎';
  if (name.includes('enhancement')) return '💎';
  if (name.includes('potion') || name.includes('elixir')) return name.includes('elixir') ? '✨' : '🧪';
  if (name.includes('bread')) return '🍞';
  if (name.includes('tooth')) return '🦷';
  if (name.includes('horn')) return '📯';
  if (name.includes('feather')) return '🪶';
  if (name.includes('ore')) return '⛏️';
  return typeMap?.default || '◎';
}

const InventoryList = ({ items }) => {
  const getRarityStyles = (rarity) => {
    switch (rarity) {
      case 'Common':
        return {
          border: 'border-gray-500',
          text: 'text-gray-300',
          bg: 'bg-gray-500/10',
          glow: 'shadow-[0_0_15px_rgba(107,114,128,0.2)]',
          animate: false,
          pulseColor: null,
        };
      case 'Rare':
        return {
          border: 'border-blue-400',
          text: 'text-blue-300',
          bg: 'bg-blue-500/10',
          glow: 'shadow-[0_0_20px_rgba(96,165,250,0.3)]',
          animate: false,
          pulseColor: null,
        };
      case 'Epic':
        return {
          border: 'border-purple-500',
          text: 'text-purple-400',
          bg: 'bg-purple-500/10',
          glow: 'shadow-[0_0_25px_rgba(168,85,247,0.4)]',
          animate: false,
          pulseColor: null,
        };
      case 'Legendary':
        return {
          border: 'border-orange-500',
          text: 'text-orange-400',
          bg: 'bg-orange-500/10',
          glow: 'shadow-[0_0_30px_rgba(249,115,22,0.5)]',
          animate: true,
          pulseColor: '249, 115, 22',
        };
      case 'S-Rank':
        return {
          border: 'border-red-500',
          text: 'text-red-500',
          bg: 'bg-red-500/10',
          glow: 'shadow-[0_0_35px_rgba(239,68,68,0.6)]',
          animate: true,
          pulseColor: '239, 68, 68',
        };
      default:
        return {
          border: 'border-gray-500',
          text: 'text-gray-300',
          bg: 'bg-gray-500/10',
          glow: '',
          animate: false,
          pulseColor: null,
        };
    }
  };

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.5, delay: 0.35 }}
      className="w-full max-w-4xl mx-auto mt-12 mb-12"
    >
      <motion.h3
        initial={{ opacity: 0, x: -10 }}
        animate={{ opacity: 1, x: 0 }}
        transition={{ delay: 0.4 }}
        className="text-2xl text-gold-accent font-system uppercase tracking-[0.2em] mb-6 glow-text-gold relative inline-block"
      >
        Inventory
        <motion.span
          className="absolute -bottom-2 left-0 h-0.5 bg-gradient-to-r from-gold-accent to-transparent"
          initial={{ scaleX: 0 }}
          animate={{ scaleX: 1 }}
          transition={{ duration: 0.6, delay: 0.5 }}
          style={{ width: '60%', transformOrigin: 'left' }}
        />
      </motion.h3>

      <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
        {items.map((item, i) => {
          const styles = getRarityStyles(item.rarity);
          return (
            <motion.div
              key={item.id}
              initial={{ opacity: 0, scale: 0.8, rotateY: 15 }}
              animate={{ opacity: 1, scale: 1, rotateY: 0 }}
              transition={{
                duration: 0.5,
                delay: 0.05 * i,
                ease: [0.22, 1, 0.36, 1],
              }}
              whileHover={{
                y: -8,
                scale: 1.05,
                rotateY: 5,
                transition: { duration: 0.2 },
              }}
              className={`system-panel p-4 border-2 ${styles.border} ${styles.bg} ${styles.glow} group relative overflow-hidden cursor-default`}
              style={{
                transformStyle: 'preserve-3d',
                perspective: 1000,
              }}
            >
              {/* Shimmer effect on hover */}
              <motion.div
                className="absolute inset-0 bg-gradient-to-r from-transparent via-white/10 to-transparent -translate-x-full group-hover:translate-x-full pointer-events-none"
                transition={{ duration: 0.6 }}
              />
              {/* Rarity pulse for legendary/S-Rank */}
              {styles.animate && styles.pulseColor && (
                <motion.div
                  className="absolute inset-0 rounded-xl pointer-events-none"
                  animate={{
                    boxShadow: [
                      `0 0 20px rgba(${styles.pulseColor}, 0.3)`,
                      `0 0 40px rgba(${styles.pulseColor}, 0.5)`,
                      `0 0 20px rgba(${styles.pulseColor}, 0.3)`,
                    ],
                  }}
                  transition={{ duration: 2, repeat: Infinity }}
                />
              )}

              <div className="relative z-10">
                <motion.span
                  className="text-5xl block mb-2"
                  animate={{ scale: [1, 1.1, 1], rotate: [0, 5, -5, 0] }}
                  transition={{ duration: 3, repeat: Infinity }}
                >
                  {getItemEmoji(item)}
                </motion.span>
                <div className="flex justify-between items-start mb-2">
                  <span className={`text-xs uppercase tracking-wider font-system font-bold ${styles.text}`}>
                    {item.rarity}
                  </span>
                  <motion.span
                    className="text-white font-system bg-white/10 px-2 py-0.5 rounded-full text-xs backdrop-blur-md border border-white/20"
                    whileHover={{ scale: 1.1 }}
                  >
                    ×{item.quantity}
                  </motion.span>
                </div>
                <h4 className="text-white font-system text-md tracking-wide mb-2 min-h-[48px] line-clamp-2 font-medium">
                  {item.name}
                </h4>
                <motion.p
                  initial={{ opacity: 0 }}
                  className="text-gray-400 text-xs font-body absolute inset-x-4 bottom-14 bg-black/90 p-2.5 rounded-lg backdrop-blur-md border border-white/10 z-20 opacity-0 group-hover:opacity-100 transition-opacity duration-300 pointer-events-none"
                  style={{ maxHeight: '60px', overflow: 'hidden', textOverflow: 'ellipsis' }}
                >
                  {item.description}
                </motion.p>

                {/* Decorative Sci-Fi Action Button (Appears on Hover) */}
                <motion.button
                  whileHover={{ scale: 1.02, filter: 'brightness(1.2)', boxShadow: `0 0 15px rgba(0, 210, 255, 0.4)` }}
                  whileTap={{ scale: 0.95 }}
                  className="absolute inset-x-4 bottom-4 opacity-0 group-hover:opacity-100 transition-opacity duration-300 z-30 relative group/btn px-4 py-1.5 text-[10px] font-system font-bold uppercase tracking-widest text-neon-blue bg-black/80 border border-neon-blue/50 skew-x-[-15deg] hover:bg-neon-blue hover:text-black overflow-hidden flex items-center justify-center gap-2"
                  onClick={() => console.log('Item interaction placeholder')}
                >
                  <div className="absolute inset-0 bg-white/20 -translate-x-full group-hover/btn:translate-x-full transition-transform duration-500 pointer-events-none" />
                  <span className="block skew-x-[15deg] relative z-10 flex items-center gap-1.5">
                    {item.item_type === 'equipment' || item.item_type === 'weapon' ? 'EQUIP ITEM' : 'USE ITEM'}
                    <svg className="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 10V3L4 14h7v7l9-11h-7z" /></svg>
                  </span>
                </motion.button>
              </div>
            </motion.div>
          );
        })}

        {items.length === 0 && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ delay: 0.3 }}
            className="col-span-full border-2 border-dashed border-gray-600/50 rounded-2xl p-12 text-center text-gray-500 font-system bg-black/30 backdrop-blur-sm"
          >
            <motion.div
              animate={{ y: [0, -5, 0] }}
              transition={{ duration: 2, repeat: Infinity }}
              className="text-4xl mb-4 opacity-50"
            >
              🎒
            </motion.div>
            <p className="text-lg">Inventory is empty.</p>
            <p className="text-sm mt-1">Complete quests to loot items.</p>
          </motion.div>
        )}
      </div>
    </motion.div>
  );
};

export default InventoryList;
