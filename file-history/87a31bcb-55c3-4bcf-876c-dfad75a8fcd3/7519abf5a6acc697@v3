'use client';

import { useState, useCallback } from 'react';
import { useRouter } from 'next/navigation';
import { motion, AnimatePresence } from 'framer-motion';
import {
  User,
  Bell,
  Eye,
  Download,
  Share2,
  Trash2,
  Lock,
  Globe,
  ChevronRight,
  CheckCircle,
  AlertTriangle,
  LogOut,
} from 'lucide-react';
import { TabContent } from '../ResultsLayout';
import { useResults } from '@/contexts/ResultsContext';
import { usePricing } from '@/contexts/PricingContext';
import { AchievementsShowcase } from '@/components/achievements';
import { AnalysisReport } from '../reports/AnalysisReport';
import { useQuota } from '@/hooks/useQuota';
import { QuotaSummary } from '@/components/ui/QuotaDisplay';
import { exportToPDF, exportToImage } from '@/lib/exportReport';

// ============================================
// SETTING ITEM
// ============================================

interface SettingItemProps {
  icon: React.ReactNode;
  title: string;
  description?: string;
  children?: React.ReactNode;
  onClick?: () => void;
}

function SettingItem({ icon, title, description, children, onClick }: SettingItemProps) {
  const Wrapper = onClick ? 'button' : 'div';

  return (
    <Wrapper
      onClick={onClick}
      className={`group w-full flex items-center gap-4 p-5 rounded-2xl bg-neutral-900/40 border border-white/5 ${onClick ? 'hover:border-white/10 transition-all cursor-pointer' : ''
        }`}
    >
      <div className="w-12 h-12 rounded-xl bg-neutral-900 border border-white/10 flex items-center justify-center flex-shrink-0">
        {icon}
      </div>
      <div className="flex-1 text-left">
        <h4 className="font-black text-white">{title}</h4>
        {description && (
          <p className="text-[10px] font-bold uppercase tracking-wider text-neutral-600 mt-0.5">{description}</p>
        )}
      </div>
      {children || (onClick && (
        <div className="w-8 h-8 rounded-lg bg-neutral-900 border border-white/5 flex items-center justify-center group-hover:border-cyan-500/30 group-hover:bg-cyan-500/10 transition-all">
          <ChevronRight size={14} className="text-neutral-600 group-hover:text-cyan-400 transition-colors" />
        </div>
      ))}
    </Wrapper>
  );
}

// ============================================
// TOGGLE SWITCH
// ============================================

interface ToggleSwitchProps {
  enabled: boolean;
  onToggle: () => void;
}

function ToggleSwitch({ enabled, onToggle }: ToggleSwitchProps) {
  return (
    <button
      onClick={onToggle}
      className={`relative w-11 h-6 rounded-full transition-colors ${enabled ? 'bg-cyan-500' : 'bg-neutral-700'
        }`}
    >
      <motion.div
        className="absolute top-1 w-4 h-4 bg-white rounded-full"
        animate={{ left: enabled ? 24 : 4 }}
        transition={{ type: 'spring', stiffness: 500, damping: 30 }}
      />
    </button>
  );
}

// ============================================
// OPTIONS TAB
// ============================================

