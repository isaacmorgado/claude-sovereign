'use client';

import { useState, useCallback } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import {
  AlertTriangle,
  Shield,
  CheckCircle,
  X,
  ChevronRight,
  FileText,
  Stethoscope,
  Clock,
  DollarSign,
  Heart,
} from 'lucide-react';

// ============================================
// TYPES
// ============================================

export interface SurgeryConsentData {
  procedureId: string;
  procedureName: string;
  consentedAt: string;
  acknowledged: {
    risks: boolean;
    costs: boolean;
    recovery: boolean;
    consultation: boolean;
    informational: boolean;
  };
  signature?: string;
  age?: number;
}

interface SurgeryConsentModalProps {
  isOpen: boolean;
  onClose: () => void;
  onConsent: (data: SurgeryConsentData) => void;
  procedure: {
    id: string;
    name: string;
    description?: string;
    risks?: string;
    costMin?: number;
    costMax?: number;
    recoveryTime?: string;
  };
}

// ============================================
// STORAGE
// ============================================

const CONSENT_STORAGE_KEY = 'looksmaxx_surgery_consents';

export function getStoredConsents(): Record<string, SurgeryConsentData> {
  if (typeof window === 'undefined') return {};

  try {
    const stored = localStorage.getItem(CONSENT_STORAGE_KEY);
    if (stored) {
      return JSON.parse(stored);
    }
  } catch {
    console.error('[SurgeryConsent] Failed to load consents');
  }

  return {};
}

export function saveConsent(data: SurgeryConsentData): void {
  if (typeof window === 'undefined') return;

  try {
    const existing = getStoredConsents();
    existing[data.procedureId] = data;
    localStorage.setItem(CONSENT_STORAGE_KEY, JSON.stringify(existing));
  } catch (e) {
    console.error('[SurgeryConsent] Failed to save consent:', e);
  }
}

export function hasConsented(procedureId: string): boolean {
  const consents = getStoredConsents();
  return !!consents[procedureId];
}

export function revokeConsent(procedureId: string): void {
  if (typeof window === 'undefined') return;

  try {
    const existing = getStoredConsents();
    delete existing[procedureId];
    localStorage.setItem(CONSENT_STORAGE_KEY, JSON.stringify(existing));
  } catch (e) {
    console.error('[SurgeryConsent] Failed to revoke consent:', e);
  }
}

// ============================================
// CONSENT MODAL
// ============================================

