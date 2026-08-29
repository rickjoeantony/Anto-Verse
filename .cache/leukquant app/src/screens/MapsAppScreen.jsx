// src/screens/MapsAppScreen.jsx
import React, { useState } from 'react';
import {
  Compass,
  Navigation,
  MapPin,
  Layers,
  Search,
  Rotate3d,
  Sparkles,
  ChevronRight,
  ShieldAlert,
  Radio
} from 'lucide-react';
import IosNavigationBar from '../components/ios/IosNavigationBar';
import sounds from '../utils/soundEffects';

export default function MapsAppScreen({ isDark, onToggleTheme, onOpenSettings }) {
  const [selectedSensor, setSelectedSensor] = useState({
    name: "Cupertino Honeypot Cluster Alpha",
    coords: "37.3349° N, 122.0090° W",
    status: "Active & Quarantined",
    telemetry: "1,248 packets/sec",
    threatScore: "0.02 (Optimal)"
  });

  return (
    <div className="flex-1 flex flex-col pb-6">
      <IosNavigationBar
        title="Apple Maps 26"
        subtitle="3D Spatial Terrain & Decoy Radar"
        isDark={isDark}
        onToggleTheme={onToggleTheme}
        onOpenSettings={onOpenSettings}
      />

      <div className="p-4 space-y-4">
        {/* Floating Liquid Glass Search HUD */}
        <div className="p-2.5 rounded-[24px] ios26-glass-thick flex items-center justify-between shadow-2xl border border-white/25">
          <div className="flex items-center gap-2 px-2">
            <Search size={17} className="text-ios-blue dark:text-sky-400" />
            <input
              type="text"
              defaultValue="Apple Park • Ghost-Net Perimeter"
              className="bg-transparent text-[14px] font-semibold text-black dark:text-white focus:outline-none"
            />
          </div>
          <button
            onClick={() => sounds.playPop()}
            className="w-8 h-8 rounded-full bg-ios-blue text-white flex items-center justify-center shadow-md"
          >
            <Navigation size={15} />
          </button>
        </div>

        {/* 3D Spatial Vector Map Canvas */}
        <div className="relative w-full h-[280px] rounded-[32px] overflow-hidden bg-[#0A1224] border border-white/20 shadow-2xl flex items-center justify-center perspective-1000">
          {/* Topographic Vector Mesh Grid */}
          <div className="absolute inset-0 opacity-40 bg-[radial-gradient(#38bdf8_1px,transparent_1px)] [background-size:16px_16px]" />

          {/* Glowing Radial Radar Sweep */}
          <div className="absolute w-[360px] h-[360px] rounded-full border border-sky-500/20 animate-spin-slow flex items-center justify-center">
            <div className="w-[240px] h-[240px] rounded-full border border-blue-400/30 flex items-center justify-center">
              <div className="w-[120px] h-[120px] rounded-full border border-indigo-400/40" />
            </div>
          </div>

          {/* Animated Decoy Pins */}
          {[
            { top: '30%', left: '40%', name: 'Decoy Alpha', color: 'bg-ios-blue' },
            { top: '55%', left: '65%', name: 'Decoy Beta', color: 'bg-ios-purple' },
            { top: '65%', left: '25%', name: 'Decoy Gamma', color: 'bg-ios-green' }
          ].map((pin, idx) => (
            <div
              key={idx}
              onClick={() => {
                sounds.playPop();
                setSelectedSensor({
                  name: pin.name,
                  coords: "37.332° N, 122.011° W",
                  status: "Active Sensor Armed",
                  telemetry: "3,120 pkts/s",
                  threatScore: "0.04"
                });
              }}
              className="absolute cursor-pointer group"
              style={{ top: pin.top, left: pin.left }}
            >
              <span className={`absolute -inset-2 rounded-full ${pin.color}/40 animate-ping`} />
              <div className={`relative w-8 h-8 rounded-full ${pin.color} text-white flex items-center justify-center shadow-lg border-2 border-white group-hover:scale-125 transition-transform`}>
                <MapPin size={15} />
              </div>
            </div>
          ))}

          {/* Center Apple Park HQ */}
          <div className="relative z-10 w-20 h-20 rounded-full border-4 border-sky-400/80 bg-black/60 backdrop-blur-md flex flex-col items-center justify-center text-white shadow-2xl animate-pulse">
            <Radio size={20} className="text-sky-400" />
            <span className="text-[9px] font-bold mt-0.5">HQ Core</span>
          </div>

          {/* Controls overlay */}
          <div className="absolute top-3 right-3 flex flex-col gap-2">
            <button
              onClick={() => sounds.playTap()}
              className="w-8 h-8 rounded-full ios26-glass flex items-center justify-center text-white shadow-md"
            >
              <Rotate3d size={15} />
            </button>
            <button
              onClick={() => sounds.playTap()}
              className="w-8 h-8 rounded-full ios26-glass flex items-center justify-center text-white shadow-md"
            >
              <Layers size={15} />
            </button>
          </div>
        </div>

        {/* Selected Sensor Glass Card */}
        <div className="p-4 rounded-[28px] ios26-glass-card space-y-3 border border-white/20">
          <div className="flex items-center justify-between">
            <div>
              <h3 className="text-[17px] font-bold text-black dark:text-white">
                {selectedSensor.name}
              </h3>
              <p className="text-[12px] font-mono text-[#8E8E93] dark:text-[#9BA1B0]">
                {selectedSensor.coords}
              </p>
            </div>
            <span className="px-3 py-1 rounded-full bg-ios-green/20 text-ios-green text-[11px] font-bold border border-ios-green/30">
              {selectedSensor.status}
            </span>
          </div>

          <div className="grid grid-cols-2 gap-2 pt-1">
            <div className="p-2.5 rounded-2xl bg-black/5 dark:bg-white/5 border border-white/10">
              <span className="text-[11px] text-gray-400">Telemetry Ingress</span>
              <div className="text-[14px] font-bold text-sky-400">{selectedSensor.telemetry}</div>
            </div>
            <div className="p-2.5 rounded-2xl bg-black/5 dark:bg-white/5 border border-white/10">
              <span className="text-[11px] text-gray-400">Threat Score</span>
              <div className="text-[14px] font-bold text-emerald-400">{selectedSensor.threatScore}</div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
