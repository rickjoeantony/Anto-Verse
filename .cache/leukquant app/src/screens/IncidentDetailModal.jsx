// src/screens/IncidentDetailModal.jsx
import React, { useState } from 'react';
import IosSheetModal from '../components/ios/IosSheetModal';
import { IosInsetGroup, IosCell } from '../components/ios/IosInsetGroup';
import { IosSeverityBadge } from '../components/ios/IosBadge';
import {
  CheckCircle2,
  Circle,
  User,
  Shield,
  Check
} from 'lucide-react';
import sounds from '../utils/soundEffects';

export default function IncidentDetailModal({
  incident,
  isOpen,
  onClose,
  onResolveIncident
}) {
  const [isResolved, setIsResolved] = useState(false);

  if (!incident) return null;

  const currentResolvedState = isResolved || incident.status.toLowerCase() === 'resolved';

  const handleResolveClick = () => {
    sounds.playChime();
    setIsResolved(true);
    if (onResolveIncident) {
      onResolveIncident(incident.id);
    }
  };

  return (
    <IosSheetModal
      isOpen={isOpen}
      onClose={onClose}
      title={incident.id}
      subtitle="Incident Audit Trail"
      rightButtonText="Done"
    >
      {/* Header Banner (Liquid Glass) */}
      <div className="p-4 rounded-[24px] ios26-glass-card shadow-lg space-y-2 border border-white/25">
        <div className="flex items-center justify-between">
          <IosSeverityBadge severity={incident.severity} size="lg" />
          <IosSeverityBadge severity={currentResolvedState ? 'resolved' : incident.status} />
        </div>
        <h3 className="text-[20px] font-extrabold text-black dark:text-white tracking-tight leading-snug">
          {incident.title}
        </h3>
        <p className="text-[14px] text-[#6C6C70] dark:text-[#9BA1B0] leading-relaxed">
          {incident.description}
        </p>
      </div>

      {/* Interactive Audit Timeline Stepper */}
      <IosInsetGroup header="Audit Timeline & Containment Stepper">
        <div className="p-4 space-y-5">
          {incident.timeline?.map((step, idx) => {
            const isCompleted = step.isCompleted || (currentResolvedState && idx === incident.timeline.length - 1);
            const isLast = idx === incident.timeline.length - 1;

            return (
              <div key={idx} className="relative flex items-start space-x-3.5">
                {/* Connecting Line */}
                {!isLast && (
                  <div
                    className={`absolute left-[13px] top-[26px] bottom-[-20px] w-[2px] ${
                      isCompleted ? 'bg-ios-blue' : 'bg-black/10 dark:bg-white/10'
                    }`}
                  />
                )}

                {/* Step Circle */}
                <div className="relative z-10 shrink-0 mt-0.5">
                  {isCompleted ? (
                    <div className="w-[26px] h-[26px] rounded-full bg-ios-blue text-white flex items-center justify-center shadow-md">
                      <Check size={16} strokeWidth={3} />
                    </div>
                  ) : (
                    <div className="w-[26px] h-[26px] rounded-full bg-black/10 dark:bg-white/10 flex items-center justify-center text-[#8E8E93]">
                      <Circle size={14} strokeWidth={2.5} />
                    </div>
                  )}
                </div>

                {/* Step Content */}
                <div className="flex-1 min-w-0">
                  <div className="flex items-center justify-between">
                    <h4
                      className={`text-[15px] font-bold tracking-tight ${
                        isCompleted ? 'text-black dark:text-white' : 'text-[#8E8E93]'
                      }`}
                    >
                      {step.stage}
                    </h4>
                    <span className="text-[11px] font-mono text-[#8E8E93] dark:text-[#9BA1B0]">
                      {step.timestamp}
                    </span>
                  </div>
                  <p className="text-[13px] text-[#6C6C70] dark:text-[#9BA1B0] mt-0.5 leading-relaxed font-medium">
                    {step.description}
                  </p>
                </div>
              </div>
            );
          })}
        </div>
      </IosInsetGroup>

      {/* Scope & Assignee */}
      <IosInsetGroup header="Incident Metadata">
        <IosCell
          icon={Shield}
          iconColor="bg-ios-indigo text-white"
          title="Containment Scope"
          value={incident.scope}
          showSeparator={true}
        />
        <IosCell
          icon={User}
          iconColor="bg-ios-blue text-white"
          title="Assigned Analyst"
          value={incident.assignee}
          showSeparator={false}
        />
      </IosInsetGroup>

      {/* Recommended Action & Resolution Button */}
      <IosInsetGroup header="Containment & Resolution">
        <div className="p-4 space-y-3">
          <p className="text-[14px] text-black dark:text-white leading-relaxed font-medium">
            {incident.recommendedAction}
          </p>

          <button
            type="button"
            onClick={handleResolveClick}
            disabled={currentResolvedState}
            className={`w-full py-3 px-4 rounded-[14px] text-[15px] font-bold transition-all ios-press-spring shadow-md ${
              currentResolvedState
                ? 'bg-ios-green/20 text-ios-green border border-ios-green/40 cursor-default flex items-center justify-center gap-1.5'
                : 'bg-ios-green text-white hover:bg-emerald-600'
            }`}
          >
            {currentResolvedState ? (
              <>
                <CheckCircle2 size={18} />
                <span>Incident Contained & Resolved</span>
              </>
            ) : (
              'Mark as Contained & Resolved'
            )}
          </button>
        </div>
      </IosInsetGroup>
    </IosSheetModal>
  );
}
