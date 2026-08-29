// src/screens/MusicAppScreen.jsx
import React, { useState, useEffect } from 'react';
import {
  Play,
  Pause,
  SkipForward,
  SkipBack,
  Volume2,
  Heart,
  Share2,
  ListMusic,
  Sparkles,
  Radio,
  Sliders,
  Headphones
} from 'lucide-react';
import IosNavigationBar from '../components/ios/IosNavigationBar';
import sounds from '../utils/soundEffects';

export default function MusicAppScreen({ isDark, onToggleTheme, onOpenSettings }) {
  const [isPlaying, setIsPlaying] = useState(true);
  const [trackProgress, setTrackProgress] = useState(42);
  const [spatialAudio, setSpatialAudio] = useState(true);
  const [activeLyricIndex, setActiveLyricIndex] = useState(1);

  const lyrics = [
    "Refracting light through pure synthetic glass...",
    "Floating in zero gravity across the spatial core...",
    "Neural waves resonating at ninety-six kilohertz...",
    "A timeless melody forged in liquid titanium..."
  ];

  useEffect(() => {
    let timer;
    if (isPlaying) {
      timer = setInterval(() => {
        setTrackProgress(prev => (prev >= 100 ? 0 : prev + 1));
      }, 1000);
    }
    return () => clearInterval(timer);
  }, [isPlaying]);

  return (
    <div className="flex-1 flex flex-col pb-8">
      <IosNavigationBar
        title="Apple Music 26"
        subtitle="Spatial Audio • Lossless Liquid Glass"
        isDark={isDark}
        onToggleTheme={onToggleTheme}
        onOpenSettings={onOpenSettings}
      />

      <div className="px-5 py-3 space-y-5">
        {/* Holographic Liquid Glass Album Art Frame */}
        <div className="relative w-full aspect-square max-w-[320px] mx-auto rounded-[36px] overflow-hidden shadow-[0_20px_60px_rgba(0,0,0,0.5)] border border-white/30 group">
          {/* Dynamic Album Background */}
          <div className="absolute inset-0 bg-gradient-to-tr from-pink-600 via-purple-700 to-indigo-800 animate-aurora-1" />

          {/* Spatial 3D Center Glyph */}
          <div className="absolute inset-0 flex flex-col items-center justify-center text-white backdrop-blur-[2px]">
            <div className={`w-28 h-28 rounded-full bg-white/20 border-2 border-white/60 flex items-center justify-center backdrop-blur-xl shadow-2xl transition-all duration-700 ${
              isPlaying ? 'scale-110 rotate-180 animate-pulse' : 'scale-95'
            }`}>
              <Headphones size={52} className="text-white drop-shadow-md" />
            </div>

            <div className="mt-4 px-3 py-1 rounded-full bg-black/40 border border-white/20 backdrop-blur-md text-[11px] font-bold tracking-widest uppercase">
              {spatialAudio ? '✨ Spatial Audio' : 'Stereo Audio'}
            </div>
          </div>

          {/* Top Specular Sheen */}
          <div className="absolute top-0 left-0 right-0 h-1.5 bg-gradient-to-r from-transparent via-white/70 to-transparent" />
        </div>

        {/* Track Details & Favorite */}
        <div className="flex items-center justify-between px-2">
          <div>
            <h2 className="text-[22px] font-extrabold text-black dark:text-white tracking-tight leading-tight">
              Liquid Glass Symphony
            </h2>
            <p className="text-[14px] font-semibold text-ios-pink dark:text-pink-400">
              Siri Neural Ensemble • iOS 26 Master
            </p>
          </div>
          <button
            onClick={() => {
              sounds.playPop();
              setSpatialAudio(!spatialAudio);
            }}
            className={`p-2.5 rounded-full border transition-all ios-press-spring ${
              spatialAudio
                ? 'bg-ios-blue text-white border-transparent shadow-lg shadow-blue-500/30'
                : 'bg-black/10 dark:bg-white/10 border-white/10 text-gray-400'
            }`}
          >
            <Sparkles size={18} />
          </button>
        </div>

        {/* Scrubber & Waveform */}
        <div className="space-y-1 px-2">
          <div className="relative w-full h-2 rounded-full bg-black/10 dark:bg-white/15 overflow-hidden">
            <div
              className="h-full rounded-full bg-gradient-to-r from-pink-500 via-purple-500 to-indigo-500"
              style={{ width: `${trackProgress}%` }}
            />
          </div>
          <div className="flex justify-between text-[11px] font-mono text-gray-400 pt-1">
            <span>1:42</span>
            <span>-2:58</span>
          </div>
        </div>

        {/* Transport Controls */}
        <div className="flex items-center justify-center gap-8 py-2">
          <button
            onClick={() => {
              sounds.playTap();
              setTrackProgress(Math.max(0, trackProgress - 15));
            }}
            className="text-black dark:text-white p-2 hover:opacity-80 ios-press-spring"
          >
            <SkipBack size={28} />
          </button>

          <button
            onClick={() => {
              if (isPlaying) sounds.playSwitchOff();
              else sounds.playSwitchOn();
              setIsPlaying(!isPlaying);
            }}
            className="w-16 h-16 rounded-full bg-gradient-to-tr from-pink-500 to-purple-600 text-white flex items-center justify-center shadow-xl shadow-pink-500/30 hover:scale-105 ios-press-spring border border-white/40"
          >
            {isPlaying ? <Pause size={30} /> : <Play size={30} className="ml-1" />}
          </button>

          <button
            onClick={() => {
              sounds.playTap();
              setTrackProgress(Math.min(100, trackProgress + 15));
            }}
            className="text-black dark:text-white p-2 hover:opacity-80 ios-press-spring"
          >
            <SkipForward size={28} />
          </button>
        </div>

        {/* Real-time Synced Glass Lyrics Card */}
        <div className="p-4 rounded-[26px] ios26-glass-card space-y-2 border border-white/20">
          <div className="flex items-center justify-between text-[12px] font-bold text-gray-400 uppercase tracking-wider">
            <span className="flex items-center gap-1.5 text-ios-blue dark:text-sky-400">
              <ListMusic size={14} />
              <span>Live Synced Lyrics</span>
            </span>
            <span className="font-mono text-[10px] text-pink-400 animate-pulse">Dolby Atmos</span>
          </div>

          <div className="space-y-2 pt-1">
            {lyrics.map((line, idx) => (
              <p
                key={idx}
                onClick={() => {
                  sounds.playTap();
                  setActiveLyricIndex(idx);
                }}
                className={`text-[14px] transition-all cursor-pointer leading-snug ${
                  activeLyricIndex === idx
                    ? 'font-bold text-black dark:text-white scale-105 pl-2 border-l-2 border-pink-500'
                    : 'text-gray-400 hover:text-gray-600 dark:hover:text-gray-200'
                }`}
              >
                {line}
              </p>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
