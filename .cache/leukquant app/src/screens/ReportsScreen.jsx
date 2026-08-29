// src/screens/ReportsScreen.jsx
import React, { useState } from 'react';
import IosNavigationBar from '../components/ios/IosNavigationBar';
import { IosInsetGroup, IosCell } from '../components/ios/IosInsetGroup';
import { MOCK_REPORTS } from '../data/mockData';
import ReportDetailModal from './ReportDetailModal';
import { FileText, ShieldCheck, Award, CheckCircle2 } from 'lucide-react';
import sounds from '../utils/soundEffects';

export default function ReportsScreen({
  isDark,
  onToggleTheme,
  onOpenSettings
}) {
  const [selectedReport, setSelectedReport] = useState(null);

  return (
    <div className="pb-12">
      <IosNavigationBar
        title="Audit Reports"
        subtitle="Enterprise Telemetry Audits"
        isDark={isDark}
        onToggleTheme={onToggleTheme}
        onOpenSettings={onOpenSettings}
      />

      {/* Available Reports Inset Group */}
      <IosInsetGroup
        header="Security Briefs & Audit Logs"
        footer="All reports are cryptographically signed with SHA-256 for executive compliance."
      >
        {MOCK_REPORTS.map((report, idx) => (
          <IosCell
            key={report.id}
            icon={FileText}
            iconColor="bg-ios-blue text-white"
            title={report.title}
            subtitle={`${report.periodicity} • ${report.coveragePeriod}`}
            rightElement={
              <span className="px-2.5 py-0.5 rounded-full text-[11px] font-bold bg-ios-blue/20 text-ios-blue dark:text-sky-400 border border-ios-blue/30">
                {report.format}
              </span>
            }
            onClick={() => {
              sounds.playPop();
              setSelectedReport(report);
            }}
            showSeparator={idx < MOCK_REPORTS.length - 1}
          />
        ))}
      </IosInsetGroup>

      {/* Compliance Posture Inset Group */}
      <IosInsetGroup
        header="Compliance & Certifications"
        footer="Automated continuous control monitoring against enterprise security frameworks."
      >
        <IosCell
          icon={Award}
          iconColor="bg-ios-green text-white"
          title="SOC 2 Type II Posture"
          subtitle="Continuous Audit Controls"
          value="100% Compliant"
          chevron={false}
          showSeparator={true}
        />
        <IosCell
          icon={ShieldCheck}
          iconColor="bg-ios-indigo text-white"
          title="ISO/IEC 27001 Decoy Verification"
          subtitle="Verified Honeypot Partitioning"
          value="Audited"
          chevron={false}
          showSeparator={true}
        />
        <IosCell
          icon={CheckCircle2}
          iconColor="bg-ios-teal text-white"
          title="GDPR / Data Privacy Guard"
          subtitle="Strict Credential Masking Enabled"
          value="Protected"
          chevron={false}
          showSeparator={false}
        />
      </IosInsetGroup>

      {/* Report Details Modal */}
      <ReportDetailModal
        report={selectedReport}
        isOpen={Boolean(selectedReport)}
        onClose={() => setSelectedReport(null)}
      />
    </div>
  );
}
