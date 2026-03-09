/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        'system-bg': '#050508',
        'system-panel': 'rgba(10, 10, 18, 0.9)',
        'neon-blue': '#00d2ff',
        'neon-cyan': '#00f5ff',
        'glow-purple': '#b026ff',
        'glow-magenta': '#ff00ff',
        'gold-accent': '#ffd700',
        'hp-red': '#ff3333',
        'mp-blue': '#3388ff',
        'void': '#0a0a12',
      },
      boxShadow: {
        'neon-blue': '0 0 15px #00d2ff, 0 0 30px rgba(0, 210, 255, 0.4)',
        'glow-purple': '0 0 15px #b026ff, 0 0 30px rgba(176, 38, 255, 0.4)',
        'panel': '0 4px 6px rgba(0, 0, 0, 0.5), inset 0 0 20px rgba(0, 210, 255, 0.05)',
        'inner-glow': 'inset 0 0 30px rgba(0, 210, 255, 0.1)',
      },
      fontFamily: {
        system: ['"Orbitron"', 'monospace'],
        body: ['"Inter"', 'sans-serif'],
      },
      animation: {
        'glow-pulse': 'glow-pulse 2s ease-in-out infinite',
        'float': 'float 6s ease-in-out infinite',
        'scan': 'scan 4s linear infinite',
        'shimmer': 'shimmer 2s linear infinite',
        'bar-fill': 'bar-fill 0.8s ease-out forwards',
        'fade-up': 'fade-up 0.6s ease-out forwards',
        'scale-in': 'scale-in 0.4s cubic-bezier(0.34, 1.56, 0.64, 1) forwards',
      },
      keyframes: {
        'glow-pulse': {
          '0%, 100%': { opacity: '1', filter: 'brightness(1)' },
          '50%': { opacity: '0.8', filter: 'brightness(1.2)' },
        },
        'float': {
          '0%, 100%': { transform: 'translateY(0) rotate(0deg)' },
          '50%': { transform: 'translateY(-12px) rotate(2deg)' },
        },
        'scan': {
          '0%': { transform: 'translateY(-100%)' },
          '100%': { transform: 'translateY(100vh)' },
        },
        'shimmer': {
          '0%': { backgroundPosition: '-200% 0' },
          '100%': { backgroundPosition: '200% 0' },
        },
        'bar-fill': {
          '0%': { width: '0%' },
        },
        'fade-up': {
          '0%': { opacity: '0', transform: 'translateY(20px)' },
          '100%': { opacity: '1', transform: 'translateY(0)' },
        },
        'scale-in': {
          '0%': { opacity: '0', transform: 'scale(0.8)' },
          '100%': { opacity: '1', transform: 'scale(1)' },
        },
      },
      backgroundImage: {
        'gradient-radial': 'radial-gradient(var(--tw-gradient-stops))',
        'gradient-mesh': 'linear-gradient(135deg, rgba(0,210,255,0.1) 0%, transparent 50%, rgba(176,38,255,0.08) 100%)',
      },
    },
  },
  plugins: [],
}
