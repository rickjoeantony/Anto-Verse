// src/components/ios/IosNavigationBar.jsx
import React from 'react';
import { ChevronLeft, Sun, Moon, Sliders } from 'lucide-react';
import LeukQuantLogo from '../common/LeukQuantLogo';
import sounds from '../../utils/soundEffects';

export default function IosNavigationBar({
  title,
  subtitle = "iOS 26 Liquid Glass",
  onBack,
  backText = "Back",
  isDark = true,
  onToggleTheme,
  onOpenSettings,
  showLogo = true,
  rightActions,
  className = ""
}) {
  return (
    <header className={`sticky top-0 z-30 w-full transition-all duration-200 ${className}`}>
      {/* Liquid Glass Floating Navigation Bar */}
      <div className="ios26-glass-thick px-4 py-2.5 flex items-center justify-between border-b border-black/[0.05] dark:border-white/[0.08] shadow-[0_4px_24px_rgba(0,0,0,0.06)]">
        {/* Left Section */}
        <div className="flex items-center space-x-3">
          {onBack ? (
            <button
              onClick={() => {
                sounds.playTap();
                onBack();
              }}
              className="flex items-center text-ios-blue dark:text-sky-400 text-[16px] font-medium ios-press-spring -ml-1 px-1 py-1 focus:outline-none"
            >
              <ChevronLeft size={22} strokeWidth={2.5} className="-mr-0.5" />
              <span>{backText}</span>
            </button>
          ) : showLogo ? (
            <div className="relative group cursor-pointer">
              <div className="absolute -inset-0.5 rounded-full bg-gradient-to-r from-ios-blue via-indigo-500 to-sky-400 opacity-60 blur-[3px] group-hover:opacity-100 transition-opacity" />
              <div className="relative w-9 h-9 rounded-full bg-white/90 dark:bg-[#1A2030]/90 border border-white/40 dark:border-white/20 flex items-center justify-center shadow-md backdrop-blur-md">
                <LeukQuantLogo size={20} />
              </div>
            </div>
          ) : null}

          {/* Title & Subtitle Stack */}
          <div className="flex flex-col">
            <h1 className="text-[17px] font-bold text-black dark:text-white tracking-tight leading-tight flex items-center gap-1.5">
              <span>{title}</span>
            </h1>
            {subtitle && (
              <p className="text-[11px] font-medium text-[#8E8E93] dark:text-[#9BA1B0] tracking-normal leading-tight">
                {subtitle}
              </p>
            )}
          </div>
        </div>

        {/* Right Section */}
        <div className="flex items-center space-x-2">
          {rightActions ? (
            rightActions
          ) : (
            <>
              {onToggleTheme && (
                <button
                  onClick={() => {
                    sounds.playSwitchOn();
                    onToggleTheme();
                  }}
                  title="Toggle Light / Dark Mode"
                  className="w-8 h-8 rounded-full bg-black/[0.04] dark:bg-white/[0.08] hover:bg-black/[0.08] dark:hover:bg-white/[0.12] border border-black/[0.06] dark:border-white/[0.1] text-black dark:text-white flex items-center justify-center ios-press-spring shadow-sm backdrop-blur-md focus:outline-none"
                >
                  {isDark ? (
                    <Sun size={15} className="text-amber-400" />
                  ) : (
                    <Moon size={15} className="text-ios-blue" />
                  )}
                </button>
              )}

              {onOpenSettings && (
                <button
                  onClick={() => {
                    sounds.playTap();
                    onOpenSettings();
                  }}
                  title="Settings & Personalization"
                  className="w-8 h-8 rounded-full bg-black/[0.04] dark:bg-white/[0.08] hover:bg-black/[0.08] dark:hover:bg-white/[0.12] border border-black/[0.06] dark:border-white/[0.1] text-black dark:text-white flex items-center justify-center ios-press-spring shadow-sm backdrop-blur-md focus:outline-none"
                >
                  <Sliders size={15} strokeWidth={2.2} />
                </button>
              )}
            </>
          )}
        </div>
      </div>
    </header>
  );
}
