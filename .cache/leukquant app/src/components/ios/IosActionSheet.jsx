// src/components/ios/IosActionSheet.jsx
import React from 'react';
import sounds from '../../utils/soundEffects';

export default function IosActionSheet({
  isOpen,
  onClose,
  title,
  message,
  actions = [],
  cancelText = "Cancel"
}) {
  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-end justify-center px-3 pb-8">
      {/* Backdrop */}
      <div
        className="fixed inset-0 bg-black/60 dark:bg-black/80 backdrop-blur-md animate-in fade-in duration-150"
        onClick={() => {
          sounds.playTap();
          onClose();
        }}
      />

      {/* Action Container */}
      <div className="relative w-full max-w-[400px] z-10 space-y-2.5 animate-in slide-in-from-bottom duration-250">
        {/* Actions Block */}
        <div className="rounded-[24px] ios26-glass-thick overflow-hidden shadow-2xl border border-white/25">
          {(title || message) && (
            <div className="px-4 py-3.5 text-center border-b border-black/[0.06] dark:border-white/[0.08]">
              {title && (
                <div className="text-[13px] font-bold text-[#8E8E93] dark:text-[#9BA1B0] tracking-tight">
                  {title}
                </div>
              )}
              {message && (
                <div className="text-[13px] text-[#8E8E93] dark:text-[#9BA1B0] mt-1 leading-snug font-medium">
                  {message}
                </div>
              )}
            </div>
          )}

          {actions.map((action, idx) => (
            <button
              key={idx}
              type="button"
              onClick={() => {
                sounds.playPop();
                action.onClick?.();
                onClose();
              }}
              className={`w-full py-4 px-4 text-center text-[19px] tracking-tight transition-colors active:bg-black/10 dark:active:bg-white/10 border-b border-black/[0.06] dark:border-white/[0.08] last:border-b-0 focus:outline-none ${
                action.destructive
                  ? 'text-ios-red dark:text-red-400 font-bold'
                  : 'text-ios-blue dark:text-sky-400 font-medium'
              }`}
            >
              {action.label}
            </button>
          ))}
        </div>

        {/* Cancel Button Block */}
        <div className="rounded-[24px] ios26-glass-thick overflow-hidden shadow-2xl border border-white/25">
          <button
            type="button"
            onClick={() => {
              sounds.playTap();
              onClose();
            }}
            className="w-full py-3.5 px-4 text-center text-[19px] font-bold text-ios-blue dark:text-sky-400 active:bg-black/10 dark:active:bg-white/10 focus:outline-none"
          >
            {cancelText}
          </button>
        </div>
      </div>
    </div>
  );
}
