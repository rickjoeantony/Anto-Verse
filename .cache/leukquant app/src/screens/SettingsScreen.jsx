// src/screens/SettingsScreen.jsx
import React, { useState } from 'react';
import IosNavigationBar from '../components/ios/IosNavigationBar';
import { IosInsetGroup, IosCell } from '../components/ios/IosInsetGroup';
import IosSwitch from '../components/ios/IosSwitch';
import IosSegmentedControl from '../components/ios/IosSegmentedControl';
import IosActionSheet from '../components/ios/IosActionSheet';
import { MOCK_ANALYST } from '../data/mockData';
import WALLPAPERS from '../data/wallpapers';
import sounds from '../utils/soundEffects';
import {
  User,
  Shield,
  Fingerprint,
  Bell,
  Radio,
  Server,
  Lock,
  LogOut,
  Sparkles,
  Palette,
  Volume2,
  Check,
  Cpu,
  Brain
} from 'lucide-react';

export default function SettingsScreen({
  themeMode,
  onThemeModeChange,
  onOpenOnboarding,
  isDark,
  onToggleTheme,
  currentWallpaper,
  onWallpaperChange,
  soundEnabled,
  onToggleSound,
  dynamicLightingEnabled,
  onToggleDynamicLighting
}) {
  const [faceIdEnabled, setFaceIdEnabled] = useState(true);
  const [credentialMasking, setCredentialMasking] = useState(true);
  const [autoQuarantine, setAutoQuarantine] = useState(true);
  const [pushAlerts, setPushAlerts] = useState(true);
  const [appleIntelligenceActive, setAppleIntelligenceActive] = useState(true);
  const [showSignOutActionSheet, setShowSignOutActionSheet] = useState(false);
  const [signedOutNotice, setSignedOutNotice] = useState(false);

  return (
    <div className="pb-12">
      <IosNavigationBar
        title="Settings 26"
        subtitle="Analyst Preferences & Liquid Glass Core"
        isDark={isDark}
        onToggleTheme={onToggleTheme}
      />

      {/* Analyst Profile Header Card with Liquid Glass */}
      <div className="mx-4 mt-3 mb-3.5 p-4 rounded-[26px] ios26-glass-card flex items-center space-x-3.5 relative overflow-hidden shadow-xl border border-white/25">
        <div className="relative">
          <img
            src={MOCK_ANALYST.avatarUrl}
            alt="Profile Avatar"
            onError={(e) => {
              e.target.style.display = 'none';
              e.target.nextSibling.style.display = 'flex';
            }}
            className="w-14 h-14 rounded-full object-cover ring-2 ring-ios-blue/50 shadow-md"
          />
          <div className="hidden w-14 h-14 rounded-full bg-gradient-to-tr from-ios-blue to-indigo-600 items-center justify-center text-white font-extrabold text-lg ring-2 ring-ios-blue/50 shadow-md">
            RA
          </div>
          <span className="absolute bottom-0 right-0 w-4 h-4 rounded-full bg-ios-green border-2 border-white dark:border-[#121624]" />
        </div>

        <div className="flex-1 min-w-0">
          <h3 className="text-[17px] font-extrabold text-black dark:text-white tracking-tight truncate">
            {MOCK_ANALYST.name}
          </h3>
          <p className="text-[13px] text-ios-blue dark:text-sky-400 font-bold truncate">
            {MOCK_ANALYST.role}
          </p>
          <p className="text-[11px] text-[#8E8E93] dark:text-[#9BA1B0] truncate mt-0.5">
            {MOCK_ANALYST.clearance} • {MOCK_ANALYST.clusterId}
          </p>
        </div>
      </div>

      {/* iOS 26 Dynamic Wallpaper Selector Inset Group */}
      <IosInsetGroup
        header="iOS 26 Dynamic Wallpapers"
        footer="Dynamic wallpapers interact with cursor light reflections and liquid glass refraction."
      >
        <div className="p-3 grid grid-cols-3 gap-2">
          {WALLPAPERS.map((wp) => (
            <button
              key={wp.id}
              onClick={() => {
                sounds.playPop();
                if (onWallpaperChange) onWallpaperChange(wp.id);
              }}
              className={`relative p-2.5 rounded-[16px] flex flex-col items-center justify-center text-center transition-all ios-press-spring border ${
                currentWallpaper === wp.id
                  ? 'bg-white/20 border-ios-blue ring-2 ring-ios-blue/60 shadow-lg'
                  : 'bg-black/5 dark:bg-white/5 border-white/10 hover:bg-white/10'
              }`}
            >
              <span className={`w-8 h-8 rounded-full bg-gradient-to-tr ${wp.previewGradient} shadow-md ring-1 ring-white/50 mb-1.5`} />
              <span className="text-[11px] font-bold truncate text-black dark:text-white">
                {wp.name}
              </span>
              {currentWallpaper === wp.id && (
                <div className="absolute top-1.5 right-1.5 w-4 h-4 rounded-full bg-ios-blue text-white flex items-center justify-center">
                  <Check size={10} strokeWidth={3} />
                </div>
              )}
            </button>
          ))}
        </div>
      </IosInsetGroup>

      {/* Appearance Inset Group */}
      <IosInsetGroup
        header="Theme & Glass Mode"
        footer="Select your preferred display theme. Matches iOS system settings seamlessly."
      >
        <div className="p-3">
          <IosSegmentedControl
            options={[
              { label: 'System', value: 'system' },
              { label: 'Light', value: 'light' },
              { label: 'Dark', value: 'dark' }
            ]}
            value={themeMode}
            onChange={onThemeModeChange}
          />
        </div>
      </IosInsetGroup>

      {/* Audio & Haptic Synthesizer */}
      <IosInsetGroup
        header="Audio & Spatial Haptics"
        footer="Web Audio synthesizer replicates authentic Apple iOS tactile click and pop cues."
      >
        <IosCell
          icon={Volume2}
          iconColor="bg-ios-pink text-white"
          title="Native iOS UI Sound Effects"
          subtitle="Synthesized haptic clicks, pops and chimes"
          chevron={false}
          rightElement={
            <IosSwitch checked={soundEnabled} onChange={onToggleSound} />
          }
          showSeparator={true}
        />
        <IosCell
          icon={Sparkles}
          iconColor="bg-ios-cyan text-white"
          title="Pointer Dynamic Lighting"
          subtitle="Specular border reflections following cursor"
          chevron={false}
          rightElement={
            <IosSwitch checked={dynamicLightingEnabled} onChange={onToggleDynamicLighting} />
          }
          showSeparator={false}
        />
      </IosInsetGroup>

      {/* Apple Intelligence & Neural Inset Group */}
      <IosInsetGroup
        header="Apple Intelligence 2026"
        footer="On-device 3B parameter neural engine assists in real-time threat categorization."
      >
        <IosCell
          icon={Brain}
          iconColor="bg-gradient-to-tr from-pink-500 to-purple-600 text-white"
          title="On-Device Siri Neural Engine"
          subtitle="Zero telemetry data leaves local hardware"
          chevron={false}
          rightElement={
            <IosSwitch checked={appleIntelligenceActive} onChange={setAppleIntelligenceActive} />
          }
          showSeparator={true}
        />
        <IosCell
          icon={Cpu}
          iconColor="bg-ios-purple text-white"
          title="SIMD Matrix Hardware Engine"
          value="Hardware Accelerated"
          chevron={false}
          showSeparator={false}
        />
      </IosInsetGroup>

      {/* Security & Privacy Guard */}
      <IosInsetGroup
        header="Security & Privacy Guard"
        footer="Leukquant strictly masks credentials and limits honeypot secrets exposure."
      >
        <IosCell
          icon={Fingerprint}
          iconColor="bg-ios-indigo text-white"
          title="Face ID Authentication"
          subtitle="Require biometric sign-in on unlock"
          chevron={false}
          rightElement={
            <IosSwitch checked={faceIdEnabled} onChange={setFaceIdEnabled} />
          }
          showSeparator={true}
        />
        <IosCell
          icon={Lock}
          iconColor="bg-ios-green text-white"
          title="Strict Honeytoken Masking"
          subtitle="Redact passwords to admin / **********"
          chevron={false}
          rightElement={
            <IosSwitch checked={credentialMasking} onChange={setCredentialMasking} />
          }
          showSeparator={true}
        />
        <IosCell
          icon={Shield}
          iconColor="bg-ios-red text-white"
          title="Auto-Quarantine Ingress Subnets"
          subtitle="Null-route confirmed scanner ASNs"
          chevron={false}
          rightElement={
            <IosSwitch checked={autoQuarantine} onChange={setAutoQuarantine} />
          }
          showSeparator={false}
        />
      </IosInsetGroup>

      {/* Notifications Inset Group */}
      <IosInsetGroup header="Alert Notifications">
        <IosCell
          icon={Bell}
          iconColor="bg-ios-red text-white"
          title="Critical Incident Push Alerts"
          chevron={false}
          rightElement={
            <IosSwitch checked={pushAlerts} onChange={setPushAlerts} />
          }
          showSeparator={false}
        />
      </IosInsetGroup>

      {/* Ghost-Net Sensors & Tour */}
      <IosInsetGroup header="Ghost-Net Decoy Mesh & Tour">
        <IosCell
          icon={Server}
          iconColor="bg-ios-teal text-white"
          title="Decoy Sensor Nodes"
          value="12/12 Online"
          chevron={true}
          showSeparator={true}
        />
        <IosCell
          icon={Sparkles}
          iconColor="bg-ios-blue text-white"
          title="Replay Onboarding Flow"
          subtitle="Review Observe, Understand, Act tour"
          onClick={() => {
            sounds.playPop();
            onOpenOnboarding();
          }}
          showSeparator={false}
        />
      </IosInsetGroup>

      {/* Sign Out */}
      <IosInsetGroup header="Account">
        <IosCell
          icon={LogOut}
          iconColor="bg-ios-red text-white"
          title={<span className="text-ios-red dark:text-ios-red-dark font-bold">Sign Out</span>}
          chevron={false}
          onClick={() => {
            sounds.playPop();
            setShowSignOutActionSheet(true);
          }}
          showSeparator={false}
        />
      </IosInsetGroup>

      {/* Build Info Footnote */}
      <div className="text-center text-[12px] text-[#8E8E93] dark:text-[#9BA1B0] pt-2 pb-6 space-y-0.5">
        <div className="font-semibold">Leukquant iOS 26 Showcase • Build 26.4.2</div>
        <div>Apple VisionOS Liquid Glass & HIG Compliant</div>
      </div>

      {/* Native Sign Out Action Sheet */}
      <IosActionSheet
        isOpen={showSignOutActionSheet}
        onClose={() => setShowSignOutActionSheet(false)}
        title="Sign Out of Leukquant"
        message="You will need to authenticate again with Face ID or your security token to view live telemetry."
        actions={[
          {
            label: "Sign Out",
            destructive: true,
            onClick: () => {
              sounds.playChime();
              setSignedOutNotice(true);
              setTimeout(() => setSignedOutNotice(false), 3000);
            }
          }
        ]}
      />

      {/* Toast Notice */}
      {signedOutNotice && (
        <div className="fixed top-16 left-1/2 -translate-x-1/2 z-50 px-4 py-2.5 rounded-full ios26-glass-thick text-white dark:text-black text-[13px] font-bold shadow-2xl flex items-center gap-2 animate-in fade-in slide-in-from-top-2 border border-white/25">
          <Check size={16} className="text-ios-green" />
          <span>Analyst Session Signed Out</span>
        </div>
      )}
    </div>
  );
}
