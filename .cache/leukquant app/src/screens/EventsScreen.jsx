// src/screens/EventsScreen.jsx
import React, { useState } from 'react';
import IosNavigationBar from '../components/ios/IosNavigationBar';
import IosSearchBar from '../components/ios/IosSearchBar';
import { IosInsetGroup, IosCell } from '../components/ios/IosInsetGroup';
import { IosSeverityBadge, IosProtocolBadge } from '../components/ios/IosBadge';
import { Radio, SearchX } from 'lucide-react';
import sounds from '../utils/soundEffects';

export default function EventsScreen({
  events = [],
  onSelectEvent,
  isDark,
  onToggleTheme,
  onOpenSettings
}) {
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedSeverity, setSelectedSeverity] = useState('all');
  const [selectedProtocol, setSelectedProtocol] = useState('all');

  const severityFilters = [
    { label: 'All', value: 'all' },
    { label: 'Critical', value: 'critical' },
    { label: 'High', value: 'high' },
    { label: 'Warning', value: 'warning' },
    { label: 'Info', value: 'info' }
  ];

  const protocolFilters = [
    { label: 'All Protocols', value: 'all' },
    { label: 'HTTPS', value: 'HTTPS' },
    { label: 'SSH', value: 'SSH' },
    { label: 'POSTGRES', value: 'POSTGRES' },
    { label: 'TCP', value: 'TCP' }
  ];

  const filteredEvents = events.filter((evt) => {
    const matchesSearch =
      searchQuery === '' ||
      evt.id.toLowerCase().includes(searchQuery.toLowerCase()) ||
      evt.classification.toLowerCase().includes(searchQuery.toLowerCase()) ||
      evt.sourceIp.includes(searchQuery) ||
      evt.canaryReference.toLowerCase().includes(searchQuery.toLowerCase()) ||
      evt.protocol.toLowerCase().includes(searchQuery.toLowerCase());

    const matchesSeverity =
      selectedSeverity === 'all' || evt.severity.toLowerCase() === selectedSeverity.toLowerCase();

    const matchesProtocol =
      selectedProtocol === 'all' || evt.protocol.toUpperCase() === selectedProtocol.toUpperCase();

    return matchesSearch && matchesSeverity && matchesProtocol;
  });

  return (
    <div className="pb-12">
      <IosNavigationBar
        title="Events Stream"
        subtitle="Live Ghost-Net Ingress Telemetry"
        isDark={isDark}
        onToggleTheme={onToggleTheme}
        onOpenSettings={onOpenSettings}
        rightActions={
          <div className="flex items-center space-x-2">
            <div className="flex items-center gap-1.5 text-[11px] font-bold text-ios-green bg-ios-green/15 border border-ios-green/30 px-3 py-1 rounded-full backdrop-blur-md shadow-sm">
              <span className="w-2 h-2 rounded-full bg-ios-green animate-ping" />
              <span>LIVE</span>
            </div>
          </div>
        }
      />

      <IosSearchBar
        value={searchQuery}
        onChange={setSearchQuery}
        placeholder="Search by ID, IP, Decoy, or Protocol"
      />

      {/* Filter Chips - Severity */}
      <div className="px-4 py-1 flex items-center space-x-2 overflow-x-auto no-scrollbar">
        {severityFilters.map((f) => {
          const isSelected = selectedSeverity === f.value;
          return (
            <button
              key={f.value}
              onClick={() => {
                sounds.playTap();
                setSelectedSeverity(f.value);
              }}
              className={`px-3 py-1 rounded-[12px] text-[13px] font-semibold whitespace-nowrap transition-all ios-press-spring shrink-0 ${
                isSelected
                  ? 'bg-ios-blue text-white shadow-md border border-ios-blue'
                  : 'ios26-glass text-black dark:text-white'
              }`}
            >
              {f.label}
            </button>
          );
        })}
      </div>

      {/* Filter Chips - Protocol */}
      <div className="px-4 pt-1.5 pb-2 flex items-center space-x-2 overflow-x-auto no-scrollbar">
        {protocolFilters.map((f) => {
          const isSelected = selectedProtocol === f.value;
          return (
            <button
              key={f.value}
              onClick={() => {
                sounds.playTap();
                setSelectedProtocol(f.value);
              }}
              className={`px-2.5 py-0.5 rounded-[10px] text-[11px] font-mono transition-all ios-press-spring shrink-0 ${
                isSelected
                  ? 'bg-black text-white dark:bg-white dark:text-black font-bold shadow-md'
                  : 'bg-black/5 dark:bg-white/5 text-[#8E8E93] border border-white/10'
              }`}
            >
              {f.label}
            </button>
          );
        })}
      </div>

      {/* Inset Grouped Events Stream */}
      {filteredEvents.length > 0 ? (
        <IosInsetGroup
          header={`Telemetry Ingress (${filteredEvents.length})`}
          footer="All honeypot secrets and credentials are fully masked by enterprise privacy design."
        >
          {filteredEvents.map((evt, idx) => (
            <IosCell
              key={evt.id}
              title={
                <div className="flex items-center gap-1.5">
                  <span className="text-[14px]">{evt.countryCode || '🌐'}</span>
                  <span className="font-semibold">{evt.classification}</span>
                </div>
              }
              subtitle={
                <div className="text-[12px] space-y-0.5 text-[#8E8E93] dark:text-[#9BA1B0]">
                  <div>
                    <span className="font-mono text-black dark:text-white font-medium">{evt.sourceIp}</span>
                    <span> : {evt.destinationPort}</span>
                    <span> • {evt.timestamp}</span>
                  </div>
                  <div className="truncate text-[11px] text-[#6B7280] dark:text-[#AEB4C2]">
                    Canary: {evt.canaryReference}
                  </div>
                </div>
              }
              rightElement={
                <div className="flex flex-col items-end gap-1">
                  <IosSeverityBadge severity={evt.severity} />
                  <IosProtocolBadge protocol={evt.protocol} />
                </div>
              }
              onClick={() => onSelectEvent(evt)}
              showSeparator={idx < filteredEvents.length - 1}
            />
          ))}
        </IosInsetGroup>
      ) : (
        /* Empty State */
        <div className="mx-4 my-8 p-8 rounded-[28px] ios26-glass-card text-center space-y-3">
          <div className="w-14 h-14 rounded-full bg-black/5 dark:bg-white/10 flex items-center justify-center mx-auto text-[#8E8E93]">
            <SearchX size={26} />
          </div>
          <h3 className="text-[18px] font-bold text-black dark:text-white">
            No Matching Telemetry Events
          </h3>
          <p className="text-[13px] text-[#8E8E93] max-w-[240px] mx-auto">
            Try adjusting your search query or clear severity & protocol filters.
          </p>
          <button
            onClick={() => {
              sounds.playPop();
              setSearchQuery('');
              setSelectedSeverity('all');
              setSelectedProtocol('all');
            }}
            className="px-4 py-2 rounded-xl bg-ios-blue text-white text-[13px] font-semibold ios-press-spring shadow-md"
          >
            Reset Filters
          </button>
        </div>
      )}
    </div>
  );
}
