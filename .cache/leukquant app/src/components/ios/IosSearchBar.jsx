// src/components/ios/IosSearchBar.jsx
import React, { useState, useRef } from 'react';
import { Search, X, Mic } from 'lucide-react';
import sounds from '../../utils/soundEffects';

export default function IosSearchBar({
  value,
  onChange,
  placeholder = "Search events, telemetry or reports...",
  onCancel,
  className = ""
}) {
  const [isFocused, setIsFocused] = useState(false);
  const inputRef = useRef(null);

  const handleClear = () => {
    sounds.playTap();
    onChange('');
    inputRef.current?.focus();
  };

  const handleCancelClick = () => {
    sounds.playTap();
    onChange('');
    setIsFocused(false);
    inputRef.current?.blur();
    if (onCancel) onCancel();
  };

  return (
    <div className={`px-4 py-2 flex items-center transition-all duration-200 ${className}`}>
      {/* Liquid Glass Search Pill */}
      <div className={`relative flex-1 flex items-center ios26-glass rounded-[16px] h-[40px] px-3.5 transition-all shadow-sm ${
        isFocused ? 'ring-2 ring-ios-blue/40 border-ios-blue/50' : ''
      }`}>
        <Search
          size={17}
          strokeWidth={2.4}
          className="text-ios-blue dark:text-sky-400 shrink-0 mr-2.5"
        />

        <input
          ref={inputRef}
          type="text"
          value={value}
          onChange={(e) => onChange(e.target.value)}
          onFocus={() => {
            sounds.playTap();
            setIsFocused(true);
          }}
          onBlur={() => !value && setIsFocused(false)}
          placeholder={placeholder}
          className="w-full bg-transparent text-[15px] font-medium text-black dark:text-white placeholder-[#8E8E93] dark:placeholder-[#8E8E93] focus:outline-none"
        />

        {/* Clear Button */}
        {value ? (
          <button
            type="button"
            onClick={handleClear}
            className="w-5 h-5 rounded-full bg-[#8E8E93]/40 dark:bg-white/20 text-white flex items-center justify-center shrink-0 ml-1.5 focus:outline-none hover:opacity-80"
          >
            <X size={12} strokeWidth={3} />
          </button>
        ) : (
          <Mic size={16} className="text-[#8E8E93] dark:text-[#8E8E93] shrink-0 ml-1 cursor-pointer hover:text-ios-blue transition-colors" />
        )}
      </div>

      {/* Cancel Button */}
      {(isFocused || value) && (
        <button
          type="button"
          onClick={handleCancelClick}
          className="ml-3 text-ios-blue dark:text-sky-400 text-[15px] font-semibold ios-press-spring shrink-0 focus:outline-none animate-in fade-in slide-in-from-right-2 duration-150"
        >
          Cancel
        </button>
      )}
    </div>
  );
}
