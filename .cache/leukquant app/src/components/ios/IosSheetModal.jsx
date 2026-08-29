// src/components/ios/IosSheetModal.jsx
import React, { useEffect } from 'react';
import { X } from 'lucide-react';
import sounds from '../../utils/soundEffects';

export default function IosSheetModal({
  isOpen,
  onClose,
  title,
  subtitle,
  rightButtonText = "Done",
  onRightButton,
  children,
  maxHeight = "max-h-[90vh]",
  showClose = true
}) {
  useEffect(() => {
    if (isOpen) {
      sounds.playPop();
      document.body.style.overflow = 'hidden';
    } else {
      document.body.style.overflow = '';
    }
    return () => {
      document.body.style.overflow = '';
    };
  }, [isOpen]);

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-end justify-center">
      {/* Dimmed Blurred Backdrop */}
      <div
        className="fixed inset-0 bg-black/60 dark:bg-black/80 backdrop-blur-md transition-opacity animate-in fade-in duration-200"
        onClick={() => {
          sounds.playTap();
          onClose();
        }}
      />

      {/* Sheet Container (Liquid Glass) */}
      <div
        className={`relative w-full max-w-[440px] ${maxHeight} flex flex-col ios26-glass-thick rounded-t-[36px] shadow-2xl overflow-hidden z-10 border-t border-x border-white/25 transition-transform animate-in slide-in-from-bottom duration-300 ease-out`}
      >
        {/* Grabber Handle */}
        <div className="pt-3 pb-1 flex justify-center cursor-grab active:cursor-grabbing" onClick={onClose}>
          <div className="w-12 h-1.5 rounded-full bg-black/25 dark:bg-white/30" />
        </div>

        {/* Modal Navigation Header */}
        <div className="px-4 py-2.5 flex items-center justify-between border-b border-black/[0.06] dark:border-white/[0.08]">
          <div className="min-w-[50px]">
            {showClose && (
              <button
                type="button"
                onClick={() => {
                  sounds.playTap();
                  onClose();
                }}
                className="w-8 h-8 rounded-full bg-black/10 dark:bg-white/10 flex items-center justify-center text-black dark:text-white ios-press-spring focus:outline-none"
              >
                <X size={16} strokeWidth={2.5} />
              </button>
            )}
          </div>

          <div className="flex-1 text-center px-2">
            <h3 className="text-[17px] font-bold text-black dark:text-white tracking-tight truncate">
              {title}
            </h3>
            {subtitle && (
              <p className="text-[12px] text-[#8E8E93] dark:text-[#9BA1B0] -mt-0.5 truncate">
                {subtitle}
              </p>
            )}
          </div>

          <div className="min-w-[50px] text-right">
            <button
              type="button"
              onClick={() => {
                sounds.playTap();
                if (onRightButton) onRightButton();
                else onClose();
              }}
              className="text-ios-blue dark:text-sky-400 text-[16px] font-bold ios-press-spring focus:outline-none"
            >
              {rightButtonText}
            </button>
          </div>
        </div>

        {/* Modal Scrollable Body */}
        <div className="flex-1 overflow-y-auto no-scrollbar p-4 space-y-4 pb-12">
          {children}
        </div>
      </div>
    </div>
  );
}
