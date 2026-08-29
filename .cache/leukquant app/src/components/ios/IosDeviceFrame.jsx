// src/components/ios/IosDeviceFrame.jsx
import React, { useState, useEffect, useRef } from 'react';
import {
  Wifi,
  BatteryMedium,
  Sparkles,
  Smartphone,
  Tablet,
  Glasses,
  Monitor,
  Sun,
  Moon,
  Volume2,
  VolumeX,
  Palette,
  Layers,
  Radio,
  Music,
  MessageCircle,
  Compass,
  Globe,
  Settings as SettingsIcon,
  Shield,
  X,
  Check,
  Share2,
  Copy,
  QrCode,
  FlaskConical
} from 'lucide-react';
import LeukQuantLogo from '../common/LeukQuantLogo';
import WALLPAPERS from '../../data/wallpapers';
import sounds from '../../utils/soundEffects';
import useDynamicLighting from '../../hooks/useDynamicLighting';

export default function IosDeviceFrame({
  children,
  isDark,
  onToggleTheme,
  onOpenOnboarding,
  activeMode, // 'showcase' or 'apps'
  onModeChange,
  activeApp, // 'leukquant', 'music', 'messages', 'maps', 'safari', 'settings'
  onAppChange,
  currentWallpaper,
  onWallpaperChange,
  soundEnabled,
  onToggleSound,
  dynamicLightingEnabled,
  onToggleDynamicLighting
}) {
  const [deviceType, setDeviceType] = useState('iphone'); // 'iphone', 'ipad', 'visionos', 'tahoe'
  const [islandState, setIslandState] = useState('collapsed'); // 'collapsed', 'expanded', 'telemetry', 'music'
  const [currentTime, setCurrentTime] = useState('9:41');
  const [showQrModal, setShowQrModal] = useState(false);
  const [showWallpaperPicker, setShowWallpaperPicker] = useState(false);
  const [copiedLink, setCopiedLink] = useState(false);
  const [isMobileScreen, setIsMobileScreen] = useState(false);

  const containerRef = useRef(null);
  useDynamicLighting(containerRef, dynamicLightingEnabled);

  const localMobileUrl = typeof window !== 'undefined' ? window.location.href : "http://localhost:5173";

  // Check window size
  useEffect(() => {
    const checkScreen = () => {
      const isMobile = window.innerWidth < 768 || /Mobi|Android|iPhone|iPad|iPod/i.test(navigator.userAgent);
      setIsMobileScreen(isMobile);
      if (isMobile) {
        setDeviceType('fullscreen');
      }
    };
    checkScreen();
    window.addEventListener('resize', checkScreen);
    return () => window.removeEventListener('resize', checkScreen);
  }, []);

  // Update clock time
  useEffect(() => {
    const updateTime = () => {
      const now = new Date();
      let hours = now.getHours();
      const minutes = now.getMinutes().toString().padStart(2, '0');
      hours = hours % 12 || 12;
      setCurrentTime(`${hours}:${minutes}`);
    };
    updateTime();
    const timer = setInterval(updateTime, 10000);
    return () => clearInterval(timer);
  }, []);

  const handleCopyLink = () => {
    navigator.clipboard?.writeText(localMobileUrl);
    setCopiedLink(true);
    sounds.playPop();
    setTimeout(() => setCopiedLink(false), 2500);
  };

  const selectedWallpaper = WALLPAPERS.find(w => w.id === currentWallpaper) || WALLPAPERS[0];
  const qrCodeApiUrl = `https://api.qrserver.com/v1/create-qr-code/?size=240x240&data=${encodeURIComponent(localMobileUrl)}&bgcolor=FFFFFF&color=07090E&margin=8`;

  // Get frame container dimensions
  const getDeviceClasses = () => {
    if (isMobileScreen || deviceType === 'fullscreen') {
      return 'w-full min-h-screen rounded-none';
    }
    switch (deviceType) {
      case 'ipad':
        return 'w-full max-w-[760px] h-[920px] max-h-[92vh] rounded-[44px] ring-[12px] ring-[#1E2333]/90 shadow-[0_35px_100px_rgba(0,0,0,0.85)] border-[4px] border-[#131622]';
      case 'visionos':
        return 'w-full max-w-[500px] h-[900px] max-h-[92vh] rounded-[40px] shadow-[0_0_80px_rgba(0,122,255,0.25)] border-[2px] border-white/30 backdrop-blur-3xl';
      case 'tahoe':
        return 'w-full max-w-[840px] h-[880px] max-h-[90vh] rounded-[28px] shadow-[0_30px_90px_rgba(0,0,0,0.8)] border border-white/20';
      case 'iphone':
      default:
        return 'w-full max-w-[420px] h-[900px] max-h-[93vh] rounded-[54px] ring-[11px] ring-[#1D2230]/95 shadow-[0_30px_90px_rgba(0,0,0,0.9)] border-[4px] border-[#141724]';
    }
  };

  return (
    <div
      ref={containerRef}
      className={`min-h-screen ${selectedWallpaper.bgClass} flex flex-col items-center justify-start p-0 md:py-4 select-none font-sf relative overflow-x-hidden transition-colors duration-700`}
    >
      {/* Dynamic Ambient Aurora Backdrops */}
      <div className={`fixed top-[-160px] left-1/2 -translate-x-[420px] w-[560px] h-[560px] rounded-full bg-gradient-to-br ${selectedWallpaper.glow1} blur-[130px] pointer-events-none animate-aurora-1`} />
      <div className={`fixed bottom-[-160px] left-1/2 translate-x-[80px] w-[600px] h-[600px] rounded-full bg-gradient-to-tr ${selectedWallpaper.glow2} blur-[140px] pointer-events-none animate-aurora-2`} />
      <div className={`fixed top-1/3 left-1/2 -translate-x-[200px] w-[450px] h-[450px] rounded-full bg-gradient-to-r ${selectedWallpaper.glow3} blur-[120px] pointer-events-none animate-aurora-3`} />

      {/* Desktop Master Control Header Bar */}
      {!isMobileScreen && (
        <header className="w-full max-w-[880px] px-4 py-2.5 mb-3 hidden md:flex items-center justify-between ios26-glass-thick rounded-[24px] shadow-2xl relative z-30 border border-white/20">
          {/* Logo & Mode Switcher */}
          <div className="flex items-center space-x-3">
            <div className="relative group cursor-pointer" onClick={() => onModeChange(activeMode === 'showcase' ? 'apps' : 'showcase')}>
              <div className="w-9 h-9 rounded-2xl bg-gradient-to-tr from-[#007AFF] via-[#5856D6] to-[#AF52DE] flex items-center justify-center text-white shadow-lg border border-white/30 ios-press-spring">
                <LeukQuantLogo size={20} />
              </div>
              <span className="absolute -bottom-0.5 -right-0.5 w-3 h-3 rounded-full bg-ios-green border-2 border-[#101420] animate-pulse" />
            </div>

            {/* Mode Pills */}
            <div className="flex items-center p-1 rounded-xl bg-black/30 dark:bg-white/10 border border-white/10">
              <button
                onClick={() => {
                  sounds.playTap();
                  onModeChange('showcase');
                }}
                className={`px-3 py-1.5 rounded-lg text-[12px] font-semibold flex items-center gap-1.5 transition-all ios-press-spring ${
                  activeMode === 'showcase'
                    ? 'bg-gradient-to-r from-ios-blue to-indigo-600 text-white shadow-md'
                    : 'text-gray-300 hover:text-white'
                }`}
              >
                <FlaskConical size={14} className={activeMode === 'showcase' ? 'animate-bounce' : ''} />
                <span>SwiftUI 26 Showcase</span>
              </button>
              <button
                onClick={() => {
                  sounds.playTap();
                  onModeChange('apps');
                }}
                className={`px-3 py-1.5 rounded-lg text-[12px] font-semibold flex items-center gap-1.5 transition-all ios-press-spring ${
                  activeMode === 'apps'
                    ? 'bg-gradient-to-r from-ios-blue to-indigo-600 text-white shadow-md'
                    : 'text-gray-300 hover:text-white'
                }`}
              >
                <Layers size={14} />
                <span>iOS 26 App Suite</span>
              </button>
            </div>
          </div>

          {/* Quick App Switcher (when in apps mode) */}
          {activeMode === 'apps' && (
            <div className="hidden lg:flex items-center space-x-1 p-1 rounded-xl bg-black/20 dark:bg-white/5 border border-white/10">
              {[
                { id: 'leukquant', name: 'LeukQuant', icon: Shield, color: 'text-sky-400' },
                { id: 'music', name: 'Music', icon: Music, color: 'text-pink-400' },
                { id: 'messages', name: 'Messages', icon: MessageCircle, color: 'text-emerald-400' },
                { id: 'maps', name: 'Maps', icon: Compass, color: 'text-amber-400' },
                { id: 'settings', name: 'Settings', icon: SettingsIcon, color: 'text-indigo-400' }
              ].map((app) => {
                const Icon = app.icon;
                const isSelected = activeApp === app.id;
                return (
                  <button
                    key={app.id}
                    onClick={() => {
                      sounds.playTap();
                      onAppChange(app.id);
                    }}
                    className={`px-2.5 py-1 rounded-lg text-[11px] font-medium flex items-center gap-1.5 transition-all ${
                      isSelected
                        ? 'bg-white/20 text-white shadow-sm font-semibold'
                        : 'text-gray-400 hover:text-white'
                    }`}
                  >
                    <Icon size={13} className={app.color} />
                    <span>{app.name}</span>
                  </button>
                );
              })}
            </div>
          )}

          {/* Device & Experience Toolbars */}
          <div className="flex items-center space-x-1.5">
            {/* Device Switcher */}
            <div className="flex items-center p-0.5 rounded-xl bg-black/30 dark:bg-white/10 border border-white/10">
              <button
                onClick={() => { sounds.playTap(); setDeviceType('iphone'); }}
                title="iPhone 26 Pro Max"
                className={`p-1.5 rounded-lg transition-all ${deviceType === 'iphone' ? 'bg-white/20 text-white shadow-sm' : 'text-gray-400 hover:text-white'}`}
              >
                <Smartphone size={15} />
              </button>
              <button
                onClick={() => { sounds.playTap(); setDeviceType('ipad'); }}
                title="iPad Pro Liquid Glass"
                className={`p-1.5 rounded-lg transition-all ${deviceType === 'ipad' ? 'bg-white/20 text-white shadow-sm' : 'text-gray-400 hover:text-white'}`}
              >
                <Tablet size={15} />
              </button>
              <button
                onClick={() => { sounds.playTap(); setDeviceType('visionos'); }}
                title="VisionOS Spatial Glass"
                className={`p-1.5 rounded-lg transition-all ${deviceType === 'visionos' ? 'bg-white/20 text-white shadow-sm' : 'text-gray-400 hover:text-white'}`}
              >
                <Glasses size={15} />
              </button>
              <button
                onClick={() => { sounds.playTap(); setDeviceType('tahoe'); }}
                title="macOS Tahoe Window"
                className={`p-1.5 rounded-lg transition-all ${deviceType === 'tahoe' ? 'bg-white/20 text-white shadow-sm' : 'text-gray-400 hover:text-white'}`}
              >
                <Monitor size={15} />
              </button>
            </div>

            {/* Wallpaper Selector Trigger */}
            <div className="relative">
              <button
                onClick={() => {
                  sounds.playTap();
                  setShowWallpaperPicker(!showWallpaperPicker);
                }}
                title="Change iOS 26 Dynamic Wallpaper"
                className="p-2 rounded-xl bg-white/10 hover:bg-white/15 text-gray-200 hover:text-white transition-colors ios-press-spring border border-white/15"
              >
                <Palette size={15} className="text-amber-400" />
              </button>

              {/* Wallpaper Dropdown Menu */}
              {showWallpaperPicker && (
                <div className="absolute right-0 top-11 w-56 p-2 rounded-2xl ios26-glass-thick shadow-2xl z-50 border border-white/25 animate-in fade-in zoom-in-95 space-y-1">
                  <div className="text-[11px] font-bold text-gray-300 px-2 py-1 uppercase tracking-wider">
                    iOS 26 Wallpapers
                  </div>
                  {WALLPAPERS.map((wp) => (
                    <button
                      key={wp.id}
                      onClick={() => {
                        sounds.playPop();
                        onWallpaperChange(wp.id);
                        setShowWallpaperPicker(false);
                      }}
                      className={`w-full px-2.5 py-1.5 rounded-xl flex items-center justify-between text-left text-[12px] font-medium transition-all ${
                        currentWallpaper === wp.id
                          ? 'bg-white/20 text-white font-semibold'
                          : 'text-gray-300 hover:bg-white/10 hover:text-white'
                      }`}
                    >
                      <div className="flex items-center gap-2">
                        <span className={`w-4 h-4 rounded-full bg-gradient-to-tr ${wp.previewGradient} ring-1 ring-white/40`} />
                        <span>{wp.name}</span>
                      </div>
                      {currentWallpaper === wp.id && <Check size={14} className="text-ios-blue" />}
                    </button>
                  ))}
                </div>
              )}
            </div>

            {/* Sound Toggle */}
            <button
              onClick={() => {
                onToggleSound();
                if (!soundEnabled) sounds.playPop();
              }}
              title={soundEnabled ? 'Mute iOS Sounds' : 'Enable iOS Sounds'}
              className={`p-2 rounded-xl transition-colors ios-press-spring border border-white/15 ${
                soundEnabled ? 'bg-ios-blue/20 text-sky-400' : 'bg-white/10 text-gray-400'
              }`}
            >
              {soundEnabled ? <Volume2 size={15} /> : <VolumeX size={15} />}
            </button>

            {/* Dark/Light Mode */}
            <button
              onClick={() => {
                sounds.playSwitchOn();
                onToggleTheme();
              }}
              title="Toggle Light / Dark Glass Mode"
              className="p-2 rounded-xl bg-white/10 hover:bg-white/15 text-gray-200 hover:text-white transition-colors ios-press-spring border border-white/15"
            >
              {isDark ? <Sun size={15} className="text-amber-400" /> : <Moon size={15} className="text-sky-300" />}
            </button>

            {/* QR / Push to Mobile */}
            <button
              onClick={() => {
                sounds.playPop();
                setShowQrModal(true);
              }}
              className="px-3 py-1.5 rounded-xl bg-gradient-to-r from-ios-blue to-indigo-600 text-white text-[12px] font-semibold flex items-center gap-1.5 shadow-lg hover:brightness-110 ios-press-spring border border-white/20"
            >
              <QrCode size={14} />
              <span>Mobile QR</span>
            </button>
          </div>
        </header>
      )}

      {/* Main Device Housing */}
      <div
        className={`relative transition-all duration-300 flex flex-col z-10 overflow-hidden ${getDeviceClasses()} bg-[#F2F5FA]/80 dark:bg-[#07090E]/80 backdrop-blur-2xl text-black dark:text-white`}
      >
        {/* Specular Edge Refraction on Top */}
        <div className="ios26-chromatic-edge" />

        {/* Dynamic iOS 26 Status Bar */}
        <div className="sticky top-0 z-50 px-6 pt-3 pb-1 flex items-center justify-between text-[14px] font-semibold tracking-tight text-black dark:text-white select-none pointer-events-none bg-transparent">
          {/* Clock */}
          <div className="w-16 font-semibold tracking-normal text-left pl-1">
            {currentTime}
          </div>

          {/* Interactive Liquid Dynamic Island */}
          <div
            onClick={(e) => {
              e.stopPropagation();
              sounds.playPop();
              setIslandState(prev => {
                if (prev === 'collapsed') return 'telemetry';
                if (prev === 'telemetry') return 'music';
                return 'collapsed';
              });
            }}
            className={`pointer-events-auto bg-black text-white rounded-full flex items-center justify-center transition-all duration-300 cursor-pointer shadow-2xl border border-white/20 ${
              islandState === 'telemetry'
                ? 'w-[260px] h-[40px] px-3.5 justify-between'
                : islandState === 'music'
                ? 'w-[280px] h-[44px] px-3.5 justify-between'
                : 'w-[130px] h-[34px] px-2'
            }`}
          >
            {islandState === 'telemetry' && (
              <div className="flex items-center justify-between w-full text-[11px] animate-in fade-in">
                <div className="flex items-center gap-2 text-ios-green">
                  <span className="w-2.5 h-2.5 rounded-full bg-ios-green animate-ping" />
                  <span className="font-bold tracking-tight">Ghost-Net Active</span>
                </div>
                <div className="flex items-center gap-1.5 text-sky-400 font-mono text-[10px]">
                  <span>12 Decoys</span>
                  <span className="px-1 py-0.5 rounded bg-sky-500/20 text-[9px]">99.9%</span>
                </div>
              </div>
            )}

            {islandState === 'music' && (
              <div className="flex items-center justify-between w-full text-[11px] animate-in fade-in">
                <div className="flex items-center gap-2">
                  <div className="w-6 h-6 rounded-lg bg-gradient-to-tr from-pink-500 to-purple-600 flex items-center justify-center text-white text-[10px]">
                    <Music size={12} />
                  </div>
                  <div className="text-left leading-tight">
                    <div className="font-bold truncate max-w-[120px]">Liquid Glass (Spatial)</div>
                    <div className="text-[9px] text-gray-400">Apple Music 26</div>
                  </div>
                </div>
                <div className="flex items-center gap-0.5 text-pink-400">
                  <span className="w-0.5 h-3 bg-pink-400 animate-bounce rounded-full" />
                  <span className="w-0.5 h-4 bg-pink-400 animate-bounce delay-75 rounded-full" />
                  <span className="w-0.5 h-2 bg-pink-400 animate-bounce delay-150 rounded-full" />
                </div>
              </div>
            )}

            {islandState === 'collapsed' && (
              <div className="flex items-center justify-between w-full px-1">
                <span className="w-2.5 h-2.5 rounded-full bg-[#181818] border border-black/40" />
                <div className="flex items-center gap-1 text-[10px] text-sky-400 font-medium">
                  <span className="w-1.5 h-1.5 rounded-full bg-sky-400 animate-pulse" />
                  <span>iOS 26</span>
                </div>
                <span className="w-3 h-3 rounded-full bg-[#141414] border border-white/10" />
              </div>
            )}
          </div>

          {/* Right Status Indicators */}
          <div className="w-16 flex items-center justify-end space-x-1.5 pr-1 text-black dark:text-white">
            <span className="text-[11px] font-bold tracking-tighter">5G</span>
            <Wifi size={15} strokeWidth={2.4} />
            <BatteryMedium size={19} strokeWidth={2.2} />
          </div>
        </div>

        {/* Device Content Viewport */}
        <main className="flex-1 flex flex-col overflow-y-auto no-scrollbar relative pb-28">
          {children}
        </main>

        {/* iOS Home Indicator Bar */}
        <div className="absolute bottom-1.5 left-0 right-0 z-50 flex justify-center pointer-events-none pb-0.5">
          <div className="w-[138px] h-[5px] rounded-full bg-black/60 dark:bg-white/60 backdrop-blur-sm transition-all" />
        </div>
      </div>

      {/* Push to Mobile QR Modal */}
      {showQrModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
          <div
            className="fixed inset-0 bg-black/80 backdrop-blur-lg transition-opacity animate-in fade-in"
            onClick={() => setShowQrModal(false)}
          />
          <div className="relative w-full max-w-[390px] rounded-[36px] ios26-glass-thick bg-[#101422]/95 text-white border border-white/20 p-6 shadow-2xl z-10 flex flex-col items-center text-center animate-in zoom-in-95 duration-200">
            <button
              onClick={() => setShowQrModal(false)}
              className="absolute top-4 right-4 w-8 h-8 rounded-full bg-white/10 text-gray-300 hover:text-white flex items-center justify-center ios-press-spring"
            >
              <X size={16} />
            </button>

            <div className="w-12 h-12 rounded-2xl bg-gradient-to-tr from-ios-blue to-indigo-600 flex items-center justify-center shadow-lg border border-white/25 mb-3">
              <Smartphone size={24} className="text-white" />
            </div>

            <h3 className="text-[20px] font-bold text-white tracking-tight">
              Open iOS 26 On Your Phone
            </h3>
            <p className="text-[13px] text-gray-300 mt-1 max-w-[280px]">
              Scan with your iPhone or Android camera to experience the full Liquid Glass interface.
            </p>

            <div className="my-4 p-3.5 bg-white rounded-[22px] shadow-2xl border-4 border-ios-blue/40">
              <img
                src={qrCodeApiUrl}
                alt="Mobile QR Code"
                className="w-48 h-48 rounded-[14px] object-contain block"
              />
            </div>

            <div className="w-full mb-3 p-2.5 rounded-[16px] bg-black/50 border border-white/10 flex items-center justify-between">
              <span className="font-mono text-[12px] text-sky-400 font-semibold truncate pl-1">
                {localMobileUrl}
              </span>
              <button
                onClick={handleCopyLink}
                className={`px-3 py-1 rounded-[10px] text-[12px] font-semibold transition-all ios-press-spring flex items-center gap-1 ${
                  copiedLink ? 'bg-ios-green text-white' : 'bg-ios-blue text-white hover:bg-blue-600'
                }`}
              >
                {copiedLink ? <Check size={13} /> : <Copy size={13} />}
                <span>{copiedLink ? 'Copied' : 'Copy'}</span>
              </button>
            </div>

            <div className="w-full text-left bg-white/5 rounded-[18px] p-3 text-[12px] text-gray-300 space-y-1 border border-white/5">
              <div className="font-semibold text-white flex items-center gap-1.5">
                <Share2 size={13} className="text-ios-blue" />
                <span>Save to iPhone Home Screen:</span>
              </div>
              <p className="text-[11px] leading-relaxed text-gray-400">
                1. Open in mobile Safari.<br />
                2. Tap the <strong>Share</strong> button.<br />
                3. Tap <strong>"Add to Home Screen"</strong> for fullscreen native feel.
              </p>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
