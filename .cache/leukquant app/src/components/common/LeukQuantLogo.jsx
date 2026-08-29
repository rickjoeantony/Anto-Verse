// src/components/common/LeukQuantLogo.jsx
import React, { useState } from 'react';

export default function LeukQuantLogo({ size = 28, height, className = "" }) {
  const [imageError, setImageError] = useState(false);
  const effectiveHeight = height || size;

  if (!imageError) {
    return (
      <img
        src="/assets/images/logo-full.png"
        alt="LeukQuant Logo"
        style={{ height: effectiveHeight, width: 'auto' }}
        className={`object-contain ${className}`}
        onError={() => setImageError(true)}
      />
    );
  }

  return (
    <svg
      width={effectiveHeight}
      height={effectiveHeight}
      viewBox="0 0 48 48"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
      className={className}
    >
      <defs>
        <linearGradient id="lqShieldGrad" x1="4" y1="4" x2="44" y2="44" gradientUnits="userSpaceOnUse">
          <stop stopColor="#007AFF" />
          <stop offset="0.5" stopColor="#38BDF8" />
          <stop offset="1" stopColor="#6366F1" />
        </linearGradient>
        <linearGradient id="lqCoreGrad" x1="16" y1="14" x2="32" y2="34" gradientUnits="userSpaceOnUse">
          <stop stopColor="#FFFFFF" />
          <stop offset="1" stopColor="#93C5FD" />
        </linearGradient>
      </defs>

      {/* Outer Hex/Shield Geometric Contour */}
      <path
        d="M24 4L42 12V27C42 37.5 24 44 24 44C24 44 6 37.5 6 27V12L24 4Z"
        fill="url(#lqShieldGrad)"
        fillOpacity="0.2"
        stroke="url(#lqShieldGrad)"
        strokeWidth="2.8"
        strokeLinecap="round"
        strokeLinejoin="round"
      />

      {/* Inner Cyber Core Polygon */}
      <path
        d="M24 12L34 18V28L24 34L14 28V18L24 12Z"
        fill="url(#lqCoreGrad)"
        fillOpacity="0.9"
        stroke="#FFFFFF"
        strokeWidth="1.5"
      />

      {/* Center Key/Sensor Node */}
      <circle cx="24" cy="23" r="3" fill="#007AFF" />
    </svg>
  );
}