export function SurgeryConsentModal({
  isOpen,
  onClose,
  onConsent,
  procedure,
}: SurgeryConsentModalProps) {
  const [step, setStep] = useState(1);
  const [acknowledged, setAcknowledged] = useState({
    risks: false,
    costs: false,
    recovery: false,
    consultation: false,
    informational: false,
  });
  const [signature, setSignature] = useState('');
  const [age, setAge] = useState<number | undefined>();

  const allAcknowledged = Object.values(acknowledged).every(Boolean);
  const canProceed = allAcknowledged && signature.length >= 2 && (age === undefined || age >= 18);

  const handleAcknowledge = (key: keyof typeof acknowledged) => {
    setAcknowledged((prev) => ({ ...prev, [key]: !prev[key] }));
  };

  const handleConsent = useCallback(() => {
    const data: SurgeryConsentData = {
      procedureId: procedure.id,
      procedureName: procedure.name,
      consentedAt: new Date().toISOString(),
      acknowledged,
      signature,
      age,
    };

    saveConsent(data);
    onConsent(data);
    onClose();

    // Reset state
    setStep(1);
    setAcknowledged({
      risks: false,
      costs: false,
      recovery: false,
      consultation: false,
      informational: false,
    });
    setSignature('');
    setAge(undefined);
  }, [procedure, acknowledged, signature, age, onConsent, onClose]);

  if (!isOpen) return null;

  return (
    <AnimatePresence>
      <motion.div
        className="fixed inset-0 z-50 flex items-center justify-center bg-black/80 backdrop-blur-sm p-4"
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        exit={{ opacity: 0 }}
        onClick={onClose}
      >
        <motion.div
          className="bg-neutral-900 border border-neutral-800 rounded-2xl w-full max-w-lg max-h-[90vh] overflow-y-auto"
          initial={{ scale: 0.95, opacity: 0 }}
          animate={{ scale: 1, opacity: 1 }}
          exit={{ scale: 0.95, opacity: 0 }}
          onClick={(e) => e.stopPropagation()}
        >
          {/* Header */}
          <div className="flex items-center justify-between p-4 border-b border-neutral-800 sticky top-0 bg-neutral-900 z-10">
            <div className="flex items-center gap-2">
              <Shield size={20} className="text-yellow-500" />
              <h3 className="font-semibold text-white">Consent Required</h3>
            </div>
            <button
              onClick={onClose}
              className="p-2 rounded-lg text-neutral-500 hover:text-white hover:bg-neutral-800"
            >
              <X size={18} />
            </button>
          </div>

          {/* Step 1: Information */}
          {step === 1 && (
            <div className="p-6 space-y-4">
              <div className="text-center mb-6">
                <div className="w-16 h-16 mx-auto mb-4 rounded-2xl bg-yellow-500/20 flex items-center justify-center">
                  <AlertTriangle size={32} className="text-yellow-500" />
                </div>
                <h4 className="text-xl font-bold text-white mb-2">
                  Important Notice
                </h4>
                <p className="text-sm text-neutral-400">
                  You are about to view information about{' '}
                  <span className="text-white font-medium">{procedure.name}</span>.
                  This is a surgical procedure with associated risks.
                </p>
              </div>

              {/* Procedure Details */}
              <div className="bg-neutral-800/50 rounded-xl p-4 space-y-3">
                <div className="flex items-center gap-3">
                  <Stethoscope size={18} className="text-cyan-400" />
                  <div>
                    <p className="text-xs text-neutral-500">Procedure</p>
                    <p className="text-sm text-white">{procedure.name}</p>
                  </div>
                </div>

                {procedure.costMin && procedure.costMax && (
                  <div className="flex items-center gap-3">
                    <DollarSign size={18} className="text-green-400" />
                    <div>
                      <p className="text-xs text-neutral-500">Estimated Cost</p>
                      <p className="text-sm text-white">
                        ${procedure.costMin.toLocaleString()} - ${procedure.costMax.toLocaleString()}
                      </p>
                    </div>
                  </div>
                )}

                {procedure.recoveryTime && (
                  <div className="flex items-center gap-3">
                    <Clock size={18} className="text-blue-400" />
                    <div>
                      <p className="text-xs text-neutral-500">Recovery Time</p>
                      <p className="text-sm text-white">{procedure.recoveryTime}</p>
                    </div>
                  </div>
                )}

                {procedure.risks && (
                  <div className="flex items-start gap-3">
                    <Heart size={18} className="text-red-400 mt-0.5" />
                    <div>
                      <p className="text-xs text-neutral-500">Associated Risks</p>
                      <p className="text-sm text-neutral-300">{procedure.risks}</p>
                    </div>
                  </div>
                )}
              </div>

              <button
                onClick={() => setStep(2)}
                className="w-full py-3 px-4 rounded-lg bg-gradient-to-r from-cyan-500 to-blue-500 hover:from-cyan-400 hover:to-blue-400 text-white font-medium transition-all flex items-center justify-center gap-2"
              >
                I Understand, Continue
                <ChevronRight size={18} />
              </button>
            </div>
          )}

          {/* Step 2: Acknowledgments */}
          {step === 2 && (
            <div className="p-6 space-y-4">
              <div className="text-center mb-4">
                <FileText size={32} className="mx-auto text-cyan-400 mb-2" />
                <h4 className="text-lg font-bold text-white">
                  Please Acknowledge
                </h4>
                <p className="text-xs text-neutral-500">
                  Check each box to confirm you understand
                </p>
              </div>

              <div className="space-y-3">
                {/* Risk Acknowledgment */}
                <label className="flex items-start gap-3 p-3 rounded-lg bg-neutral-800/50 cursor-pointer hover:bg-neutral-800 transition-colors">
                  <input
                    type="checkbox"
                    checked={acknowledged.risks}
                    onChange={() => handleAcknowledge('risks')}
                    className="mt-0.5 w-4 h-4 rounded border-neutral-600 bg-neutral-700 text-cyan-500 focus:ring-cyan-500 focus:ring-offset-0"
                  />
                  <div>
                    <p className="text-sm text-white font-medium">I understand the risks</p>
                    <p className="text-xs text-neutral-500">
                      All surgical procedures carry risks including infection, complications, and unsatisfactory results.
                    </p>
                  </div>
                </label>

                {/* Cost Acknowledgment */}
                <label className="flex items-start gap-3 p-3 rounded-lg bg-neutral-800/50 cursor-pointer hover:bg-neutral-800 transition-colors">
                  <input
                    type="checkbox"
                    checked={acknowledged.costs}
                    onChange={() => handleAcknowledge('costs')}
                    className="mt-0.5 w-4 h-4 rounded border-neutral-600 bg-neutral-700 text-cyan-500 focus:ring-cyan-500 focus:ring-offset-0"
                  />
                  <div>
                    <p className="text-sm text-white font-medium">I understand the costs</p>
                    <p className="text-xs text-neutral-500">
                      Costs vary by provider and may not be covered by insurance. Additional revision surgery may be needed.
                    </p>
                  </div>
                </label>

                {/* Recovery Acknowledgment */}
                <label className="flex items-start gap-3 p-3 rounded-lg bg-neutral-800/50 cursor-pointer hover:bg-neutral-800 transition-colors">
                  <input
                    type="checkbox"
                    checked={acknowledged.recovery}
                    onChange={() => handleAcknowledge('recovery')}
                    className="mt-0.5 w-4 h-4 rounded border-neutral-600 bg-neutral-700 text-cyan-500 focus:ring-cyan-500 focus:ring-offset-0"
                  />
                  <div>
                    <p className="text-sm text-white font-medium">I understand recovery requirements</p>
                    <p className="text-xs text-neutral-500">
                      Recovery time varies. I may need to take time off work and follow post-operative care instructions.
                    </p>
                  </div>
                </label>

                {/* Consultation Acknowledgment */}
                <label className="flex items-start gap-3 p-3 rounded-lg bg-neutral-800/50 cursor-pointer hover:bg-neutral-800 transition-colors">
                  <input
                    type="checkbox"
                    checked={acknowledged.consultation}
                    onChange={() => handleAcknowledge('consultation')}
                    className="mt-0.5 w-4 h-4 rounded border-neutral-600 bg-neutral-700 text-cyan-500 focus:ring-cyan-500 focus:ring-offset-0"
                  />
                  <div>
                    <p className="text-sm text-white font-medium">I will consult a qualified professional</p>
                    <p className="text-xs text-neutral-500">
                      I understand this app provides information only. I will consult board-certified surgeons before any procedure.
                    </p>
                  </div>
                </label>

                {/* Informational Acknowledgment */}
                <label className="flex items-start gap-3 p-3 rounded-lg bg-neutral-800/50 cursor-pointer hover:bg-neutral-800 transition-colors">
                  <input
                    type="checkbox"
                    checked={acknowledged.informational}
                    onChange={() => handleAcknowledge('informational')}
                    className="mt-0.5 w-4 h-4 rounded border-neutral-600 bg-neutral-700 text-cyan-500 focus:ring-cyan-500 focus:ring-offset-0"
                  />
                  <div>
                    <p className="text-sm text-white font-medium">This is for informational purposes only</p>
                    <p className="text-xs text-neutral-500">
                      LOOKSMAXX is not a medical provider and does not recommend or endorse any specific procedure or surgeon.
                    </p>
                  </div>
                </label>
              </div>

              {/* Signature */}
              <div className="pt-4 border-t border-neutral-800">
                <label className="block text-sm text-neutral-400 mb-2">
                  Type your initials to confirm
                </label>
                <input
                  type="text"
                  value={signature}
                  onChange={(e) => setSignature(e.target.value.toUpperCase())}
                  placeholder="e.g., JD"
                  maxLength={4}
                  className="w-full px-4 py-3 rounded-lg bg-neutral-800 border border-neutral-700 text-white placeholder:text-neutral-600 focus:outline-none focus:border-cyan-500 text-center text-lg font-mono"
                />
              </div>

              {/* Age Verification */}
              <div>
                <label className="block text-sm text-neutral-400 mb-2">
                  Confirm your age (must be 18+)
                </label>
                <input
                  type="number"
                  value={age || ''}
                  onChange={(e) => setAge(parseInt(e.target.value) || undefined)}
                  placeholder="Your age"
                  min={18}
                  max={120}
                  className="w-full px-4 py-3 rounded-lg bg-neutral-800 border border-neutral-700 text-white placeholder:text-neutral-600 focus:outline-none focus:border-cyan-500"
                />
                {age !== undefined && age < 18 && (
                  <p className="text-xs text-red-400 mt-1">
                    You must be 18 or older to view surgical procedures.
                  </p>
                )}
              </div>

              {/* Consent Button */}
              <button
                onClick={handleConsent}
                disabled={!canProceed}
                className={`w-full py-3 px-4 rounded-lg font-medium transition-all flex items-center justify-center gap-2 ${
                  canProceed
                    ? 'bg-gradient-to-r from-cyan-500 to-green-500 hover:from-cyan-400 hover:to-green-400 text-white'
                    : 'bg-neutral-800 text-neutral-600 cursor-not-allowed'
                }`}
              >
                <CheckCircle size={18} />
                I Consent & Acknowledge
              </button>

              <p className="text-[10px] text-neutral-600 text-center">
                By clicking above, you acknowledge that you have read and understood all information presented.
              </p>
            </div>
          )}
        </motion.div>
      </motion.div>
    </AnimatePresence>
  );
}

