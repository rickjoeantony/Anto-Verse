// src/components/ios/IosInsetGroup.jsx
import React from 'react';
import { ChevronRight } from 'lucide-react';
import sounds from '../../utils/soundEffects';

export function IosInsetGroup({
  header,
  footer,
  children,
  className = ""
}) {
  return (
    <div className={`my-3.5 ${className}`}>
      {/* Section Header */}
      {header && (
        <div className="px-5 pb-1.5 text-[12px] font-bold tracking-wider text-[#6B7280] dark:text-[#9BA1B0] uppercase flex items-center justify-between">
          <span>{header}</span>
        </div>
      )}

      {/* Inset Group Container (Liquid Glass Squircle) */}
      <div className="mx-4 rounded-[24px] ios26-glass-card dynamic-lighting-card relative overflow-hidden shadow-lg">
        {/* Top Specular Sheen */}
        <div className="absolute top-0 left-4 right-4 h-[1px] bg-gradient-to-r from-transparent via-white/60 dark:via-white/20 to-transparent pointer-events-none" />
        {children}
      </div>

      {/* Section Footer */}
      {footer && (
        <div className="px-5 pt-1.5 text-[12px] text-[#6B7280] dark:text-[#8E95A5] leading-relaxed">
          {footer}
        </div>
      )}
    </div>
  );
}

export function IosCell({
  icon: Icon,
  iconColor = "bg-ios-blue text-white",
  iconBg,
  title,
  subtitle,
  value,
  badge,
  badgeColor = "bg-ios-blue",
  chevron = true,
  rightElement,
  onClick,
  showSeparator = true,
  disabled = false,
  className = ""
}) {
  const isInteractive = Boolean(onClick);

  return (
    <div className="relative">
      <div
        onClick={!disabled && onClick ? (e) => {
          sounds.playTap();
          onClick(e);
        } : undefined}
        className={`flex items-center justify-between px-4 py-3.5 min-h-[48px] transition-all duration-150 ${
          isInteractive && !disabled
            ? 'ios-cell-press cursor-pointer hover:bg-black/[0.02] dark:hover:bg-white/[0.04] active:bg-black/[0.05] dark:active:bg-white/[0.08]'
            : ''
        } ${disabled ? 'opacity-40 cursor-not-allowed' : ''} ${className}`}
      >
        {/* Left: Icon & Text */}
        <div className="flex items-center min-w-0 pr-3">
          {Icon && (
            <div
              className={`w-[34px] h-[34px] rounded-[11px] flex items-center justify-center mr-3.5 shrink-0 shadow-sm border border-white/30 ${
                iconBg || iconColor
              }`}
            >
              <Icon size={19} strokeWidth={2.2} />
            </div>
          )}

          <div className="min-w-0 flex-1">
            <div className="text-[16px] font-semibold text-black dark:text-white tracking-tight truncate leading-tight">
              {title}
            </div>
            {subtitle && (
              <div className="text-[12px] text-[#8E8E93] dark:text-[#9BA1B0] tracking-normal truncate mt-0.5 font-normal">
                {subtitle}
              </div>
            )}
          </div>
        </div>

        {/* Right Accessory */}
        <div className="flex items-center shrink-0 space-x-2">
          {value && (
            <span className="text-[14px] font-normal text-[#8E8E93] dark:text-[#9BA1B0] tracking-tight">
              {value}
            </span>
          )}

          {badge && (
            <span className={`px-2.5 py-0.5 text-[11px] font-bold text-white rounded-full shadow-sm ${badgeColor}`}>
              {badge}
            </span>
          )}

          {rightElement}

          {chevron && isInteractive && (
            <ChevronRight
              size={17}
              strokeWidth={2.4}
              className="text-[#C7C7CC] dark:text-[#58585E] ml-1"
            />
          )}
        </div>
      </div>

      {/* Inset Separator */}
      {showSeparator && (
        <div className={`h-[0.5px] bg-black/[0.06] dark:bg-white/[0.08] ${
          Icon ? 'ml-[60px]' : 'ml-4'
        }`} />
      )}
    </div>
  );
}