export function OptionsTab() {
  const router = useRouter();
  const {
    frontRatios,
    sideRatios,
    overallScore,
    pslRating,
    showLandmarkOverlay,
    setShowLandmarkOverlay,
  } = useResults();
  const { openPricingModal } = usePricing();
  const { analyses, downloads, forumPosts, plan } = useQuota();

  // Mock achievement data based on PSL score
  const pslScore = pslRating?.psl || 0;
  const mockAchievements = {
    unlockedIds: [
      'first-analysis',
      ...(pslScore >= 5.0 ? ['above-average'] : []),
      ...(pslScore >= 6.0 ? ['top-tier'] : []),
      ...(pslScore >= 7.0 ? ['elite'] : []),
      ...(pslScore >= 7.5 ? ['top-model'] : []),
    ],
    progress: {
      'analysis-veteran': 1,
      'streak-3': 1,
      'streak-7': 1,
      'streak-30': 1,
    },
    totalXp: 50 +
      (pslScore >= 5.0 ? 100 : 0) +
      (pslScore >= 6.0 ? 250 : 0) +
      (pslScore >= 7.0 ? 500 : 0) +
      (pslScore >= 7.5 ? 1000 : 0),
  };
  const [notifications, setNotifications] = useState(true);
  const [autoSave, setAutoSave] = useState(true);
  const [toast, setToast] = useState<{ message: string; type: 'success' | 'error' } | null>(null);
  const [showDeleteConfirm, setShowDeleteConfirm] = useState(false);
  const [showLogoutConfirm, setShowLogoutConfirm] = useState(false);

  const showToast = useCallback((message: string, type: 'success' | 'error' = 'success') => {
    setToast({ message, type });
    setTimeout(() => setToast(null), 3000);
  }, []);

  const handleProfile = () => {
    // If we have an authentication system, this would go to profile
    // For now, if no profile page exists, we show a toast or redirect to login/signup
    const token = localStorage.getItem('auth_token');
    if (token) {
      showToast('Profile settings coming soon!');
    } else {
      router.push('/login');
    }
  };

  const handlePrivacy = () => {
    router.push('/privacy');
  };

  const handleLogout = () => {
    localStorage.removeItem('auth_token');
    localStorage.removeItem('user');
    showToast('Logged out successfully');
    setShowLogoutConfirm(false);
    setTimeout(() => router.push('/'), 1000);
  };



  // ... (inside component)

  const handleExport = useCallback(async () => {
    showToast('Generating PDF...', 'success');
    try {
      // Use existing utility which handles html2canvas + jsPDF
      const result = await exportToPDF('pdf-report-container', {
        filename: `LooxsmaxxLabs_Report_${new Date().toISOString().split('T')[0]}`,
        scale: 2, // High quality
        pageFormat: 'a4',
        margins: 10
      });

      if (result.success) {
        showToast('PDF Exported Successfully!');
      } else {
        showToast('Failed to generate PDF', 'error');
        console.error(result.error);
      }
    } catch {
      showToast('Failed to export', 'error');
    }
  }, [showToast]);

  const handleShare = useCallback(async () => {
    showToast('Generating shareable card...', 'success');
    try {
      // Just export the same report as an image for now, or we could target a specific subsection
      // Ideally we'd have a specific "SocialCard" element, but the report is good too.
      const result = await exportToImage('pdf-report-container', {
        filename: `LooxsmaxxLabs_Card_${new Date().toISOString().split('T')[0]}`,
        scale: 2
      });

      if (result.success) {
        showToast('Image saved! Ready to share.');
      } else {
        showToast('Failed to generate image', 'error');
      }
    } catch {
      showToast('Failed to share', 'error');
    }
  }, [showToast]);

  const handleDeleteAnalysis = useCallback(() => {
    // Clear localStorage
    localStorage.removeItem('looksmaxx_results');
    localStorage.removeItem('looksmaxx_photos');
    showToast('Analysis deleted successfully');
    setShowDeleteConfirm(false);
    // Redirect to home after short delay
    setTimeout(() => router.push('/'), 1500);
  }, [router, showToast]);

  return (
    <TabContent
      title="Options"
      subtitle="Customize your experience"
    >
      {/* Toast notification */}
      <AnimatePresence>
        {toast && (
          <motion.div
            initial={{ opacity: 0, y: -20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -20 }}
            className={`fixed top-4 right-4 z-50 px-4 py-3 rounded-lg shadow-lg flex items-center gap-2 ${toast.type === 'success'
              ? 'bg-neutral-800 border border-neutral-700'
              : 'bg-red-900/80 border border-red-700'
              }`}
          >
            {toast.type === 'success' ? (
              <CheckCircle size={16} className="text-cyan-400" />
            ) : (
              <AlertTriangle size={16} className="text-red-400" />
            )}
            <span className="text-sm text-white">{toast.message}</span>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Logout confirmation modal */}
      <AnimatePresence>
        {showLogoutConfirm && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 z-50 flex items-center justify-center bg-black/80 backdrop-blur-sm p-4"
          >
            <motion.div
              initial={{ scale: 0.95, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              exit={{ scale: 0.95, opacity: 0 }}
              className="bg-neutral-900/90 border border-white/10 rounded-2xl p-8 max-w-sm w-full"
            >
              <div className="flex items-center gap-4 mb-6">
                <div className="w-12 h-12 rounded-xl bg-neutral-800 border border-white/10 flex items-center justify-center">
                  <LogOut size={22} className="text-white" />
                </div>
                <h3 className="text-xl font-black text-white">Sign Out?</h3>
              </div>
              <p className="text-neutral-500 text-sm mb-8">
                Are you sure you want to sign out of your account?
              </p>
              <div className="flex gap-4">
                <button
                  onClick={() => setShowLogoutConfirm(false)}
                  className="flex-1 px-5 py-3 bg-neutral-800 border border-white/5 text-white font-bold rounded-xl hover:bg-neutral-700 transition-colors"
                >
                  Cancel
                </button>
                <button
                  onClick={handleLogout}
                  className="flex-1 px-5 py-3 bg-cyan-500 text-black font-black uppercase tracking-wider rounded-xl hover:bg-cyan-400 transition-colors"
                >
                  Sign Out
                </button>
              </div>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Delete confirmation modal */}
      <AnimatePresence>
        {showDeleteConfirm && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 z-50 flex items-center justify-center bg-black/80 backdrop-blur-sm p-4"
          >
            <motion.div
              initial={{ scale: 0.95, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              exit={{ scale: 0.95, opacity: 0 }}
              className="bg-neutral-900/90 border border-white/10 rounded-2xl p-8 max-w-sm w-full"
            >
              <div className="flex items-center gap-4 mb-6">
                <div className="w-12 h-12 rounded-xl bg-red-500/15 border border-red-500/20 flex items-center justify-center">
                  <AlertTriangle size={22} className="text-red-400" />
                </div>
                <h3 className="text-xl font-black text-white">Delete Analysis?</h3>
              </div>
              <p className="text-neutral-500 text-sm mb-8">
                This will permanently delete your analysis and all associated data. This action cannot be undone.
              </p>
              <div className="flex gap-4">
                <button
                  onClick={() => setShowDeleteConfirm(false)}
                  className="flex-1 px-5 py-3 bg-neutral-800 border border-white/5 text-white font-bold rounded-xl hover:bg-neutral-700 transition-colors"
                >
                  Cancel
                </button>
                <button
                  onClick={handleDeleteAnalysis}
                  className="flex-1 px-5 py-3 bg-red-500 text-white font-black uppercase tracking-wider rounded-xl hover:bg-red-400 transition-colors"
                >
                  Delete
                </button>
              </div>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>

      <div className="max-w-2xl space-y-8">
        {/* Achievements Section */}
        <div>
          <h3 className="text-[10px] font-black uppercase tracking-[0.4em] text-neutral-600 mb-4 flex items-center gap-4">
            Achievements
            <div className="flex-1 h-px bg-neutral-800" />
          </h3>
          <AchievementsShowcase
            unlockedIds={mockAchievements.unlockedIds}
            progress={mockAchievements.progress}
            totalXp={mockAchievements.totalXp}
            compact={true}
          />
        </div>

        {/* Usage & Quota Section */}
        <div>
          <h3 className="text-[10px] font-black uppercase tracking-[0.4em] text-neutral-600 mb-4 flex items-center gap-4">
            Usage & Quota
            <div className="flex-1 h-px bg-neutral-800" />
          </h3>
          <QuotaSummary
            analyses={analyses}
            downloads={downloads}
            forumPosts={forumPosts}
            plan={plan}
            onUpgrade={openPricingModal}
          />
        </div>

        {/* Display Settings */}
        <div>
          <h3 className="text-[10px] font-black uppercase tracking-[0.4em] text-neutral-600 mb-4 flex items-center gap-4">
            Display
            <div className="flex-1 h-px bg-neutral-800" />
          </h3>
          <div className="space-y-3">
            <SettingItem
              icon={<Eye size={20} className="text-cyan-400" />}
              title="Show Landmarks"
              description="Display facial landmarks on photos"
            >
              <ToggleSwitch enabled={showLandmarkOverlay} onToggle={() => setShowLandmarkOverlay(!showLandmarkOverlay)} />
            </SettingItem>
          </div>
        </div>

        {/* Account Settings */}
        <div>
          <h3 className="text-[10px] font-black uppercase tracking-[0.4em] text-neutral-600 mb-4 flex items-center gap-4">
            Account
            <div className="flex-1 h-px bg-neutral-800" />
          </h3>
          <div className="space-y-3">
            <SettingItem
              icon={<User size={20} className="text-green-400" />}
              title="Profile Settings"
              description="Manage your account information"
              onClick={handleProfile}
            />

            <SettingItem
              icon={<Bell size={20} className="text-yellow-400" />}
              title="Notifications"
              description="Receive updates about your analysis"
            >
              <ToggleSwitch enabled={notifications} onToggle={() => setNotifications(!notifications)} />
            </SettingItem>

            <SettingItem
              icon={<Lock size={20} className="text-red-400" />}
              title="Privacy & Terms"
              description="Control how your data is used"
              onClick={handlePrivacy}
            />

            <SettingItem
              icon={<LogOut size={20} className="text-neutral-400" />}
              title="Sign Out"
              description="Logout of your account"
              onClick={() => setShowLogoutConfirm(true)}
            />
          </div>
        </div>

        {/* Data Settings */}
        <div>
          <h3 className="text-[10px] font-black uppercase tracking-[0.4em] text-neutral-600 mb-4 flex items-center gap-4">
            Data
            <div className="flex-1 h-px bg-neutral-800" />
          </h3>
          <div className="space-y-3">
            <SettingItem
              icon={<Download size={20} className="text-cyan-400" />}
              title="Export Analysis"
              description="Download your results as PDF"
              onClick={handleExport}
            />

            <SettingItem
              icon={<Share2 size={20} className="text-blue-400" />}
              title="Share Results"
              description="Download shareable result card"
              onClick={handleShare}
            />

            <SettingItem
              icon={<Globe size={20} className="text-purple-400" />}
              title="Auto-Save"
              description="Automatically save analysis to cloud"
            >
              <ToggleSwitch enabled={autoSave} onToggle={() => setAutoSave(!autoSave)} />
            </SettingItem>
          </div>
        </div>

        {/* Danger Zone */}
        <div>
          <h3 className="text-[10px] font-black uppercase tracking-[0.4em] text-red-500/80 mb-4 flex items-center gap-4">
            Danger Zone
            <div className="flex-1 h-px bg-red-500/20" />
          </h3>
          <div className="space-y-3">
            <div className="group w-full flex items-center gap-4 p-5 rounded-2xl bg-red-500/5 border border-red-500/20 hover:border-red-500/40 transition-all cursor-pointer"
              onClick={() => setShowDeleteConfirm(true)}
            >
              <div className="w-12 h-12 rounded-xl bg-red-500/10 border border-red-500/20 flex items-center justify-center flex-shrink-0">
                <Trash2 size={20} className="text-red-400" />
              </div>
              <div className="flex-1 text-left">
                <h4 className="font-black text-red-400">Delete Analysis</h4>
                <p className="text-[10px] font-bold uppercase tracking-wider text-red-400/60 mt-0.5">Permanently delete this analysis and all data</p>
              </div>
              <div className="w-8 h-8 rounded-lg bg-red-500/10 border border-red-500/20 flex items-center justify-center group-hover:bg-red-500/20 transition-all">
                <ChevronRight size={14} className="text-red-400" />
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Hidden Report Container for Capture */}
      <div style={{ position: 'fixed', left: '-9999px', top: 0 }}>
        <div id="pdf-report-container">
          <AnalysisReport
            analysis={{
              front_image_url: localStorage.getItem('looksmaxx_front_photo'),
              side_image_url: localStorage.getItem('looksmaxx_side_photo'),
              front_landmarks: (() => {
                try {
                  const results = JSON.parse(localStorage.getItem('looksmaxx_results') || '{}');
                  return results?.analysis?.front_landmarks || [];
                } catch { return []; }
              })(),
              side_landmarks: (() => {
                try {
                  const results = JSON.parse(localStorage.getItem('looksmaxx_results') || '{}');
                  return results?.analysis?.side_landmarks || [];
                } catch { return []; }
              })(),
              scores: { masculinity: 50, femininity: 50, symmetry: 50, skinQuality: 50, aging: 25 },
            }}
            results={{ overallScore, pslRating, frontRatios, sideRatios }}
            userName={(() => {
              try {
                return JSON.parse(localStorage.getItem('user') || '{}').username || 'User';
              } catch { return 'User'; }
            })()}
            isUnlocked={plan === 'pro' || plan === 'plus'}
          />
        </div>
      </div>
    </TabContent>
  );
}