// ============================================
// CONSENT GATE COMPONENT
// ============================================

interface SurgeryConsentGateProps {
  procedureId: string;
  procedureName: string;
  children: React.ReactNode;
  onConsentGranted?: () => void;
  procedure?: {
    description?: string;
    risks?: string;
    costMin?: number;
    costMax?: number;
    recoveryTime?: string;
  };
}

export function SurgeryConsentGate({
  procedureId,
  procedureName,
  children,
  onConsentGranted,
  procedure = {},
}: SurgeryConsentGateProps) {
  const [hasConsent, setHasConsent] = useState(() => hasConsented(procedureId));
  const [showModal, setShowModal] = useState(false);

  const handleConsent = useCallback(() => {
    setHasConsent(true);
    onConsentGranted?.();
  }, [onConsentGranted]);

  if (hasConsent) {
    return <>{children}</>;
  }

  return (
    <>
      <div className="relative">
        {/* Blurred content */}
        <div className="blur-md pointer-events-none select-none opacity-50">
          {children}
        </div>

        {/* Gate overlay */}
        <div className="absolute inset-0 flex items-center justify-center bg-black/60 backdrop-blur-sm rounded-xl">
          <div className="text-center p-6 max-w-sm">
            <div className="w-14 h-14 mx-auto mb-4 rounded-2xl bg-yellow-500/20 flex items-center justify-center">
              <Shield size={28} className="text-yellow-500" />
            </div>
            <h3 className="text-lg font-semibold text-white mb-2">
              Consent Required
            </h3>
            <p className="text-sm text-neutral-400 mb-4">
              This is a surgical procedure. You must acknowledge the risks and information before viewing details.
            </p>
            <button
              onClick={() => setShowModal(true)}
              className="px-6 py-2 rounded-lg bg-gradient-to-r from-cyan-500 to-blue-500 hover:from-cyan-400 hover:to-blue-400 text-white font-medium transition-all"
            >
              View Consent Form
            </button>
          </div>
        </div>
      </div>

      <SurgeryConsentModal
        isOpen={showModal}
        onClose={() => setShowModal(false)}
        onConsent={handleConsent}
        procedure={{
          id: procedureId,
          name: procedureName,
          ...procedure,
        }}
      />
    </>
  );
}

export default SurgeryConsentModal;
