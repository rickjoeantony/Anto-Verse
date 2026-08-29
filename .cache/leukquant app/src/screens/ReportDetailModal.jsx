// src/screens/ReportDetailModal.jsx
import React, { useState } from 'react';
import IosSheetModal from '../components/ios/IosSheetModal';
import { IosInsetGroup, IosCell } from '../components/ios/IosInsetGroup';
import { FileText, Download, Check, Shield, Calendar } from 'lucide-react';
import sounds from '../utils/soundEffects';

export default function ReportDetailModal({
  report,
  isOpen,
  onClose
}) {
  const [downloading, setDownloading] = useState(false);
  const [downloaded, setDownloaded] = useState(false);

  if (!report) return null;

  const handleDownload = () => {
    sounds.playPop();
    setDownloading(true);
    setTimeout(() => {
      sounds.playChime();
      setDownloading(false);
      setDownloaded(true);
      setTimeout(() => setDownloaded(false), 3000);
    }, 1200);
  };

  return (
    <IosSheetModal
      isOpen={isOpen}
      onClose={onClose}
      title={report.title}
      subtitle={report.coveragePeriod}
      rightButtonText="Done"
    >
      {/* Report Document Header Card (Liquid Glass) */}
      <div className="p-4 rounded-[24px] ios26-glass-card shadow-lg space-y-3 border border-white/25">
        <div className="flex items-center space-x-3.5">
          <div className="w-12 h-14 rounded-[14px] bg-ios-red/20 text-ios-red flex flex-col items-center justify-center font-bold text-[12px] border border-ios-red/30 shadow-md">
            <FileText size={22} strokeWidth={2.2} />
            <span className="text-[10px] font-mono mt-0.5">PDF</span>
          </div>
          <div>
            <h3 className="text-[18px] font-extrabold text-black dark:text-white tracking-tight leading-snug">
              {report.title}
            </h3>
            <div className="flex items-center gap-2 text-[12px] text-[#8E8E93] dark:text-[#9BA1B0] mt-0.5">
              <span>{report.periodicity}</span>
              <span>•</span>
              <span>{report.fileSize}</span>
              <span>•</span>
              <span className="text-ios-green font-bold">Ready</span>
            </div>
          </div>
        </div>

        <p className="text-[13px] text-[#6C6C70] dark:text-[#9BA1B0] leading-relaxed font-medium">
          {report.description}
        </p>
      </div>

      {/* Highlights Grid Inset Group */}
      {report.highlights && (
        <IosInsetGroup header="Audit Summary & Highlights">
          <div className="grid grid-cols-2 divide-x divide-y divide-black/[0.06] dark:divide-white/[0.08]">
            {Object.entries(report.highlights).map(([key, val], idx) => {
              const formattedKey = key.replace(/([A-Z])/g, ' $1').toLowerCase();
              return (
                <div key={idx} className="p-3.5 space-y-0.5">
                  <div className="text-[11px] text-[#8E8E93] dark:text-[#9BA1B0] capitalize font-medium">
                    {formattedKey}
                  </div>
                  <div className="text-[15px] font-bold text-black dark:text-white">
                    {val}
                  </div>
                </div>
              );
            })}
          </div>
        </IosInsetGroup>
      )}

      {/* Metadata Inset Group */}
      <IosInsetGroup header="Verification & Integrity">
        <IosCell
          icon={Calendar}
          iconColor="bg-ios-blue text-white"
          title="Coverage Window"
          value={report.coveragePeriod}
          showSeparator={true}
        />
        <IosCell
          icon={Shield}
          iconColor="bg-ios-green text-white"
          title="Cryptographic Signature"
          value="SHA-256 Verified"
          showSeparator={false}
        />
      </IosInsetGroup>

      {/* Download / Export Action */}
      <div className="pt-2 space-y-2">
        <button
          type="button"
          onClick={handleDownload}
          disabled={downloading}
          className={`w-full py-3.5 px-4 rounded-[16px] text-[16px] font-bold transition-all ios-press-spring shadow-lg flex items-center justify-center gap-2 ${
            downloaded
              ? 'bg-ios-green text-white'
              : 'bg-gradient-to-r from-ios-blue to-indigo-600 text-white hover:brightness-110'
          }`}
        >
          {downloading ? (
            <div className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin" />
          ) : downloaded ? (
            <>
              <Check size={18} strokeWidth={2.8} />
              <span>Downloaded to iOS Files</span>
            </>
          ) : (
            <>
              <Download size={18} strokeWidth={2.2} />
              <span>Export {report.format} Report</span>
            </>
          )}
        </button>
      </div>
    </IosSheetModal>
  );
}
