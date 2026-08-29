// src/App.jsx
import React, { useState, useEffect } from 'react';
import IosDeviceFrame from './components/ios/IosDeviceFrame';
import IosTabBar from './components/ios/IosTabBar';
import OverviewScreen from './screens/OverviewScreen';
import EventsScreen from './screens/EventsScreen';
import EventDetailModal from './screens/EventDetailModal';
import IncidentsScreen from './screens/IncidentsScreen';
import IncidentDetailModal from './screens/IncidentDetailModal';
import ReportsScreen from './screens/ReportsScreen';
import SettingsScreen from './screens/SettingsScreen';
import OnboardingModal from './screens/OnboardingModal';
import IOS26ShowcaseScreen from './screens/iOS26ShowcaseScreen';
import MusicAppScreen from './screens/MusicAppScreen';
import MessagesAppScreen from './screens/MessagesAppScreen';
import MapsAppScreen from './screens/MapsAppScreen';

import {
  MOCK_SECURITY_EVENTS,
  MOCK_INCIDENTS
} from './data/mockData';
import { CheckCircle2, AlertTriangle, ShieldCheck, Music, Sparkles, Play, Pause } from 'lucide-react';
import sounds from './utils/soundEffects';

export default function App() {
  // Navigation & Ecosystem States
  const [activeMode, setActiveMode] = useState('apps'); // 'showcase' or 'apps'
  const [activeApp, setActiveApp] = useState('leukquant'); // 'leukquant', 'music', 'messages', 'maps', 'settings'
  const [activeTab, setActiveTab] = useState('overview');
  const [themeMode, setThemeMode] = useState('dark');
  const [currentWallpaper, setCurrentWallpaper] = useState('dark-aurora');
  const [soundEnabled, setSoundEnabled] = useState(true);
  const [dynamicLightingEnabled, setDynamicLightingEnabled] = useState(true);

  // Data & Modal States
  const [events, setEvents] = useState(MOCK_SECURITY_EVENTS);
  const [incidents, setIncidents] = useState(MOCK_INCIDENTS);
  const [selectedEvent, setSelectedEvent] = useState(null);
  const [selectedIncident, setSelectedIncident] = useState(null);
  const [isOnboardingOpen, setIsOnboardingOpen] = useState(false);
  const [toastMessage, setToastMessage] = useState(null);
  const [miniMusicPlaying, setMiniMusicPlaying] = useState(true);

  const isDark =
    themeMode === 'dark' ||
    (themeMode === 'system' && window.matchMedia('(prefers-color-scheme: dark)').matches);

  // Apply Dark Mode class to root HTML
  useEffect(() => {
    if (isDark) {
      document.documentElement.classList.add('dark');
    } else {
      document.documentElement.classList.remove('dark');
    }
  }, [isDark]);

  const handleToggleTheme = () => {
    setThemeMode(isDark ? 'light' : 'dark');
  };

  const handleToggleSound = () => {
    const nextState = sounds.toggleSound();
    setSoundEnabled(nextState);
  };

  const showToast = (message, icon = CheckCircle2) => {
    sounds.playChime();
    setToastMessage({ message, icon });
    setTimeout(() => setToastMessage(null), 3400);
  };

  // Simulate incoming live telemetry ingress event
  const handleSimulateEvent = () => {
    sounds.playPop();
    const randomIps = ["194.26.29.11", "45.142.122.98", "185.191.171.4", "94.102.61.18", "198.51.100.42"];
    const randomProtocols = ["HTTPS", "SSH", "POSTGRES", "TCP", "DNS"];
    const randomSeverities = ["critical", "high", "warning", "info"];
    const randomClassifications = [
      "Canary Access Token Intercept",
      "Synthetic Redis Port Probe",
      "Automated Directory Scanner",
      "Decoy API Key Exposure",
      "Spatial Neural Node Ingress"
    ];

    const randomIdx = Math.floor(Math.random() * randomClassifications.length);
    const newEvent = {
      id: `EVT-${Math.floor(1000 + Math.random() * 9000)}-LK`,
      classification: randomClassifications[randomIdx],
      classificationReasons: [
        "Automated ingress heuristic match against Ghost-Net decoy sensor.",
        "Payload signature matched known scanning tool with 99.4% confidence."
      ],
      severity: randomSeverities[randomIdx],
      protocol: randomProtocols[randomIdx],
      destinationPort: randomProtocols[randomIdx] === "SSH" ? "22" : "443",
      sourceIp: randomIps[randomIdx],
      country: "Simulated Telemetry Source",
      countryCode: "⚡",
      canaryReference: `canary-edge-node-0${Math.floor(1 + Math.random() * 8)}`,
      recommendedAction: "Verify firewall perimeter drop rule.",
      maskedCredentials: "admin / **********",
      timestamp: "Just now",
      rawPayload: {
        event_source: "Ghost-Net Decoy Node",
        simulated: true,
        protocol: randomProtocols[randomIdx],
        packet_timestamp: new Date().toISOString()
      }
    };

    setEvents((prev) => [newEvent, ...prev]);
    showToast(`New Ingress: ${newEvent.classification}`, AlertTriangle);
  };

  // Resolve incident handler
  const handleResolveIncident = (incidentId) => {
    sounds.playChime();
    setIncidents((prev) =>
      prev.map((inc) =>
        inc.id === incidentId
          ? {
              ...inc,
              status: 'Resolved',
              timeline: inc.timeline.map((t) => ({ ...t, isCompleted: true }))
            }
          : inc
      )
    );
    showToast(`Incident ${incidentId} Contained & Resolved`, ShieldCheck);
  };

  // Escalate event to new incident
  const handleEscalateEvent = (event) => {
    sounds.playPop();
    const newInc = {
      id: `INC-2026-${Math.floor(1000 + Math.random() * 9000)}`,
      title: `Escalated Incident: ${event.classification}`,
      description: `Verified telemetry signal from ${event.sourceIp} escalated to active SOC review.`,
      severity: event.severity,
      status: "Investigating",
      assignee: "Dr. Rick J. Antony",
      scope: `Decoy (${event.canaryReference})`,
      recommendedAction: event.recommendedAction,
      createdAt: "Just now",
      timeline: [
        {
          stage: "Detection",
          description: `Ingress signal ${event.id} flagged by Ghost-Net sensor.`,
          timestamp: "Just now",
          isCompleted: true
        },
        {
          stage: "Correlation",
          description: `Correlated with honeypot ${event.canaryReference} on port ${event.destinationPort}.`,
          timestamp: "Just now",
          isCompleted: true
        },
        {
          stage: "Triage & Containment",
          description: "Perimeter quarantine rule queued.",
          timestamp: "In Progress",
          isCompleted: false
        },
        {
          stage: "Resolution",
          description: "Pending analyst sign-off.",
          timestamp: "Pending",
          isCompleted: false
        }
      ]
    };

    setIncidents((prev) => [newInc, ...prev]);
    setActiveMode('apps');
    setActiveApp('leukquant');
    setActiveTab('incidents');
    setSelectedIncident(newInc);
    showToast(`Event escalated to Incident ${newInc.id}`, ShieldCheck);
  };

  // Create new incident manually
  const handleNewIncident = () => {
    sounds.playPop();
    const customInc = {
      id: `INC-2026-${Math.floor(1000 + Math.random() * 9000)}`,
      title: "Manual Threat Quarantine & Triage",
      description: "Analyst initiated containment investigation on suspicious subnet egress pattern.",
      severity: "high",
      status: "Investigating",
      assignee: "Dr. Rick J. Antony",
      scope: "Enterprise Perimeter Cluster",
      recommendedAction: "Isolate affected subnet and inspect canary logs.",
      createdAt: "Just now",
      timeline: [
        {
          stage: "Detection",
          description: "Manual threat triage opened by Tier 3 Analyst.",
          timestamp: "Just now",
          isCompleted: true
        },
        {
          stage: "Correlation",
          description: "Ingress telemetry cross-referenced across decoy nodes.",
          timestamp: "Just now",
          isCompleted: true
        },
        {
          stage: "Triage & Containment",
          description: "Applying firewall null-route drop rules.",
          timestamp: "Active",
          isCompleted: false
        },
        {
          stage: "Resolution",
          description: "Awaiting verification.",
          timestamp: "Pending",
          isCompleted: false
        }
      ]
    };

    setIncidents((prev) => [customInc, ...prev]);
    setSelectedIncident(customInc);
    showToast("Created new incident for active triage", ShieldCheck);
  };

  return (
    <IosDeviceFrame
      isDark={isDark}
      onToggleTheme={handleToggleTheme}
      onOpenOnboarding={() => {
        sounds.playPop();
        setIsOnboardingOpen(true);
      }}
      activeMode={activeMode}
      onModeChange={setActiveMode}
      activeApp={activeApp}
      onAppChange={setActiveApp}
      currentWallpaper={currentWallpaper}
      onWallpaperChange={setCurrentWallpaper}
      soundEnabled={soundEnabled}
      onToggleSound={handleToggleSound}
      dynamicLightingEnabled={dynamicLightingEnabled}
      onToggleDynamicLighting={() => setDynamicLightingEnabled(!dynamicLightingEnabled)}
    >
      {/* Toast Notification Banner (iOS Dynamic Island Style) */}
      {toastMessage && (
        <div className="fixed top-14 left-1/2 -translate-x-1/2 z-50 px-4 py-2.5 rounded-full ios26-glass-thick text-black dark:text-white text-[13px] font-bold shadow-2xl flex items-center gap-2 animate-in fade-in slide-in-from-top-3 max-w-[360px] truncate pointer-events-none border border-white/30">
          <toastMessage.icon size={16} className="text-ios-blue shrink-0" />
          <span className="truncate">{toastMessage.message}</span>
        </div>
      )}

      {/* =========================================================================
          MODE 1: SWIFTUI IOS 26 FEATURE SHOWCASE & LAB
          ========================================================================= */}
      {activeMode === 'showcase' && (
        <IOS26ShowcaseScreen
          isDark={isDark}
          onToggleTheme={handleToggleTheme}
          onOpenSettings={() => {
            setActiveMode('apps');
            setActiveApp('settings');
          }}
        />
      )}

      {/* =========================================================================
          MODE 2: IOS 26 APP SUITE
          ========================================================================= */}
      {activeMode === 'apps' && (
        <>
          {/* APP 1: LEUKQUANT SOC & ACTIVE DEFENSE (WITH LUXURY UI) */}
          {activeApp === 'leukquant' && (
            <>
              {activeTab === 'overview' && (
                <OverviewScreen
                  onSelectEvent={setSelectedEvent}
                  onNavigateTab={setActiveTab}
                  onOpenSettings={() => setActiveTab('settings')}
                  isDark={isDark}
                  onToggleTheme={handleToggleTheme}
                />
              )}

              {activeTab === 'events' && (
                <EventsScreen
                  events={events}
                  onSelectEvent={setSelectedEvent}
                  isDark={isDark}
                  onToggleTheme={handleToggleTheme}
                  onOpenSettings={() => setActiveTab('settings')}
                />
              )}

              {activeTab === 'incidents' && (
                <IncidentsScreen
                  incidents={incidents}
                  onSelectIncident={setSelectedIncident}
                  onNewIncident={handleNewIncident}
                  isDark={isDark}
                  onToggleTheme={handleToggleTheme}
                  onOpenSettings={() => setActiveTab('settings')}
                />
              )}

              {activeTab === 'reports' && (
                <ReportsScreen
                  isDark={isDark}
                  onToggleTheme={handleToggleTheme}
                  onOpenSettings={() => setActiveTab('settings')}
                />
              )}

              {activeTab === 'settings' && (
                <SettingsScreen
                  themeMode={themeMode}
                  onThemeModeChange={setThemeMode}
                  onOpenOnboarding={() => setIsOnboardingOpen(true)}
                  isDark={isDark}
                  onToggleTheme={handleToggleTheme}
                  currentWallpaper={currentWallpaper}
                  onWallpaperChange={setCurrentWallpaper}
                  soundEnabled={soundEnabled}
                  onToggleSound={handleToggleSound}
                  dynamicLightingEnabled={dynamicLightingEnabled}
                  onToggleDynamicLighting={() => setDynamicLightingEnabled(!dynamicLightingEnabled)}
                />
              )}

              {/* Floating Liquid Glass Tab Bar */}
              <IosTabBar
                activeTab={activeTab}
                onTabChange={setActiveTab}
                unreadIncidentsCount={incidents.filter((i) => i.status.toLowerCase() !== 'resolved').length}
                unreadEventsCount={events.filter((e) => e.severity === 'critical').length}
                bottomAccessory={
                  <div
                    onClick={() => {
                      sounds.playTap();
                      setActiveApp('music');
                    }}
                    className="mx-1 px-3 py-1.5 rounded-[18px] ios26-glass shadow-md flex items-center justify-between cursor-pointer ios-press-spring border border-white/20"
                  >
                    <div className="flex items-center gap-2">
                      <div className="w-6 h-6 rounded-lg bg-gradient-to-tr from-pink-500 to-purple-600 flex items-center justify-center text-white text-[10px]">
                        <Music size={12} />
                      </div>
                      <div className="text-left text-[11px] leading-tight">
                        <span className="font-bold text-black dark:text-white truncate block max-w-[150px]">
                          Liquid Glass (Spatial)
                        </span>
                        <span className="text-[10px] text-pink-400 font-semibold">Apple Music 26</span>
                      </div>
                    </div>
                    <button
                      onClick={(e) => {
                        e.stopPropagation();
                        sounds.playTap();
                        setMiniMusicPlaying(!miniMusicPlaying);
                      }}
                      className="p-1 text-black dark:text-white hover:text-pink-400"
                    >
                      {miniMusicPlaying ? <Pause size={14} /> : <Play size={14} />}
                    </button>
                  </div>
                }
              />
            </>
          )}

          {/* APP 2: APPLE MUSIC 26 */}
          {activeApp === 'music' && (
            <MusicAppScreen
              isDark={isDark}
              onToggleTheme={handleToggleTheme}
              onOpenSettings={() => setActiveApp('settings')}
            />
          )}

          {/* APP 3: APPLE MESSAGES 26 */}
          {activeApp === 'messages' && (
            <MessagesAppScreen
              isDark={isDark}
              onToggleTheme={handleToggleTheme}
              onOpenSettings={() => setActiveApp('settings')}
            />
          )}

          {/* APP 4: APPLE MAPS 26 */}
          {activeApp === 'maps' && (
            <MapsAppScreen
              isDark={isDark}
              onToggleTheme={handleToggleTheme}
              onOpenSettings={() => setActiveApp('settings')}
            />
          )}

          {/* APP 5: SETTINGS 26 */}
          {activeApp === 'settings' && (
            <SettingsScreen
              themeMode={themeMode}
              onThemeModeChange={setThemeMode}
              onOpenOnboarding={() => setIsOnboardingOpen(true)}
              isDark={isDark}
              onToggleTheme={handleToggleTheme}
              currentWallpaper={currentWallpaper}
              onWallpaperChange={setCurrentWallpaper}
              soundEnabled={soundEnabled}
              onToggleSound={handleToggleSound}
              dynamicLightingEnabled={dynamicLightingEnabled}
              onToggleDynamicLighting={() => setDynamicLightingEnabled(!dynamicLightingEnabled)}
            />
          )}
        </>
      )}

      {/* Event Details Sheet Modal */}
      <EventDetailModal
        event={selectedEvent}
        isOpen={Boolean(selectedEvent)}
        onClose={() => setSelectedEvent(null)}
        onEscalate={handleEscalateEvent}
      />

      {/* Incident Details Sheet Modal */}
      <IncidentDetailModal
        incident={selectedIncident}
        isOpen={Boolean(selectedIncident)}
        onClose={() => setSelectedIncident(null)}
        onResolveIncident={handleResolveIncident}
      />

      {/* Onboarding Tour Modal */}
      <OnboardingModal
        isOpen={isOnboardingOpen}
        onClose={() => setIsOnboardingOpen(false)}
      />
    </IosDeviceFrame>
  );
}
