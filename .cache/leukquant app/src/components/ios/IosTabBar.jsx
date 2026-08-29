// src/components/ios/IosTabBar.jsx
import React from 'react';
import { Shield, Radio, AlertTriangle, FileText, Settings, Sparkles } from 'lucide-react';
import sounds from '../../utils/soundEffects';

export default function IosTabBar({
  activeTab,
  onTabChange,
  unreadIncidentsCount = 1,
  unreadEventsCount = 6,
  bottomAccessory = null,
  isMinimized = false
}) {
  const tabs = [
    {
      id: 'overview',
      label: 'Overview',
      icon: Shield,
      badge: null
    },
    {
      id: 'events',
      label: 'Events',
      icon: Radio,
      badge: unreadEventsCount > 0 ? unreadEventsCount : null
    },
    {
      id: 'incidents',
      label: 'Incidents',
      icon: AlertTriangle,
      badge: unreadIncidentsCount > 0 ? unreadIncidentsCount : null,
      badgeColor: 'bg-ios-red'
    },
    {
      id: 'reports',
      label: 'Reports',
      icon: FileText,
      badge: null
    },
    {
      id: 'settings',
      label: 'Settings',
      icon: Settings,
      badge: null
    }
  ];

  return (
    <div className="fixed bottom-0 left-0 right-0 z-40 max-w-[440px] mx-auto px-3 pb-2 pt-1 pointer-events-none">
      {/* Optional Bottom Accessory (e.g. Mini Player or Quick Action) */}
      {bottomAccessory && (
        <div className="mb-2 pointer-events-auto animate-in slide-in-from-bottom-2 duration-300">
          {bottomAccessory}
        </div>
      )}

      {/* Floating Apple Liquid Glass Dock */}
      <nav
        className={`pointer-events-auto ios26-glass-thick rounded-[28px] px-2 py-1.5 flex items-center justify-around relative overflow-hidden transition-all duration-300 shadow-[0_12px_40px_rgba(0,0,0,0.3)] ${
          isMinimized ? 'opacity-70 scale-95 hover:opacity-100 hover:scale-100' : 'opacity-100'
        }`}
      >
        {/* Specular Edge Top Line */}
        <div className="absolute top-0 left-4 right-4 h-[1px] bg-gradient-to-r from-transparent via-white/50 dark:via-white/25 to-transparent pointer-events-none" />

        {tabs.map((tab) => {
          const Icon = tab.icon;
          const isActive = activeTab === tab.id;

          return (
            <button
              key={tab.id}
              onClick={() => {
                sounds.playTap();
                onTabChange(tab.id);
              }}
              className={`relative flex flex-col items-center justify-center flex-1 py-1 min-h-[46px] rounded-[20px] transition-all duration-200 ios-press-spring focus:outline-none ${
                isActive
                  ? 'bg-ios-blue/15 dark:bg-ios-blue/20 shadow-inner'
                  : 'hover:bg-black/5 dark:hover:bg-white/5'
              }`}
            >
              <div className="relative">
                <Icon
                  size={21}
                  strokeWidth={isActive ? 2.5 : 1.8}
                  className={`transition-all duration-200 ${
                    isActive
                      ? 'text-ios-blue dark:text-sky-400 scale-110 drop-shadow-[0_2px_10px_rgba(0,122,255,0.5)]'
                      : 'text-[#8E8E93] dark:text-[#9BA1B0]'
                  }`}
                />

                {/* iOS Notification Badge */}
                {tab.badge && (
                  <span className={`absolute -top-1.5 -right-3 min-w-[17px] h-[17px] px-1 text-[10px] font-bold text-white flex items-center justify-center rounded-full ring-2 ring-white dark:ring-[#121624] shadow-sm ${
                    tab.badgeColor || 'bg-ios-blue'
                  }`}>
                    {tab.badge}
                  </span>
                )}
              </div>

              {/* Label */}
              <span
                className={`text-[10px] font-medium tracking-tight mt-1 transition-all duration-200 ${
                  isActive
                    ? 'text-ios-blue dark:text-sky-400 font-bold'
                    : 'text-[#8E8E93] dark:text-[#8E8E93]'
                }`}
              >
                {tab.label}
              </span>

              {/* Active Pip */}
              {isActive && (
                <span className="w-1 h-1 rounded-full bg-ios-blue dark:bg-sky-400 mt-0.5 animate-pulse shadow-[0_0_6px_#007AFF]" />
              )}
            </button>
          );
        })}
      </nav>
    </div>
  );
}
