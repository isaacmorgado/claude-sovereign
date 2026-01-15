'use client';

import { useState } from 'react';
import { motion } from 'framer-motion';
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
} from 'lucide-react';
import { TabContent } from '../ResultsLayout';

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
      className={`w-full flex items-center gap-4 p-4 bg-neutral-900/60 border border-neutral-800 rounded-xl ${
        onClick ? 'hover:border-neutral-700 transition-all cursor-pointer' : ''
      }`}
    >
      <div className="w-10 h-10 rounded-lg bg-neutral-800 flex items-center justify-center flex-shrink-0">
        {icon}
      </div>
      <div className="flex-1 text-left">
        <h4 className="font-medium text-white">{title}</h4>
        {description && (
          <p className="text-sm text-neutral-500">{description}</p>
        )}
      </div>
      {children || (onClick && <ChevronRight size={18} className="text-neutral-600" />)}
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
      className={`relative w-11 h-6 rounded-full transition-colors ${
        enabled ? 'bg-cyan-500' : 'bg-neutral-700'
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
  const [showLandmarks, setShowLandmarks] = useState(true);
  const [notifications, setNotifications] = useState(true);
  const [autoSave, setAutoSave] = useState(true);

  return (
    <TabContent
      title="Options"
      subtitle="Customize your experience"
    >
      <div className="max-w-2xl space-y-6">
        {/* Display Settings */}
        <div>
          <h3 className="text-sm font-medium text-neutral-400 mb-3 uppercase tracking-wider">
            Display
          </h3>
          <div className="space-y-3">
            <SettingItem
              icon={<Eye size={20} className="text-cyan-400" />}
              title="Show Landmarks"
              description="Display facial landmarks on photos"
            >
              <ToggleSwitch enabled={showLandmarks} onToggle={() => setShowLandmarks(!showLandmarks)} />
            </SettingItem>
          </div>
        </div>

        {/* Account Settings */}
        <div>
          <h3 className="text-sm font-medium text-neutral-400 mb-3 uppercase tracking-wider">
            Account
          </h3>
          <div className="space-y-3">
            <SettingItem
              icon={<User size={20} className="text-green-400" />}
              title="Profile Settings"
              description="Manage your account information"
              onClick={() => {}}
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
              title="Privacy Settings"
              description="Control how your data is used"
              onClick={() => {}}
            />
          </div>
        </div>

        {/* Data Settings */}
        <div>
          <h3 className="text-sm font-medium text-neutral-400 mb-3 uppercase tracking-wider">
            Data
          </h3>
          <div className="space-y-3">
            <SettingItem
              icon={<Download size={20} className="text-cyan-400" />}
              title="Export Analysis"
              description="Download your results as PDF or JSON"
              onClick={() => {}}
            />

            <SettingItem
              icon={<Share2 size={20} className="text-blue-400" />}
              title="Share Results"
              description="Generate a shareable link to your analysis"
              onClick={() => {}}
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
          <h3 className="text-sm font-medium text-red-400 mb-3 uppercase tracking-wider">
            Danger Zone
          </h3>
          <div className="space-y-3">
            <SettingItem
              icon={<Trash2 size={20} className="text-red-400" />}
              title="Delete Analysis"
              description="Permanently delete this analysis and all data"
              onClick={() => {}}
            />
          </div>
        </div>
      </div>
    </TabContent>
  );
}
