// src/screens/EventDetailModal.jsx
import React, { useState } from 'react';
import IosSheetModal from '../components/ios/IosSheetModal';
import { IosInsetGroup, IosCell } from '../components/ios/IosInsetGroup';
import { IosSeverityBadge, IosProtocolBadge } from '../components/ios/IosBadge';
import {
  Server,
  Globe,
  Lock,
  Terminal,
  Check,
  Copy,
  Send
} from 'lucide-react';
import sounds from '../utils/soundEffects';

export default function EventDetailModal({
  event,
  isOpen,
  onClose,
  onEscalate
}) {
  const [copied, setCopied] = useState(false);
  const [actionDone, setActionDone] = useState(false);

  if (!event) return null;

  const handleCopyJson = () => {
    sounds.playPop();
    navigator.clipboard?.writeText(JSON.stringify(event, null, 2));
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  return (
    <IosSheetModal
      isOpen={isOpen}
      onClose={onClose}
      title={event.id}
      subtitle="Verified Telemetry Signal"
      rightButtonText="Done"
    >
      {/* Event Header Banner (Liquid Glass) */}
      <div className="p-4 rounded-[24px] ios26-glass-card shadow-lg space-y-2 border border-white/25">
        <div className="flex items-center justify-between">
          <IosSeverityBadge severity={event.severity} size="lg" />
          <IosProtocolBadge protocol={event.protocol} />
        </div>
        <h3 className="text-[20px] font-extrabold text-black dark:text-white tracking-tight">
          {event.classification}
        </h3>
        <p className="text-[13px] text-[#8E8E93] dark:text-[#9BA1B0]">
          Ingress detected {event.timestamp} • Target Port {event.destinationPort}
        </p>
      </div>

      {/* Classification Reasons */}
      <IosInsetGroup header="Classification Reasons">
        {event.classificationReasons?.map((reason, idx) => (
          <div
            key={idx}
            className="px-4 py-3 text-[14px] text-black dark:text-white leading-snug border-b border-black/[0.06] dark:border-white/[0.08] last:border-b-0 flex items-start gap-2.5"
          >
            <span className="w-2 h-2 rounded-full bg-ios-blue shrink-0 mt-1.5 shadow-sm" />
            <span>{reason}</span>
          </div>
        ))}
      </IosInsetGroup>

      {/* Telemetry Network Parameters */}
      <IosInsetGroup header="Telemetry & Honeytoken Reference">
        <IosCell
          icon={Globe}
          iconColor="bg-ios-teal text-white"
          title="Attacker Source IP"
          value={event.sourceIp}
          subtitle={event.country}
          showSeparator={true}
        />
        <IosCell
          icon={Server}
          iconColor="bg-ios-indigo text-white"
          title="Canary Decoy Sensor"
          value={event.canaryReference}
          subtitle="Ghost-Net Edge Ingress Node"
          showSeparator={true}
        />
        <IosCell
          icon={Terminal}
          iconColor="bg-ios-purple text-white"
          title="Target Honeypot Port"
          value={event.destinationPort}
          subtitle={`Protocol: ${event.protocol}`}
          showSeparator={false}
        />
      </IosInsetGroup>

      {/* Strict Privacy Credential Masking */}
      <IosInsetGroup
        header="Credential Privacy Guard"
        footer="Leukquant strictly redacts sensitive honeytoken keys and passwords to prevent SOC credential leakage."
      >
        <IosCell
          icon={Lock}
          iconColor="bg-ios-green text-white"
          title="Extracted Credentials"
          value={
            <span className="font-mono text-[13px] text-ios-green font-bold">
              {event.maskedCredentials}
            </span>
          }
          subtitle="Redacted via Enterprise Policy"
          showSeparator={false}
        />
      </IosInsetGroup>

      {/* Recommended Remediation Action */}
      <IosInsetGroup header="Recommended Action">
        <div className="p-4 space-y-3">
          <p className="text-[14px] text-black dark:text-white leading-relaxed font-medium">
            {event.recommendedAction}
          </p>

          <div className="flex items-center gap-2 pt-1">
            <button
              type="button"
              onClick={() => {
                sounds.playPop();
                setActionDone(!actionDone);
              }}
              className={`flex-1 py-2.5 px-3 rounded-[14px] text-[14px] font-bold transition-all ios-press-spring ${
                actionDone
                  ? 'bg-ios-green text-white flex items-center justify-center gap-1.5 shadow-md'
                  : 'bg-ios-blue text-white shadow-md'
              }`}
            >
              {actionDone ? (
                <>
                  <Check size={16} />
                  <span>Rule Applied</span>
                </>
              ) : (
                'Apply Drop Rule'
              )}
            </button>

            <button
              type="button"
              onClick={() => {
                sounds.playTap();
                onEscalate?.(event);
                onClose();
              }}
              className="py-2.5 px-3.5 rounded-[14px] text-[14px] font-bold ios26-glass text-ios-blue dark:text-sky-400 ios-press-spring flex items-center gap-1.5"
            >
              <Send size={14} />
              <span>Escalate</span>
            </button>
          </div>
        </div>
      </IosInsetGroup>

      {/* Raw Payload Inspector */}
      {event.rawPayload && (
        <IosInsetGroup header="Raw Telemetry Payload">
          <div className="p-3 bg-black/10 dark:bg-black/40 font-mono text-[12px] text-black dark:text-[#AEAEB2] overflow-x-auto relative rounded-2xl">
            <button
              onClick={handleCopyJson}
              className="absolute top-2 right-2 p-1.5 rounded-[10px] ios26-glass text-black dark:text-white ios-press-spring flex items-center gap-1 text-[11px]"
            >
              {copied ? <Check size={12} className="text-ios-green" /> : <Copy size={12} />}
              <span>{copied ? 'Copied' : 'Copy'}</span>
            </button>
            <pre>{JSON.stringify(event.rawPayload, null, 2)}</pre>
          </div>
        </IosInsetGroup>
      )}
    </IosSheetModal>
  );
}
