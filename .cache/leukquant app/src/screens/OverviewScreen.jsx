// src/screens/OverviewScreen.jsx
import React, { useState } from 'react';
import { IosInsetGroup, IosCell } from '../components/ios/IosInsetGroup';
import IosSegmentedControl from '../components/ios/IosSegmentedControl';
import { IosActivityLineChart, IosDonutChart, IosProtocolBarChart } from '../components/ios/IosCharts';
import { IosSeverityBadge, IosProtocolBadge } from '../components/ios/IosBadge';
import {
  MOCK_SECURITY_METRICS,
  MOCK_24H_CHART_DATA,
  MOCK_THREAT_DISTRIBUTION,
  MOCK_PROTOCOL_BREAKDOWN,
  MOCK_SECURITY_EVENTS
} from '../data/mockData';
import {
  ShieldCheck,
  Zap,
  AlertOctagon,
  ArrowUpRight,
  CheckCircle2,
  Bell,
  SlidersHorizontal,
  Sun,
  Moon,
  Star
} from 'lucide-react';
import sounds from '../utils/soundEffects';

export default function OverviewScreen({
  onSelectEvent,
  onNavigateTab,
  onOpenSettings,
  isDark,
  onToggleTheme
}) {
  const [timeRange, setTimeRange] = useState('24h');
  const [acknowledgedAction, setAcknowledgedAction] = useState(false);
  const [selectedCategory, setSelectedCategory] = useState('All');

  const categories = [
    {
      id: 'All',
      label: 'All',
      image: 'https://images.unsplash.com/photo-1558494949-ef010cbdcc31?w=300&auto=format&fit=crop&q=80',
    },
    {
      id: 'Decoys',
      label: 'Decoys',
      image: 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=300&auto=format&fit=crop&q=80',
    },
    {
      id: 'Canaries',
      label: 'Canaries',
      image: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=300&auto=format&fit=crop&q=80',
    },
    {
      id: 'Fleet',
      label: 'Fleet',
      image: 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=300&auto=format&fit=crop&q=80',
    },
  ];

  return (
    <div className={`min-h-full pb-20 ${isDark ? 'bg-[#0D1117] text-white' : 'bg-[#EBE7DE] text-[#1C1917]'}`}>
      {/* 1. TOP HEADER: Profile Avatar & Notification Bell */}
      <div className="px-5 pt-3 pb-2 flex items-center justify-between">
        <button
          onClick={() => {
            sounds.playTap();
            onOpenSettings && onOpenSettings();
          }}
          className="w-12 h-12 rounded-full overflow-hidden border-2 border-white dark:border-white/20 shadow-md transition-transform hover:scale-105 active:scale-95"
        >
          <img
            src="https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&auto=format&fit=crop&q=80"
            alt="User profile"
            className="w-full h-full object-cover"
          />
        </button>

        <div className="flex items-center space-x-2">
          {/* Theme Toggle */}
          <button
            onClick={() => {
              sounds.playTap();
              onToggleTheme && onToggleTheme();
            }}
            className="w-11 h-11 rounded-full bg-white dark:bg-slate-800 text-slate-700 dark:text-amber-400 flex items-center justify-center shadow-md border border-black/5 dark:border-white/10 transition-transform active:scale-90"
            title="Toggle theme"
          >
            {isDark ? <Sun size={19} /> : <Moon size={19} />}
          </button>

          {/* Notification Bell */}
          <button
            onClick={() => {
              sounds.playTap();
              onNavigateTab('incidents');
            }}
            className="w-11 h-11 rounded-full bg-white dark:bg-slate-800 text-slate-800 dark:text-white flex items-center justify-center shadow-md border border-black/5 dark:border-white/10 relative transition-transform active:scale-90"
            title="Notifications"
          >
            <Bell size={20} />
            <span className="absolute top-2.5 right-2.5 w-2 h-2 rounded-full bg-red-500 ring-2 ring-white dark:ring-slate-800" />
          </button>
        </div>
      </div>

      {/* 2. GREETING SECTION */}
      <div className="px-5 pt-2 pb-3">
        <p className="text-[14px] font-medium text-[#78716C] dark:text-[#94A3B8]">
          Security User
        </p>
        <div className="flex items-center gap-2 mt-0.5">
          <h1 className="text-[32px] font-extrabold tracking-tight text-[#1C1917] dark:text-white">
            Hello!
          </h1>
          <span className="text-[26px]">👋</span>
        </div>
        <p className="text-[26px] font-light text-[#292524] dark:text-[#CBD5E1] -mt-1 tracking-tight">
          Good to see you
        </p>
      </div>

      {/* 3. VERIFIED METRICS & 24-HOUR TELEMETRY CHART */}
      <div className="mx-5 my-4 p-4 rounded-[24px] bg-white/90 dark:bg-slate-800/80 shadow-md border border-white dark:border-white/10">
        <div className="flex items-center justify-between mb-2.5">
          <div>
            <h3 className="text-[16px] font-bold text-black dark:text-white tracking-tight">
              Verified Ingress Telemetry
            </h3>
            <p className="text-[11px] text-[#8E8E93] dark:text-[#9BA1B0]">Ghost-Net sensor detection timeline</p>
          </div>
        </div>

        <IosSegmentedControl
          options={[
            { label: '24 Hours', value: '24h' },
            { label: '7 Days', value: '7d' },
            { label: '30 Days', value: '30d' }
          ]}
          value={timeRange}
          onChange={setTimeRange}
          className="mb-3"
        />

        <IosActivityLineChart data={MOCK_24H_CHART_DATA} strokeColor="#007AFF" />
      </div>

      {/* 7. THREAT DISTRIBUTION & PROTOCOLS */}
      <IosInsetGroup header="Threat Distribution & Vectors">
        <div className="p-4">
          <IosDonutChart data={MOCK_THREAT_DISTRIBUTION} />
        </div>
      </IosInsetGroup>

      <IosInsetGroup header="Targeted Decoy Protocols">
        <div className="p-4">
          <IosProtocolBarChart data={MOCK_PROTOCOL_BREAKDOWN} />
        </div>
      </IosInsetGroup>

      {/* 8. RECOMMENDED ACTION CARD */}
      <IosInsetGroup header="Recommended Action">
        <div className="p-4">
          <div className="flex items-start space-x-3">
            <div className="w-10 h-10 rounded-2xl bg-blue-500/20 text-blue-500 flex items-center justify-center shrink-0 mt-0.5 border border-blue-500/30 shadow-sm">
              <ShieldCheck size={22} strokeWidth={2.2} />
            </div>
            <div className="flex-1 min-w-0">
              <h4 className="text-[15px] font-bold text-black dark:text-white leading-snug">
                Rotate STS Canary Honeytoken
              </h4>
              <p className="text-[13px] text-[#6B7280] dark:text-[#9BA1B0] mt-1 leading-relaxed">
                Interaction on <code className="text-[11px] font-mono text-blue-500 bg-black/5 dark:bg-white/10 px-1 py-0.5 rounded">canary-aws-prod-decoy-04</code> suggests credential probe from unverified ASN.
              </p>

              <div className="mt-3 flex items-center gap-2">
                <button
                  type="button"
                  onClick={() => {
                    sounds.playPop();
                    setAcknowledgedAction(!acknowledgedAction);
                  }}
                  className={`px-3.5 py-1.5 rounded-[12px] text-[13px] font-semibold ios-press-spring transition-all ${
                    acknowledgedAction
                      ? 'bg-emerald-500/25 text-emerald-500 flex items-center gap-1.5 border border-emerald-500/40'
                      : 'bg-blue-600 text-white shadow-md'
                  }`}
                >
                  {acknowledgedAction ? (
                    <>
                      <CheckCircle2 size={14} />
                      <span>Action Queued</span>
                    </>
                  ) : (
                    'Initiate Auto-Rotation'
                  )}
                </button>

                <button
                  type="button"
                  onClick={() => {
                    sounds.playTap();
                    onNavigateTab('incidents');
                  }}
                  className="px-3.5 py-1.5 rounded-[12px] text-[13px] font-medium bg-black/5 dark:bg-white/10 text-black dark:text-white ios-press-spring border border-black/5 dark:border-white/10"
                >
                  View Incident
                </button>
              </div>
            </div>
          </div>
        </div>
      </IosInsetGroup>

      {/* 9. RECENT TELEMETRY INGRESS */}
      <IosInsetGroup
        header="Recent Telemetry Ingress"
        footer="Tap on any event to inspect raw payload, target decoy, and masked credentials."
      >
        {MOCK_SECURITY_EVENTS.slice(0, 4).map((evt, idx) => (
          <IosCell
            key={evt.id}
            title={evt.classification}
            subtitle={`${evt.sourceIp} • ${evt.timestamp}`}
            rightElement={
              <div className="flex items-center gap-1.5">
                <IosProtocolBadge protocol={evt.protocol} />
                <IosSeverityBadge severity={evt.severity} />
              </div>
            }
            onClick={() => onSelectEvent(evt)}
            showSeparator={idx < 3}
          />
        ))}
      </IosInsetGroup>
    </div>
  );
}
