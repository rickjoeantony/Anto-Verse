// src/components/ios/IosCharts.jsx
import React, { useState } from 'react';
import sounds from '../../utils/soundEffects';

export function IosActivityLineChart({
  data = [],
  height = 140,
  strokeColor = "#007AFF"
}) {
  const [hoverIndex, setHoverIndex] = useState(data.length - 1);

  if (!data || data.length === 0) return null;

  const maxVal = Math.max(...data.map(d => d.events), 10);
  const minVal = 0;
  const paddingX = 10;
  const paddingY = 16;
  const width = 340;
  const innerHeight = height - paddingY * 2;
  const innerWidth = width - paddingX * 2;

  const points = data.map((d, i) => {
    const x = paddingX + (i / (data.length - 1)) * innerWidth;
    const y = height - paddingY - ((d.events - minVal) / (maxVal - minVal)) * innerHeight;
    return { x, y, data: d, index: i };
  });

  const pathD = points.reduce((acc, pt, i) => {
    if (i === 0) return `M ${pt.x} ${pt.y}`;
    const prev = points[i - 1];
    const cx = (prev.x + pt.x) / 2;
    return `${acc} C ${cx} ${prev.y}, ${cx} ${pt.y}, ${pt.x} ${pt.y}`;
  }, '');

  const areaD = `${pathD} L ${points[points.length - 1].x} ${height} L ${points[0].x} ${height} Z`;
  const activePt = points[hoverIndex] || points[points.length - 1];

  return (
    <div className="w-full flex flex-col">
      {/* Chart Header Info */}
      <div className="flex items-baseline justify-between mb-2">
        <div>
          <span className="text-[26px] font-extrabold tracking-tight text-black dark:text-white">
            {activePt.data.events}
          </span>
          <span className="text-[13px] text-[#8E8E93] dark:text-[#9BA1B0] ml-1.5 font-medium">
            events at {activePt.data.time}
          </span>
        </div>
        <div className="text-[12px] font-semibold text-ios-blue dark:text-sky-400 flex items-center gap-1 bg-ios-blue/10 dark:bg-sky-400/10 px-2 py-0.5 rounded-full">
          <span>Peak: {maxVal}/hr</span>
        </div>
      </div>

      {/* SVG Chart with Liquid Glow */}
      <div className="relative w-full overflow-hidden rounded-[16px] bg-black/[0.02] dark:bg-white/[0.03] p-1 border border-black/[0.04] dark:border-white/[0.06]">
        <svg
          viewBox={`0 0 ${width} ${height}`}
          className="w-full h-[140px] overflow-visible"
          onMouseMove={(e) => {
            const rect = e.currentTarget.getBoundingClientRect();
            const mouseX = e.clientX - rect.left;
            const idx = Math.min(
              data.length - 1,
              Math.max(0, Math.round(((mouseX / rect.width) * innerWidth) / (innerWidth / (data.length - 1))))
            );
            if (idx !== hoverIndex) {
              sounds.playTap();
              setHoverIndex(idx);
            }
          }}
          onTouchMove={(e) => {
            const rect = e.currentTarget.getBoundingClientRect();
            const touchX = e.touches[0].clientX - rect.left;
            const idx = Math.min(
              data.length - 1,
              Math.max(0, Math.round(((touchX / rect.width) * innerWidth) / (innerWidth / (data.length - 1))))
            );
            if (idx !== hoverIndex) {
              sounds.playTap();
              setHoverIndex(idx);
            }
          }}
        >
          <defs>
            <linearGradient id="iosChartGrad26" x1="0" y1="0" x2="0" y2="1">
              <stop offset="0%" stopColor={strokeColor} stopOpacity="0.45" />
              <stop offset="60%" stopColor={strokeColor} stopOpacity="0.15" />
              <stop offset="100%" stopColor={strokeColor} stopOpacity="0.0" />
            </linearGradient>
            <filter id="glowFilter" x="-20%" y="-20%" width="140%" height="140%">
              <feGaussianBlur stdDeviation="3" result="blur" />
              <feComposite in="SourceGraphic" in2="blur" operator="over" />
            </filter>
          </defs>

          {/* Reference Lines */}
          <line x1={paddingX} y1={paddingY} x2={width - paddingX} y2={paddingY} stroke="currentColor" strokeOpacity="0.08" strokeDasharray="4 4" />
          <line x1={paddingX} y1={height / 2} x2={width - paddingX} y2={height / 2} stroke="currentColor" strokeOpacity="0.08" strokeDasharray="4 4" />
          <line x1={paddingX} y1={height - paddingY} x2={width - paddingX} y2={height - paddingY} stroke="currentColor" strokeOpacity="0.08" />

          {/* Area */}
          <path d={areaD} fill="url(#iosChartGrad26)" />

          {/* Glowing Stroke */}
          <path
            d={pathD}
            fill="none"
            stroke={strokeColor}
            strokeWidth="3"
            strokeLinecap="round"
            strokeLinejoin="round"
            filter="url(#glowFilter)"
          />

          {/* Active Point Indicator */}
          {activePt && (
            <>
              <line
                x1={activePt.x}
                y1={paddingY}
                x2={activePt.x}
                y2={height - paddingY}
                stroke={strokeColor}
                strokeWidth="1.5"
                strokeDasharray="3 3"
                opacity="0.7"
              />
              <circle
                cx={activePt.x}
                cy={activePt.y}
                r="6"
                fill="#FFFFFF"
                stroke={strokeColor}
                strokeWidth="3"
                className="drop-shadow-lg"
              />
            </>
          )}
        </svg>
      </div>

      {/* Time axis */}
      <div className="flex justify-between text-[11px] text-[#8E8E93] dark:text-[#9BA1B0] pt-2 px-1 font-mono">
        <span>00:00</span>
        <span>08:00</span>
        <span>16:00</span>
        <span>22:00</span>
      </div>
    </div>
  );
}

