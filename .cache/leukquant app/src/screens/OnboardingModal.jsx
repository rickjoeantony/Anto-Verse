// src/screens/OnboardingModal.jsx
import React, { useState } from 'react';
import { Eye, Activity, ShieldCheck, ArrowRight, Check, Sparkles } from 'lucide-react';
import sounds from '../utils/soundEffects';

export default function OnboardingModal({ isOpen, onClose }) {
  const [currentStep, setCurrentStep] = useState(0);

  if (!isOpen) return null;

  const slides = [
    {
      title: "See Suspicious Activity Early",
      tagline: "OBSERVE",
      description:
        "Ghost-Net observes adversary interactions with synthetic decoy honeypots before attackers ever reach your production core.",
      icon: Eye,
      image: "/assets/images/onboard_observe_3d.jpg",
      iconBg: "from-blue-500 via-indigo-500 to-purple-600",
      stats: "12 Decoy Canaries Online",
      badge: "Real-time Telemetry"
    },
    {
      title: "Understand Every Signal",
      tagline: "UNDERSTAND",
      description:
        "Transform raw ingress packets and honeytoken triggers into structured timelines, precise classification, and actionable guidance.",
      icon: Activity,
      image: "/assets/images/onboard_understand_3d.jpg",
      iconBg: "from-indigo-500 via-purple-600 to-pink-600",
      stats: "Zero Credential Leakage",
      badge: "Strict Privacy by Design"
    },
    {
      title: "Act With Pure Confidence",
      tagline: "ACT",
      description:
        "Isolate adversary source ASNs with one tap, auto-rotate compromised decoy canary keys, and maintain immutable audit reports.",
      icon: ShieldCheck,
      image: "/assets/images/onboard_act_3d.jpg",
      iconBg: "from-emerald-500 via-teal-500 to-cyan-600",
      stats: "100% Contained & Audited",
      badge: "SOC 2 & ISO 27001 Ready"
    }
  ];

  const slide = slides[currentStep];
  const Icon = slide.icon;

  const handleNext = () => {
    sounds.playTap();
    if (currentStep < slides.length - 1) {
      setCurrentStep(currentStep + 1);
    } else {
      sounds.playChime();
      onClose();
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
      {/* Backdrop */}
      <div
        className="fixed inset-0 bg-black/70 dark:bg-black/85 backdrop-blur-xl transition-opacity animate-in fade-in"
        onClick={() => {
          sounds.playTap();
          onClose();
        }}
      />

      {/* Liquid Glass Modal Container */}
      <div className="relative w-full max-w-[400px] rounded-[36px] ios26-glass-thick shadow-2xl overflow-hidden border border-white/25 z-10 flex flex-col p-6 text-center animate-in zoom-in-95 duration-200">
        {/* Specular top */}
        <div className="absolute top-0 left-6 right-6 h-[1.5px] bg-gradient-to-r from-transparent via-white/70 to-transparent pointer-events-none" />

        {/* Skip button */}
        <div className="flex justify-end">
          <button
            onClick={() => {
              sounds.playTap();
              onClose();
            }}
            className="text-[14px] font-semibold text-[#8E8E93] dark:text-[#9BA1B0] hover:text-black dark:hover:text-white ios-press-spring px-2 py-1"
          >
            Skip
          </button>
        </div>

        {/* Hero 3D Graphic / Vector Visual */}
        <div className="my-3 flex flex-col items-center justify-center">
          <div className="relative w-full h-44 rounded-[26px] overflow-hidden shadow-2xl border border-white/30 bg-black/40 mb-3 flex items-center justify-center">
            {slide.image && (
              <img
                src={slide.image}
                alt={slide.title}
                className="w-full h-full object-cover"
                onError={(e) => {
                  e.target.style.display = 'none';
                }}
              />
            )}
            <div className="absolute inset-0 bg-gradient-to-t from-black/60 via-transparent to-transparent pointer-events-none" />
            
            <div className="absolute bottom-3 left-3 flex items-center gap-2">
              <div
                className={`w-9 h-9 rounded-[14px] bg-gradient-to-tr ${slide.iconBg} text-white flex items-center justify-center shadow-lg border border-white/40`}
              >
                <Icon size={20} strokeWidth={2.2} />
              </div>
              <span className="px-3 py-0.5 rounded-full text-[10px] font-extrabold tracking-wider uppercase bg-white/20 backdrop-blur-md text-white border border-white/30 shadow-sm">
                {slide.tagline}
              </span>
            </div>
          </div>
        </div>

        {/* Text Content */}
        <h2 className="text-[20px] font-extrabold text-black dark:text-white tracking-tight leading-tight mb-2">
          {slide.title}
        </h2>

        <p className="text-[13.5px] text-[#6C6C70] dark:text-[#9BA1B0] leading-relaxed mb-4 px-1 font-normal">
          {slide.description}
        </p>

        {/* Stat Pill */}
        <div className="mb-4 mx-auto inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full ios26-glass text-[12px] font-semibold text-black dark:text-white shadow-sm border border-white/20">
          <span className="w-2 h-2 rounded-full bg-ios-green animate-pulse" />
          <span>{slide.stats}</span>
        </div>

        {/* Pagination Dots */}
        <div className="flex items-center justify-center space-x-2 mb-5">
          {slides.map((_, idx) => (
            <button
              key={idx}
              onClick={() => {
                sounds.playTap();
                setCurrentStep(idx);
              }}
              className={`h-2 rounded-full transition-all duration-300 ${
                currentStep === idx
                  ? 'w-7 bg-ios-blue shadow-md'
                  : 'w-2 bg-[#C7C7CC] dark:bg-[#48484A]'
              }`}
            />
          ))}
        </div>

        {/* Primary Action Button */}
        <button
          onClick={handleNext}
          className="w-full py-3.5 px-6 rounded-[16px] bg-gradient-to-r from-ios-blue to-indigo-600 text-white text-[15px] font-bold flex items-center justify-center gap-2 shadow-xl hover:brightness-110 ios-press-spring border border-white/20"
        >
          {currentStep === slides.length - 1 ? (
            <>
              <span>Get Started with LeukQuant</span>
              <Check size={18} strokeWidth={2.8} />
            </>
          ) : (
            <>
              <span>Continue</span>
              <ArrowRight size={18} strokeWidth={2.5} />
            </>
          )}
        </button>
      </div>
    </div>
  );
}
