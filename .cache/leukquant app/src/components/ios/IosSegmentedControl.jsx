// src/components/ios/IosSegmentedControl.jsx
import React from 'react';
import sounds from '../../utils/soundEffects';

export default function IosSegmentedControl({
  options = [],
  value,
  onChange,
  className = ""
}) {
  const activeIndex = options.findIndex((opt) => (typeof opt === 'string' ? opt : opt.value) === value);

  return (
    <div className={`relative p-1 bg-black/[0.06] dark:bg-white/[0.08] backdrop-blur-xl border border-white/20 dark:border-white/10 rounded-[14px] flex items-center shadow-inner ${className}`}>
      {/* Sliding Liquid Glass Active Capsule */}
      {activeIndex >= 0 && (
        <div
          className="absolute top-1 bottom-1 rounded-[11px] bg-white dark:bg-white/20 shadow-[0_3px_12px_rgba(0,0,0,0.15)] border border-white/80 dark:border-white/25 transition-all duration-250 ease-out pointer-events-none"
          style={{
            width: `calc(${100 / options.length}% - 4px)`,
            left: `calc(${(activeIndex * 100) / options.length}% + 2px)`
          }}
        />
      )}

      {/* Segment Buttons */}
      {options.map((option) => {
        const optionValue = typeof option === 'string' ? option : option.value;
        const optionLabel = typeof option === 'string' ? option : option.label;
        const isSelected = optionValue === value;

        return (
          <button
            key={optionValue}
            type="button"
            onClick={() => {
              sounds.playTap();
              onChange(optionValue);
            }}
            className={`relative z-10 flex-1 py-1.5 px-2.5 text-[13px] font-semibold text-center truncate rounded-[11px] transition-all duration-150 ios-press-spring focus:outline-none ${
              isSelected
                ? 'text-black dark:text-white font-bold'
                : 'text-black/60 dark:text-white/60 hover:text-black dark:hover:text-white'
            }`}
          >
            {optionLabel}
          </button>
        );
      })}
    </div>
  );
}
