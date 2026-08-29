// src/screens/IncidentsScreen.jsx
import React, { useState } from 'react';
import IosNavigationBar from '../components/ios/IosNavigationBar';
import IosSegmentedControl from '../components/ios/IosSegmentedControl';
import { IosInsetGroup, IosCell } from '../components/ios/IosInsetGroup';
import { IosSeverityBadge } from '../components/ios/IosBadge';
import { Plus, CheckCircle } from 'lucide-react';
import sounds from '../utils/soundEffects';

export default function IncidentsScreen({
  incidents = [],
  onSelectIncident,
  onNewIncident,
  isDark,
  onToggleTheme,
  onOpenSettings
}) {
  const [tabFilter, setTabFilter] = useState('active');

  const activeIncidents = incidents.filter(
    (inc) => inc.status.toLowerCase() !== 'resolved'
  );
  const resolvedIncidents = incidents.filter(
    (inc) => inc.status.toLowerCase() === 'resolved'
  );

  const currentList = tabFilter === 'active' ? activeIncidents : resolvedIncidents;

  return (
    <div className="pb-12">
      <IosNavigationBar
        title="Incident Triage"
        subtitle="Verified Threat Containment"
        isDark={isDark}
        onToggleTheme={onToggleTheme}
        onOpenSettings={onOpenSettings}
        rightActions={
          <div className="flex items-center space-x-2">
            <button
              onClick={() => {
                sounds.playPop();
                onNewIncident();
              }}
              className="w-9 h-9 rounded-full bg-ios-blue text-white flex items-center justify-center ios-press-spring focus:outline-none shadow-md border border-white/25"
              title="New Triage Incident"
            >
              <Plus size={18} strokeWidth={2.6} />
            </button>
          </div>
        }
      />

      <div className="px-4 py-2.5">
        <IosSegmentedControl
          options={[
            { label: `Active (${activeIncidents.length})`, value: 'active' },
            { label: `Resolved (${resolvedIncidents.length})`, value: 'resolved' }
          ]}
          value={tabFilter}
          onChange={setTabFilter}
        />
      </div>

      {currentList.length > 0 ? (
        <IosInsetGroup
          header={tabFilter === 'active' ? "Active Incidents Under Triage" : "Resolved Incident History"}
          footer="Audit timestamps and SOC mitigation timelines are immutable for compliance."
        >
          {currentList.map((incident, idx) => (
            <IosCell
              key={incident.id}
              title={
                <div className="font-bold text-black dark:text-white leading-snug text-[15px]">
                  {incident.title}
                </div>
              }
              subtitle={
                <div className="mt-1 space-y-1">
                  <p className="text-[13px] text-[#6B7280] dark:text-[#9BA1B0] line-clamp-2 leading-relaxed font-normal">
                    {incident.description}
                  </p>
                  <div className="flex items-center gap-2 text-[12px] text-[#8E8E93] dark:text-[#8E95A5]">
                    <span className="font-mono text-ios-blue dark:text-sky-400 font-semibold">{incident.id}</span>
                    <span>•</span>
                    <span>{incident.scope}</span>
                    <span>•</span>
                    <span>{incident.createdAt}</span>
                  </div>
                </div>
              }
              rightElement={
                <div className="flex flex-col items-end gap-1.5 self-start pt-0.5">
                  <IosSeverityBadge severity={incident.severity} />
                  <IosSeverityBadge severity={incident.status} />
                </div>
              }
              onClick={() => onSelectIncident(incident)}
              showSeparator={idx < currentList.length - 1}
            />
          ))}
        </IosInsetGroup>
      ) : (
        <div className="mx-4 my-10 p-8 rounded-[28px] ios26-glass-card text-center space-y-3">
          <div className="w-14 h-14 rounded-full bg-ios-green/20 text-ios-green flex items-center justify-center mx-auto border border-ios-green/30 shadow-md">
            <CheckCircle size={28} strokeWidth={2.2} />
          </div>
          <h3 className="text-[18px] font-bold text-black dark:text-white">
            No Active Incidents
          </h3>
          <p className="text-[13px] text-[#8E8E93] max-w-[260px] mx-auto">
            All enterprise decoy ingress signals have been contained and resolved.
          </p>
        </div>
      )}
    </div>
  );
}
