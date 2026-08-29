// src/components/ios/IosSwitch.jsx
import React from 'react';
import sounds from '../../utils/soundEffects';

export default function IosSwitch({
  checked = false,
  onChange,
  disabled = false,
  color = "bg-ios-green",
  className = ""
}) {
  const handleClick = (e) => {
    e.stopPropagation();
    if (!disabled && onChange) {
      if (!checked) {
        sounds.playSwitchOn();
      } else {
        sounds.playSwitchOff();
      }
      onChange(!checked);
    }
  };

  return (
    <button
      type="button"
      role="switch"
      aria-checked={checked}
      disabled={disabled}
      onClick={handleClick}
      className={`relative inline-flex h-[32px] w-[52px] shrink-0 cursor-pointer rounded-full p-[2px] transition-all duration-250 ease-out focus:outline-none border border-white/20 shadow-inner ${
        checked
          ? `${color} shadow-[0_0_12px_rgba(52,199,89,0.4)]`
          : 'bg-black/15 dark:bg-white/15'
      } ${disabled ? 'opacity-40 cursor-not-allowed' : ''} ${className}`}
    >
      {/* Moving Liquid Thumb */}
      <span
        className={`pointer-events-none inline-block h-[26px] w-[26px] rounded-full bg-white shadow-[0_3px_8px_rgba(0,0,0,0.25)] border border-white/80 transition-transform duration-250 ease-[cubic-bezier(0.34,1.56,0.64,1)] ${
          checked ? 'translate-x-[20px]' : 'translate-x-0'
        }`}
      />
    </button>
  );
}
