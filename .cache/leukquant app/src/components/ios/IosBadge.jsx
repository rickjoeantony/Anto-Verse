// src/components/ios/IosBadge.jsx
import React from 'react';

export function IosSeverityBadge({ severity, size = "sm", className = "" }) {
  const sev = (severity || 'info').toLowerCase();

  const configs = {
    critical: {
      label: 'Critical',
      color: 'bg-[#FF3B30]/20 text-[#FF3B30] dark:bg-[#FF453A]/25 dark:text-[#FF453A] border-[#FF3B30]/40 shadow-[0_0_12px_rgba(255,59,48,0.25)]',
      dot: 'bg-[#FF3B30] dark:bg-[#FF453A] animate-ping'
    },
    high: {
      label: 'High',
      color: 'bg-[#FF9500]/20 text-[#FF9500] dark:bg-[#FF9F0A]/25 dark:text-[#FF9F0A] border-[#FF9500]/40 shadow-[0_0_10px_rgba(255,149,0,0.2)]',
      dot: 'bg-[#FF9500] dark:bg-[#FF9F0A]'
    },
    warning: {
      label: 'Warning',
      color: 'bg-[#FFCC00]/25 text-[#A67C00] dark:bg-[#FFD60A]/25 dark:text-[#FFD60A] border-[#FFCC00]/40',
      dot: 'bg-[#FFCC00] dark:bg-[#FFD60A]'
    },
    info: {
      label: 'Info',
      color: 'bg-[#007AFF]/20 text-[#007AFF] dark:bg-[#0A84FF]/25 dark:text-sky-400 border-[#007AFF]/40 shadow-[0_0_10px_rgba(0,122,255,0.2)]',
      dot: 'bg-[#007AFF] dark:bg-sky-400'
    },
    resolved: {
      label: 'Resolved',
      color: 'bg-[#34C759]/20 text-[#34C759] dark:bg-[#30D158]/25 dark:text-[#30D158] border-[#34C759]/40 shadow-[0_0_10px_rgba(52,199,89,0.2)]',
      dot: 'bg-[#34C759] dark:bg-[#30D158]'
    },
    contained: {
      label: 'Contained',
      color: 'bg-[#5856D6]/20 text-[#5856D6] dark:bg-[#5E5CE6]/25 dark:text-[#5E5CE6] border-[#5856D6]/40',
      dot: 'bg-[#5856D6] dark:bg-[#5E5CE6]'
    },
    investigating: {
      label: 'Investigating',
      color: 'bg-[#FF9500]/20 text-[#FF9500] dark:bg-[#FF9F0A]/25 dark:text-[#FF9F0A] border-[#FF9500]/40 animate-pulse',
      dot: 'bg-[#FF9500] dark:bg-[#FF9F0A]'
    }
  };

  const current = configs[sev] || configs.info;

  const sizeClasses = size === "lg" 
    ? "px-3 py-1 text-[13px] font-semibold"
    : "px-2.5 py-0.5 text-[11px] font-semibold";

  return (
    <span
      className={`inline-flex items-center gap-1.5 rounded-full backdrop-blur-md border ${current.color} ${sizeClasses} ${className}`}
    >
      <span className={`w-1.5 h-1.5 rounded-full ${current.dot} shrink-0`} />
      <span>{current.label}</span>
    </span>
  );
}

export function IosProtocolBadge({ protocol, className = "" }) {
  return (
    <span
      className={`inline-flex items-center px-2 py-0.5 rounded-md text-[11px] font-mono font-semibold tracking-tight ios26-glass text-[#0A1120] dark:text-[#E2E8F0] border border-white/20 ${className}`}
    >
      {protocol}
    </span>
  );
}
