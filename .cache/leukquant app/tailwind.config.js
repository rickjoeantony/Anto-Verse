/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  darkMode: 'class',
  theme: {
    extend: {
      fontFamily: {
        sf: [
          "-apple-system",
          "BlinkMacSystemFont",
          '"SF Pro Display"',
          '"SF Pro Text"',
          '"SF Pro"',
          "system-ui",
          "-apple-system-font",
          '"Helvetica Neue"',
          "Helvetica",
          "Arial",
          "sans-serif"
        ],
        mono: [
          '"SF Mono"',
          "ui-monospace",
          "Menlo",
          "Monaco",
          "Consolas",
          '"Liberation Mono"',
          '"Courier New"',
          "monospace"
        ]
      },
      colors: {
        ios: {
          blue: '#007AFF',
          'blue-dark': '#0A84FF',
          green: '#34C759',
          'green-dark': '#30D158',
          red: '#FF3B30',
          'red-dark': '#FF453A',
          orange: '#FF9500',
          'orange-dark': '#FF9F0A',
          yellow: '#FFCC00',
          'yellow-dark': '#FFD60A',
          purple: '#AF52DE',
          'purple-dark': '#BF5AF2',
          teal: '#59ADC4',
          'teal-dark': '#40C8E0',
          indigo: '#5856D6',
          'indigo-dark': '#5E5CE6',
          mint: '#00C7BE',
          'mint-dark': '#63E6E2',
          gray: {
            DEFAULT: '#8E8E93',
            2: '#AEAEB2',
            3: '#C7C7CC',
            4: '#D1D1D6',
            5: '#E5E5EA',
            6: '#F2F2F7',
          },
          'gray-dark': {
            DEFAULT: '#8E8E93',
            2: '#636366',
            3: '#48484A',
            4: '#3A3A3C',
            5: '#2C2C2E',
            6: '#1C1C1E',
          },
          light: {
            bg: '#F2F2F7',
            card: '#FFFFFF',
            cardSecondary: '#F2F2F7',
            separator: '#E5E5EA',
            separatorOpaque: '#C6C6C8',
            label: '#000000',
            secondaryLabel: '#3C3C4399', // 60%
            tertiaryLabel: '#3C3C434D',  // 30%
            quaternaryLabel: '#3C3C432E' // 18%
          },
          dark: {
            bg: '#000000',
            card: '#1C1C1E',
            cardSecondary: '#2C2C2E',
            separator: '#38383A',
            separatorOpaque: '#545458',
            label: '#FFFFFF',
            secondaryLabel: '#EBEBF599', // 60%
            tertiaryLabel: '#EBEBF54D',  // 30%
            quaternaryLabel: '#EBEBF52E' // 18%
          }
        }
      },
      borderRadius: {
        'ios-sm': '10px',
        'ios-md': '14px',
        'ios-lg': '20px',
        'ios-xl': '24px',
        'ios-full': '9999px',
      },
      boxShadow: {
        'ios-bar': '0 0.5px 0 rgba(0, 0, 0, 0.15)',
        'ios-bar-dark': '0 0.5px 0 rgba(255, 255, 255, 0.12)',
        'ios-sheet': '0 -10px 40px rgba(0, 0, 0, 0.25)',
        'ios-card': '0 1px 2px rgba(0, 0, 0, 0.04)',
      },
      fontSize: {
        'ios-largetitle': ['34px', { lineHeight: '41px', letterSpacing: '-0.022em', fontWeight: '700' }],
        'ios-title1': ['28px', { lineHeight: '34px', letterSpacing: '-0.021em', fontWeight: '700' }],
        'ios-title2': ['22px', { lineHeight: '28px', letterSpacing: '-0.018em', fontWeight: '700' }],
        'ios-title3': ['20px', { lineHeight: '25px', letterSpacing: '-0.017em', fontWeight: '600' }],
        'ios-headline': ['17px', { lineHeight: '22px', letterSpacing: '-0.016em', fontWeight: '600' }],
        'ios-body': ['17px', { lineHeight: '22px', letterSpacing: '-0.016em', fontWeight: '400' }],
        'ios-callout': ['16px', { lineHeight: '21px', letterSpacing: '-0.015em', fontWeight: '400' }],
        'ios-subheadline': ['15px', { lineHeight: '20px', letterSpacing: '-0.013em', fontWeight: '400' }],
        'ios-footnote': ['13px', { lineHeight: '18px', letterSpacing: '-0.006em', fontWeight: '400' }],
        'ios-caption1': ['12px', { lineHeight: '16px', letterSpacing: '0em', fontWeight: '400' }],
        'ios-caption2': ['11px', { lineHeight: '13px', letterSpacing: '0.006em', fontWeight: '400' }],
      }
    },
  },
  plugins: [],
}