export function IosDonutChart({ data = [] }) {
  const total = data.reduce((acc, item) => acc + item.count, 0);
  const size = 120;
  const strokeWidth = 14;
  const radius = (size - strokeWidth) / 2;
  const circumference = 2 * Math.PI * radius;

  let currentOffset = 0;

  return (
    <div className="flex items-center gap-4">
      {/* Donut Ring */}
      <div className="relative w-[120px] h-[120px] shrink-0">
        <svg viewBox={`0 0 ${size} ${size}`} className="w-full h-full -rotate-90">
          <circle
            cx={size / 2}
            cy={size / 2}
            r={radius}
            fill="transparent"
            stroke="currentColor"
            strokeOpacity="0.08"
            strokeWidth={strokeWidth}
          />
          {data.map((item, idx) => {
            const dashLength = (item.count / (total || 1)) * circumference;
            const strokeDasharray = `${dashLength} ${circumference - dashLength}`;
            const strokeDashoffset = -currentOffset;
            currentOffset += dashLength;

            return (
              <circle
                key={idx}
                cx={size / 2}
                cy={size / 2}
                r={radius}
                fill="transparent"
                stroke={item.color}
                strokeWidth={strokeWidth}
                strokeDasharray={strokeDasharray}
                strokeDashoffset={strokeDashoffset}
                strokeLinecap="round"
                className="transition-all duration-500"
              />
            );
          })}
        </svg>

        {/* Center label */}
        <div className="absolute inset-0 flex flex-col items-center justify-center pointer-events-none">
          <span className="text-[18px] font-bold text-black dark:text-white leading-tight">
            {total}
          </span>
          <span className="text-[10px] uppercase font-bold text-[#8E8E93] tracking-wider">
            Threats
          </span>
        </div>
      </div>

      {/* Legend list */}
      <div className="flex-1 space-y-2">
        {data.map((item, idx) => (
          <div key={idx} className="flex items-center justify-between text-[13px]">
            <div className="flex items-center gap-2 min-w-0 pr-2">
              <span
                className="w-2.5 h-2.5 rounded-full shrink-0 shadow-sm"
                style={{ backgroundColor: item.color }}
              />
              <span className="text-black dark:text-white truncate font-medium">
                {item.name}
              </span>
            </div>
            <div className="shrink-0 font-semibold text-[#8E8E93] dark:text-[#9BA1B0] text-[12px]">
              {item.percent}%
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

export function IosProtocolBarChart({ data = [] }) {
  return (
    <div className="space-y-3">
      {data.map((item, idx) => (
        <div key={idx} className="space-y-1">
          <div className="flex items-center justify-between text-[13px]">
            <span className="font-semibold text-black dark:text-white truncate">
              {item.protocol}
            </span>
            <span className="font-mono text-[12px] text-[#8E8E93] dark:text-[#9BA1B0] font-medium">
              {item.events} <span className="text-[10px] text-ios-blue dark:text-sky-400">({item.percent}%)</span>
            </span>
          </div>
          {/* Liquid glowing bar */}
          <div className="w-full h-2.5 rounded-full bg-black/10 dark:bg-white/10 overflow-hidden p-0.5 border border-white/10">
            <div
              className="h-full rounded-full transition-all duration-700 shadow-sm"
              style={{
                width: `${item.percent}%`,
                backgroundColor: item.color
              }}
            />
          </div>
        </div>
      ))}
    </div>
  );
}
