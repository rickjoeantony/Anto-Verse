// src/screens/iOS26ShowcaseScreen.jsx
import React, { useState, useEffect, useRef } from 'react';
import {
  Sparkles,
  Layers,
  BarChart3,
  Globe,
  FileEdit,
  Activity,
  Sliders,
  Rotate3d,
  Check,
  Play,
  RotateCcw,
  Shield,
  Lock,
  Cpu,
  Brain,
  Zap,
  ChevronRight,
  ExternalLink,
  RefreshCw,
  Bold,
  Italic,
  Underline,
  List,
  Code,
  Palette,
  Volume2
} from 'lucide-react';
import IosNavigationBar from '../components/ios/IosNavigationBar';
import IosSegmentedControl from '../components/ios/IosSegmentedControl';
import IosSwitch from '../components/ios/IosSwitch';
import sounds from '../utils/soundEffects';

export default function IOS26ShowcaseScreen({
  isDark,
  onToggleTheme,
  onOpenSettings
}) {
  const [activeFeatureTab, setActiveFeatureTab] = useState('liquid-glass'); // 'liquid-glass', 'chart3d', 'webview', 'richtext', 'animatable', 'section-index'

  // Liquid Glass Studio States
  const [blurRadius, setBlurRadius] = useState(32);
  const [saturation, setSaturation] = useState(210);
  const [glassTint, setGlassTint] = useState('clear');
  const [glassShape, setGlassShape] = useState('squircle');
  const [specularHighlight, setSpecularHighlight] = useState(true);
  const [chromaticAberration, setChromaticAberration] = useState(true);
  const [shimmerActive, setShimmerActive] = useState(false);

  // 3D Chart States
  const [rotationX, setRotationX] = useState(20);
  const [rotationY, setRotationY] = useState(-25);
  const [isRotating, setIsRotating] = useState(false);
  const [selectedVoxel, setSelectedVoxel] = useState(null);

  // Native WebView States
  const [webUrl, setWebUrl] = useState('https://apple.com/ios26-showcase');
  const [isWebLoading, setIsWebLoading] = useState(false);
  const [readerMode, setReaderMode] = useState(false);

  // Rich Text & Apple Intelligence States
  const [richText, setRichText] = useState("LeukQuant 2026 Core is operating with Swift 6 Strict Concurrency and zero-dependency Liquid Glass UI architecture.");
  const [aiGenerating, setAiGenerating] = useState(false);
  const [aiSummary, setAiSummary] = useState(null);

  // @Animatable & SF Symbol Draw States
  const [symbolDrawing, setSymbolDrawing] = useState(true);
  const [animProgress, setAnimProgress] = useState(85);
  const [morphShape, setMorphShape] = useState(0);

  // Section Index States
  const [activeLetter, setActiveLetter] = useState('L');

  // Trigger Symbol Draw animation loop
  useEffect(() => {
    const timer = setInterval(() => {
      setSymbolDrawing(prev => !prev);
    }, 4000);
    return () => clearInterval(timer);
  }, []);

  const handleAiAction = (promptType) => {
    sounds.playChime();
    setAiGenerating(true);
    setAiSummary(null);

    setTimeout(() => {
      setAiGenerating(false);
      if (promptType === 'summarize') {
        setAiSummary("✨ Apple Intelligence Summary: LeukQuant iOS 26 utilizes unified SIMD hardware acceleration with hardware-level memory isolation, reducing threat triage response latency by 74%.");
      } else if (promptType === 'polish') {
        setAiSummary("✨ Polished Intent: High-integrity biomedical sensor mesh verified on VisionOS and Tahoe with zero concurrency race conditions.");
      } else {
        setAiSummary("✨ Security Brief: Perimeter intact across 12 decoy clusters. No uncontained egress anomalies detected in active epoch.");
      }
    }, 1200);
  };

  const tintStyles = {
    clear: 'bg-white/60 dark:bg-white/10 text-black dark:text-white',
    cyan: 'bg-cyan-500/20 text-cyan-400 border-cyan-400/40',
    purple: 'bg-purple-500/25 text-fuchsia-300 border-purple-400/40',
    emerald: 'bg-emerald-500/20 text-emerald-400 border-emerald-400/40',
    amber: 'bg-amber-500/20 text-amber-300 border-amber-400/40',
    sapphire: 'bg-blue-600/25 text-sky-400 border-blue-400/40'
  };

  const shapeStyles = {
    rect: 'rounded-none',
    squircle: 'rounded-[26px]',
    capsule: 'rounded-full',
    circle: 'rounded-full aspect-square w-32 mx-auto flex items-center justify-center'
  };

  const alphabet = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'];

  return (
    <div className="flex-1 flex flex-col pb-6">
      {/* Header */}
      <IosNavigationBar
        title="SwiftUI iOS 26"
        subtitle="Liquid Glass Feature Map & Lab"
        isDark={isDark}
        onToggleTheme={onToggleTheme}
        onOpenSettings={onOpenSettings}
      />

      {/* Feature Selector Tabs */}
      <div className="px-4 pt-3 pb-2">
        <IosSegmentedControl
          options={[
            { label: '🔮 Glass', value: 'liquid-glass' },
            { label: '📊 3D Charts', value: 'chart3d' },
            { label: '🌐 WebView', value: 'webview' },
            { label: '✍️ Siri AI', value: 'richtext' },
            { label: '⚡ Animate', value: 'animatable' },
            { label: '🏷️ Scrubber', value: 'section-index' }
          ]}
          value={activeFeatureTab}
          onChange={setActiveFeatureTab}
        />
      </div>

      <div className="px-4 py-2 space-y-4">
        {/* =========================================================================
            TAB 1: 🔮 LIQUID GLASS STUDIO & PLAYGROUND
            ========================================================================= */}
        {activeFeatureTab === 'liquid-glass' && (
          <div className="space-y-4 animate-in fade-in duration-300">
            {/* Live Interactive Glass Sandbox Viewport */}
            <div className="p-6 rounded-[32px] bg-gradient-to-tr from-blue-600/20 via-purple-600/20 to-pink-500/20 border border-white/20 relative overflow-hidden shadow-2xl flex flex-col items-center justify-center min-h-[220px]">
              {/* Dynamic specimen box */}
              <div
                className={`p-6 transition-all duration-300 border relative ${shapeStyles[glassShape]} ${tintStyles[glassTint]} ${
                  shimmerActive ? 'shimmer-active' : ''
                } ${chromaticAberration ? 'ios26-chromatic-edge' : ''}`}
                style={{
                  backdropFilter: `blur(${blurRadius}px) saturate(${saturation}%)`,
                  WebkitBackdropFilter: `blur(${blurRadius}px) saturate(${saturation}%)`,
                  boxShadow: specularHighlight
                    ? '0 16px 40px rgba(0,0,0,0.35), inset 0 1.5px 1.5px rgba(255,255,255,0.75)'
                    : '0 8px 24px rgba(0,0,0,0.2)'
                }}
              >
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-xl bg-gradient-to-tr from-ios-blue to-purple-600 flex items-center justify-center text-white shadow-lg">
                    <Sparkles size={22} className="animate-spin-slow" />
                  </div>
                  <div>
                    <h3 className="text-[17px] font-bold tracking-tight">Liquid Glass 2026</h3>
                    <p className="text-[12px] opacity-80 font-mono">
                      blur({blurRadius}px) • sat({saturation}%)
                    </p>
                  </div>
                </div>

                <div className="mt-4 flex gap-2">
                  <button
                    onClick={() => {
                      sounds.playPop();
                      setShimmerActive(true);
                      setTimeout(() => setShimmerActive(false), 2600);
                    }}
                    className="px-3.5 py-1.5 rounded-full bg-white/25 hover:bg-white/35 text-[12px] font-bold backdrop-blur-md shadow-sm ios-press-spring border border-white/40"
                  >
                    Trigger Shimmer ✨
                  </button>
                  <button
                    onClick={() => sounds.playChime()}
                    className="px-3.5 py-1.5 rounded-full bg-ios-blue/30 text-sky-200 text-[12px] font-bold backdrop-blur-md shadow-sm ios-press-spring border border-sky-400/40"
                  >
                    Haptic Press 🔊
                  </button>
                </div>
              </div>
            </div>

            {/* Controls Panel */}
            <div className="p-4 rounded-[26px] ios26-glass-card space-y-4">
              <div className="flex items-center justify-between pb-2 border-b border-black/[0.06] dark:border-white/[0.08]">
                <span className="text-[13px] font-bold uppercase tracking-wider text-[#6B7280] dark:text-[#9BA1B0]">
                  Glass Parameters
                </span>
                <span className="text-[11px] font-mono text-ios-blue dark:text-sky-400 font-semibold">
                  .glassEffect()
                </span>
              </div>

              {/* Blur Radius Slider */}
              <div className="space-y-1.5">
                <div className="flex justify-between text-[13px] font-medium">
                  <span>Blur Radius</span>
                  <span className="font-mono text-ios-blue dark:text-sky-400 font-bold">{blurRadius}px</span>
                </div>
                <input
                  type="range"
                  min="8"
                  max="60"
                  value={blurRadius}
                  onChange={(e) => {
                    sounds.playTap();
                    setBlurRadius(Number(e.target.value));
                  }}
                  className="w-full accent-ios-blue cursor-pointer"
                />
              </div>

              {/* Saturation Slider */}
              <div className="space-y-1.5">
                <div className="flex justify-between text-[13px] font-medium">
                  <span>Backdrop Saturation</span>
                  <span className="font-mono text-ios-blue dark:text-sky-400 font-bold">{saturation}%</span>
                </div>
                <input
                  type="range"
                  min="100"
                  max="300"
                  value={saturation}
                  onChange={(e) => {
                    sounds.playTap();
                    setSaturation(Number(e.target.value));
                  }}
                  className="w-full accent-ios-blue cursor-pointer"
                />
              </div>

              {/* Tint Selector */}
              <div className="space-y-2">
                <span className="text-[13px] font-medium">Semantic Glass Tint</span>
                <div className="grid grid-cols-6 gap-2">
                  {[
                    { id: 'clear', bg: 'bg-white/80 dark:bg-white/30', label: 'Clear' },
                    { id: 'cyan', bg: 'bg-cyan-400', label: 'Cyan' },
                    { id: 'purple', bg: 'bg-purple-500', label: 'Siri' },
                    { id: 'emerald', bg: 'bg-emerald-400', label: 'Emerald' },
                    { id: 'amber', bg: 'bg-amber-400', label: 'Amber' },
                    { id: 'sapphire', bg: 'bg-blue-600', label: 'Sapphire' }
                  ].map((tint) => (
                    <button
                      key={tint.id}
                      onClick={() => {
                        sounds.playPop();
                        setGlassTint(tint.id);
                      }}
                      className={`h-8 rounded-xl ${tint.bg} shadow-md border-2 transition-all flex items-center justify-center ${
                        glassTint === tint.id ? 'border-white scale-110 ring-2 ring-ios-blue' : 'border-transparent opacity-70 hover:opacity-100'
                      }`}
                    >
                      {glassTint === tint.id && <Check size={14} className="text-white drop-shadow" />}
                    </button>
                  ))}
                </div>
              </div>

              {/* Shape Morpher */}
              <div className="space-y-2">
                <span className="text-[13px] font-medium">Shape Primitive</span>
                <div className="grid grid-cols-4 gap-2">
                  {['squircle', 'capsule', 'rect', 'circle'].map((shape) => (
                    <button
                      key={shape}
                      onClick={() => {
                        sounds.playTap();
                        setGlassShape(shape);
                      }}
                      className={`py-1.5 px-2 rounded-xl text-[12px] font-semibold capitalize border transition-all ${
                        glassShape === shape
                          ? 'bg-ios-blue text-white border-transparent shadow-md'
                          : 'bg-black/5 dark:bg-white/5 border-white/10 text-gray-400 hover:text-white'
                      }`}
                    >
                      .{shape}
                    </button>
                  ))}
                </div>
              </div>

              {/* Specular & Chromatic Toggles */}
              <div className="pt-2 space-y-3 border-t border-black/[0.06] dark:border-white/[0.08]">
                <div className="flex items-center justify-between">
                  <span className="text-[14px] font-medium">Specular Top Highlight</span>
                  <IosSwitch checked={specularHighlight} onChange={setSpecularHighlight} />
                </div>
                <div className="flex items-center justify-between">
                  <span className="text-[14px] font-medium">Chromatic Edge Refraction</span>
                  <IosSwitch checked={chromaticAberration} onChange={setChromaticAberration} />
                </div>
              </div>
            </div>
          </div>
        )}

        {/* =========================================================================
            TAB 2: 📊 CHART3D & SURFACE PLOT VISUALIZER
            ========================================================================= */}
        {activeFeatureTab === 'chart3d' && (
          <div className="space-y-4 animate-in fade-in duration-300">
            <div className="p-4 rounded-[28px] ios26-glass-card space-y-3">
              <div className="flex items-center justify-between">
                <div>
                  <h3 className="text-[17px] font-bold text-black dark:text-white">Chart3D & SurfacePlot</h3>
                  <p className="text-[12px] text-[#8E8E93] dark:text-[#9BA1B0]">
                    Native iOS 26 spatial data surface with 3D rotation
                  </p>
                </div>
                <span className="px-2 py-0.5 rounded-full bg-ios-purple/20 text-fuchsia-400 text-[11px] font-bold">
                  iOS 26 API
                </span>
              </div>

              {/* 3D Interactive Spatial Voxel Canvas */}
              <div
                className="w-full h-[260px] rounded-[24px] bg-[#0A0E18] border border-white/15 relative overflow-hidden flex items-center justify-center cursor-grab active:cursor-grabbing perspective-1000"
                onMouseMove={(e) => {
                  if (e.buttons === 1) {
                    setRotationY(prev => prev + e.movementX * 0.8);
                    setRotationX(prev => Math.max(-60, Math.min(60, prev - e.movementY * 0.8)));
                  }
                }}
              >
                {/* 3D Surface Grid Container */}
                <div
                  className="transform-style-3d transition-transform duration-75 flex flex-col items-center justify-center"
                  style={{
                    transform: `rotateX(${rotationX}deg) rotateY(${rotationY}deg)`
                  }}
                >
                  {/* Isometric 4x4 Voxel Matrix */}
                  <div className="grid grid-cols-4 gap-3 p-4 bg-white/5 rounded-3xl border border-white/20 shadow-2xl backdrop-blur-md">
                    {[
                      { x: 0, y: 0, z: 85, label: "Cell-Alpha", color: "from-blue-500 to-indigo-600" },
                      { x: 0, y: 1, z: 62, label: "Ingress-SSH", color: "from-sky-400 to-blue-600" },
                      { x: 0, y: 2, z: 94, label: "Decoy-01", color: "from-purple-500 to-pink-600" },
                      { x: 0, y: 3, z: 45, label: "Canary-A", color: "from-indigo-400 to-blue-700" },

                      { x: 1, y: 0, z: 30, label: "Port-443", color: "from-teal-400 to-emerald-600" },
                      { x: 1, y: 1, z: 98, label: "Anomaly-X", color: "from-rose-500 to-red-600" },
                      { x: 1, y: 2, z: 75, label: "Decoy-02", color: "from-purple-400 to-indigo-600" },
                      { x: 1, y: 3, z: 50, label: "Canary-B", color: "from-blue-500 to-indigo-500" },

                      { x: 2, y: 0, z: 88, label: "Cytometry", color: "from-blue-600 to-purple-600" },
                      { x: 2, y: 1, z: 42, label: "DNS-Sensor", color: "from-sky-500 to-teal-600" },
                      { x: 2, y: 2, z: 90, label: "Decoy-03", color: "from-fuchsia-500 to-pink-600" },
                      { x: 2, y: 3, z: 68, label: "Canary-C", color: "from-indigo-500 to-blue-600" },

                      { x: 3, y: 0, z: 55, label: "TLS-Proxy", color: "from-emerald-400 to-teal-600" },
                      { x: 3, y: 1, z: 72, label: "Redis-Drop", color: "from-amber-400 to-orange-600" },
                      { x: 3, y: 2, z: 96, label: "Decoy-04", color: "from-pink-500 to-rose-600" },
                      { x: 3, y: 3, z: 80, label: "Canary-D", color: "from-blue-400 to-indigo-600" }
                    ].map((voxel, idx) => (
                      <div
                        key={idx}
                        onClick={() => {
                          sounds.playPop();
                          setSelectedVoxel(voxel);
                        }}
                        className={`w-10 h-10 rounded-xl bg-gradient-to-t ${voxel.color} flex flex-col items-center justify-center text-white cursor-pointer shadow-lg transition-transform hover:scale-125 border border-white/40 ${
                          selectedVoxel?.label === voxel.label ? 'ring-2 ring-white scale-125 animate-pulse' : ''
                        }`}
                        style={{
                          transform: `translateZ(${voxel.z * 0.7}px)`,
                          height: `${30 + voxel.z * 0.4}px`
                        }}
                      >
                        <span className="text-[10px] font-bold drop-shadow">{voxel.z}</span>
                      </div>
                    ))}
                  </div>
                </div>

                {/* Drag to rotate hint */}
                <div className="absolute bottom-2.5 left-3 text-[11px] text-gray-400 flex items-center gap-1.5 bg-black/60 px-2.5 py-1 rounded-full backdrop-blur-md border border-white/10 pointer-events-none">
                  <Rotate3d size={13} className="text-sky-400" />
                  <span>Drag spatial canvas to rotate</span>
                </div>
              </div>

              {/* Selected Voxel Detail */}
              {selectedVoxel && (
                <div className="p-3.5 rounded-2xl bg-white/10 border border-white/15 flex items-center justify-between animate-in fade-in">
                  <div>
                    <div className="text-[14px] font-bold text-white flex items-center gap-2">
                      <span>{selectedVoxel.label}</span>
                      <span className="text-[11px] font-mono text-sky-400 bg-sky-500/20 px-2 py-0.5 rounded-full">
                        Val: {selectedVoxel.z}
                      </span>
                    </div>
                    <div className="text-[11px] text-gray-400 font-mono">
                      Spatial Coords: X={selectedVoxel.x}, Y={selectedVoxel.y}, Z={selectedVoxel.z}
                    </div>
                  </div>
                  <button
                    onClick={() => setSelectedVoxel(null)}
                    className="text-[12px] font-semibold text-sky-400 hover:text-white px-2 py-1"
                  >
                    Clear
                  </button>
                </div>
              )}

              {/* Swift Code Snippet */}
              <div className="p-3 rounded-2xl bg-black/40 font-mono text-[11px] text-sky-300 border border-white/10 space-y-1">
                <span className="text-gray-400">// iOS 26 Chart3D API</span>
                <div>
                  <span className="text-purple-400">Chart3D</span> &#123;
                </div>
                <div className="pl-4">
                  <span className="text-purple-400">SurfacePlot</span>(data: surfaceData) &#123; pt <span className="text-pink-400">in</span>
                </div>
                <div className="pl-8">
                  <span className="text-purple-400">SurfaceMark</span>(x: pt.x, y: pt.y, z: pt.z)
                </div>
                <div className="pl-4">&#125;</div>
                <div>&#125;.<span className="text-sky-400">chart3DRotation</span>(x: .degrees({Math.round(rotationX)}), y: .degrees({Math.round(rotationY)}))</div>
              </div>
            </div>
          </div>
        )}

        {/* =========================================================================
            TAB 3: 🌐 NATIVE WEBVIEW 26
            ========================================================================= */}
        {activeFeatureTab === 'webview' && (
          <div className="space-y-4 animate-in fade-in duration-300">
            <div className="rounded-[28px] ios26-glass-card overflow-hidden shadow-2xl border border-white/20">
              {/* Liquid Glass Address Bar */}
              <div className="p-3 bg-black/10 dark:bg-white/5 border-b border-black/[0.06] dark:border-white/[0.08] flex items-center gap-2">
                <div className="flex-1 h-9 rounded-full ios26-glass px-3 flex items-center justify-between shadow-inner">
                  <div className="flex items-center gap-2 min-w-0">
                    <Lock size={13} className="text-ios-green shrink-0" />
                    <span className="text-[12px] font-mono font-medium truncate text-black dark:text-white">
                      {webUrl}
                    </span>
                  </div>
                  <button
                    onClick={() => {
                      sounds.playTap();
                      setIsWebLoading(true);
                      setTimeout(() => setIsWebLoading(false), 900);
                    }}
                    className="p-1 text-gray-400 hover:text-black dark:hover:text-white"
                  >
                    <RefreshCw size={13} className={isWebLoading ? 'animate-spin text-ios-blue' : ''} />
                  </button>
                </div>

                <button
                  onClick={() => {
                    sounds.playPop();
                    setReaderMode(!readerMode);
                  }}
                  className={`px-3 py-1.5 rounded-full text-[11px] font-bold transition-all ${
                    readerMode ? 'bg-ios-blue text-white' : 'bg-black/10 dark:bg-white/10 text-gray-400'
                  }`}
                >
                  Reader
                </button>
              </div>

              {/* WebView Render Body */}
              <div className="p-6 min-h-[260px] bg-white/60 dark:bg-[#0E121E]/80 backdrop-blur-xl flex flex-col justify-center text-left space-y-3">
                <div className="flex items-center gap-2.5">
                  <div className="w-8 h-8 rounded-xl bg-gradient-to-tr from-ios-blue to-indigo-600 flex items-center justify-center text-white">
                    <Globe size={18} />
                  </div>
                  <div>
                    <h4 className="text-[16px] font-bold text-black dark:text-white">
                      Native SwiftUI WebView
                    </h4>
                    <p className="text-[11px] text-gray-400">Zero UIViewRepresentable boilerplate</p>
                  </div>
                </div>

                <p className="text-[13px] text-gray-700 dark:text-gray-300 leading-relaxed">
                  In iOS 26, <code className="text-ios-blue dark:text-sky-400 font-mono">WebView(url:)</code> is a first-class citizen of SwiftUI. It supports declarative lifecycle delegates, native reader mode, and seamless Liquid Glass overlays.
                </p>

                <div className="p-3 rounded-2xl bg-black/5 dark:bg-white/5 border border-white/10 text-[12px] space-y-1">
                  <div className="font-bold text-ios-green flex items-center gap-1">
                    <Check size={14} />
                    <span>Hardware Accelerated Compositor Active</span>
                  </div>
                  <div className="text-gray-400">FPS: 120Hz ProMotion • WebGL 3D: Enabled</div>
                </div>
              </div>
            </div>
          </div>
        )}

        {/* =========================================================================
            TAB 4: ✍️ RICH TEXTEDITOR & SIRI APPLE INTELLIGENCE
            ========================================================================= */}
        {activeFeatureTab === 'richtext' && (
          <div className="space-y-4 animate-in fade-in duration-300">
            <div className="p-4 rounded-[28px] ios26-glass-card relative overflow-hidden space-y-3 siri-glow border border-fuchsia-500/30">
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <div className="w-7 h-7 rounded-lg bg-gradient-to-tr from-pink-500 via-purple-600 to-indigo-600 flex items-center justify-center text-white shadow-md">
                    <Brain size={16} />
                  </div>
                  <h3 className="text-[16px] font-bold siri-gradient-text">
                    Siri Apple Intelligence Editor
                  </h3>
                </div>
                <span className="text-[11px] font-mono text-purple-400 font-semibold">
                  AttributedString
                </span>
              </div>

              {/* Rich Text Toolbar */}
              <div className="flex items-center gap-1.5 p-1 rounded-xl bg-black/10 dark:bg-white/5 border border-white/10">
                <button
                  onClick={() => sounds.playTap()}
                  className="p-1.5 rounded-lg text-gray-300 hover:text-white hover:bg-white/10"
                >
                  <Bold size={14} />
                </button>
                <button
                  onClick={() => sounds.playTap()}
                  className="p-1.5 rounded-lg text-gray-300 hover:text-white hover:bg-white/10"
                >
                  <Italic size={14} />
                </button>
                <button
                  onClick={() => sounds.playTap()}
                  className="p-1.5 rounded-lg text-gray-300 hover:text-white hover:bg-white/10"
                >
                  <Underline size={14} />
                </button>
                <button
                  onClick={() => sounds.playTap()}
                  className="p-1.5 rounded-lg text-gray-300 hover:text-white hover:bg-white/10"
                >
                  <Code size={14} />
                </button>
                <div className="h-4 w-[1px] bg-white/20 mx-1" />
                <button
                  onClick={() => sounds.playTap()}
                  className="p-1.5 rounded-lg text-gray-300 hover:text-white hover:bg-white/10"
                >
                  <List size={14} />
                </button>
              </div>

              {/* Text Area */}
              <textarea
                value={richText}
                onChange={(e) => setRichText(e.target.value)}
                rows={4}
                className="w-full p-3 rounded-2xl bg-black/10 dark:bg-white/5 border border-white/10 text-black dark:text-white text-[14px] leading-relaxed focus:outline-none focus:ring-2 focus:ring-purple-500/50 resize-none font-medium"
              />

              {/* Apple Intelligence Quick Prompts */}
              <div className="space-y-2">
                <div className="text-[11px] font-bold text-gray-400 uppercase tracking-wider">
                  On-Device Foundation Model Actions
                </div>
                <div className="flex flex-wrap gap-2">
                  <button
                    disabled={aiGenerating}
                    onClick={() => handleAiAction('summarize')}
                    className="px-3 py-1.5 rounded-full bg-gradient-to-r from-pink-500/30 to-purple-600/30 border border-purple-400/40 text-[12px] font-semibold text-fuchsia-200 hover:brightness-125 ios-press-spring flex items-center gap-1.5 shadow-sm"
                  >
                    <Sparkles size={13} className="text-pink-300" />
                    <span>Summarize</span>
                  </button>
                  <button
                    disabled={aiGenerating}
                    onClick={() => handleAiAction('polish')}
                    className="px-3 py-1.5 rounded-full bg-gradient-to-r from-blue-500/30 to-indigo-600/30 border border-blue-400/40 text-[12px] font-semibold text-sky-200 hover:brightness-125 ios-press-spring flex items-center gap-1.5 shadow-sm"
                  >
                    <Zap size={13} className="text-sky-300" />
                    <span>Polish Intent</span>
                  </button>
                  <button
                    disabled={aiGenerating}
                    onClick={() => handleAiAction('brief')}
                    className="px-3 py-1.5 rounded-full bg-gradient-to-r from-emerald-500/30 to-teal-600/30 border border-emerald-400/40 text-[12px] font-semibold text-emerald-200 hover:brightness-125 ios-press-spring flex items-center gap-1.5 shadow-sm"
                  >
                    <Shield size={13} className="text-emerald-300" />
                    <span>Threat Briefing</span>
                  </button>
                </div>
              </div>

              {/* AI Generating Indicator or Output Result */}
              {aiGenerating && (
                <div className="p-3 rounded-2xl bg-purple-500/15 border border-purple-400/30 text-[13px] text-fuchsia-200 flex items-center gap-2 animate-pulse">
                  <Sparkles size={16} className="text-pink-400 animate-spin" />
                  <span>Siri Neural Engine synthesizing intent...</span>
                </div>
              )}

              {aiSummary && (
                <div className="p-3.5 rounded-2xl bg-purple-950/60 border border-purple-400/40 text-[13px] text-fuchsia-100 leading-relaxed shadow-xl animate-in zoom-in-95 duration-200">
                  {aiSummary}
                </div>
              )}
            </div>
          </div>
        )}

        {/* =========================================================================
            TAB 5: ⚡ @ANIMATABLE & SF SYMBOLS DRAW
            ========================================================================= */}
        {activeFeatureTab === 'animatable' && (
          <div className="space-y-4 animate-in fade-in duration-300">
            <div className="p-5 rounded-[28px] ios26-glass-card space-y-4">
              <div className="flex items-center justify-between">
                <div>
                  <h3 className="text-[17px] font-bold text-black dark:text-white">@Animatable Macro & SF Draw</h3>
                  <p className="text-[12px] text-[#8E8E93] dark:text-[#9BA1B0]">
                    Zero manual animatableData boilerplate
                  </p>
                </div>
                <button
                  onClick={() => {
                    sounds.playPop();
                    setMorphShape((prev) => (prev + 1) % 3);
                  }}
                  className="px-3 py-1 rounded-full bg-ios-blue text-white text-[12px] font-semibold ios-press-spring shadow-md"
                >
                  Morph Shape
                </button>
              </div>

              {/* Morphing Liquid Shape Canvas */}
              <div className="h-44 rounded-2xl bg-black/20 dark:bg-white/5 border border-white/10 flex items-center justify-center relative overflow-hidden">
                <div
                  className={`w-28 h-28 bg-gradient-to-tr from-ios-blue via-indigo-500 to-pink-500 shadow-2xl flex items-center justify-center text-white transition-all duration-700 ease-[cubic-bezier(0.34,1.56,0.64,1)] ${
                    morphShape === 0 ? 'rounded-[36px] rotate-0 scale-100' : morphShape === 1 ? 'rounded-full rotate-45 scale-110' : 'rounded-[12px] rotate-90 scale-95'
                  }`}
                >
                  <Shield size={44} className={`transition-transform duration-500 ${symbolDrawing ? 'scale-110 drop-shadow-[0_0_12px_#fff]' : 'scale-90'}`} />
                </div>
              </div>

              {/* Interactive Progress Slider */}
              <div className="space-y-1.5">
                <div className="flex justify-between text-[13px] font-medium">
                  <span>Animatable Progress</span>
                  <span className="font-mono text-ios-blue dark:text-sky-400 font-bold">{animProgress}%</span>
                </div>
                <input
                  type="range"
                  min="0"
                  max="100"
                  value={animProgress}
                  onChange={(e) => {
                    sounds.playTap();
                    setAnimProgress(Number(e.target.value));
                  }}
                  className="w-full accent-ios-blue cursor-pointer"
                />
              </div>

              {/* Code comparison */}
              <div className="p-3 rounded-2xl bg-black/30 font-mono text-[11px] text-gray-300 border border-white/10 space-y-1">
                <div className="text-ios-green font-bold">// iOS 26: Just add @Animatable!</div>
                <div><span className="text-pink-400">@Animatable</span></div>
                <div><span className="text-purple-400">struct</span> <span className="text-sky-300">ProgressRing</span>: <span className="text-amber-300">Shape</span> &#123;</div>
                <div className="pl-4"><span className="text-purple-400">var</span> progress: <span className="text-amber-300">Double</span></div>
                <div>&#125;</div>
              </div>
            </div>
          </div>
        )}

        {/* =========================================================================
            TAB 6: 🏷️ SECTION INDEX LABELS & MINIMIZING TABBAR
            ========================================================================= */}
        {activeFeatureTab === 'section-index' && (
          <div className="space-y-4 animate-in fade-in duration-300">
            <div className="p-4 rounded-[28px] ios26-glass-card space-y-3">
              <div className="flex items-center justify-between">
                <div>
                  <h3 className="text-[17px] font-bold text-black dark:text-white">Section Index Scrubber</h3>
                  <p className="text-[12px] text-[#8E8E93] dark:text-[#9BA1B0]">
                    Alphabetical index with floating magnifying glass
                  </p>
                </div>
                <span className="w-8 h-8 rounded-full bg-ios-blue text-white font-bold flex items-center justify-center text-[15px] shadow-lg">
                  {activeLetter}
                </span>
              </div>

              {/* Scrubber Bar Visualizer */}
              <div className="flex items-center justify-between p-2 rounded-2xl bg-black/10 dark:bg-white/5 border border-white/10 overflow-x-auto no-scrollbar gap-1">
                {alphabet.map((letter) => (
                  <button
                    key={letter}
                    onClick={() => {
                      sounds.playTap();
                      setActiveLetter(letter);
                    }}
                    className={`min-w-[20px] h-7 rounded-lg text-[12px] font-bold transition-all ${
                      activeLetter === letter
                        ? 'bg-ios-blue text-white scale-125 shadow-md'
                        : 'text-gray-400 hover:text-black dark:hover:text-white'
                    }`}
                  >
                    {letter}
                  </button>
                ))}
              </div>

              {/* Simulated Filtered Contact / Node List */}
              <div className="space-y-2 pt-2">
                {[
                  { name: `${activeLetter}lpha Decoy Sensor`, ip: "192.168.1.104", status: "Active" },
                  { name: `${activeLetter}pache Canary Node`, ip: "10.0.4.22", status: "Armed" },
                  { name: `${activeLetter}uthenticated Ingress Gateway`, ip: "172.16.0.8", status: "Monitoring" }
                ].map((item, i) => (
                  <div key={i} className="p-3 rounded-2xl bg-white/10 border border-white/10 flex items-center justify-between">
                    <div>
                      <div className="text-[14px] font-bold text-black dark:text-white">{item.name}</div>
                      <div className="text-[11px] font-mono text-gray-400">{item.ip}</div>
                    </div>
                    <span className="px-2.5 py-0.5 rounded-full bg-ios-green/20 text-ios-green text-[11px] font-semibold">
                      {item.status}
                    </span>
                  </div>
                ))}
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
