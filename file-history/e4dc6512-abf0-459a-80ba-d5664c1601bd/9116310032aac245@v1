'use client';

import { motion } from 'framer-motion';
import {
  HelpCircle,
  Book,
  MessageCircle,
  Mail,
  ExternalLink,
  ChevronRight,
  FileText,
  Video,
  Users,
} from 'lucide-react';
import { TabContent } from '../ResultsLayout';

// ============================================
// SUPPORT CARD
// ============================================

interface SupportCardProps {
  icon: React.ReactNode;
  title: string;
  description: string;
  action?: string;
  onClick?: () => void;
  external?: boolean;
}

function SupportCard({ icon, title, description, action, onClick, external }: SupportCardProps) {
  return (
    <motion.button
      onClick={onClick}
      className="w-full p-4 bg-neutral-900/60 border border-neutral-800 rounded-xl hover:border-neutral-700 transition-all text-left"
      whileHover={{ scale: 1.01 }}
      whileTap={{ scale: 0.99 }}
    >
      <div className="flex items-start gap-4">
        <div className="w-12 h-12 rounded-xl bg-gradient-to-br from-cyan-500/20 to-blue-600/20 flex items-center justify-center flex-shrink-0">
          {icon}
        </div>
        <div className="flex-1">
          <h4 className="font-medium text-white mb-1">{title}</h4>
          <p className="text-sm text-neutral-500">{description}</p>
          {action && (
            <div className="flex items-center gap-1 mt-2 text-sm text-cyan-400">
              {action}
              {external ? <ExternalLink size={14} /> : <ChevronRight size={14} />}
            </div>
          )}
        </div>
      </div>
    </motion.button>
  );
}

// ============================================
// FAQ ITEM
// ============================================

interface FAQItemProps {
  question: string;
  answer: string;
}

function FAQItem({ question, answer }: FAQItemProps) {
  return (
    <div className="p-4 bg-neutral-900/40 border border-neutral-800 rounded-xl">
      <h4 className="font-medium text-white mb-2">{question}</h4>
      <p className="text-sm text-neutral-400">{answer}</p>
    </div>
  );
}

// ============================================
// SUPPORT TAB
// ============================================

export function SupportTab() {
  return (
    <TabContent
      title="Support"
      subtitle="Get help and learn more about facial analysis"
    >
      <div className="max-w-3xl space-y-8">
        {/* Quick Help */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <SupportCard
            icon={<Book size={24} className="text-cyan-400" />}
            title="Documentation"
            description="Learn about facial measurements and what they mean"
            action="Read docs"
            onClick={() => {}}
          />
          <SupportCard
            icon={<Video size={24} className="text-purple-400" />}
            title="Video Tutorials"
            description="Watch step-by-step guides on using the app"
            action="Watch videos"
            onClick={() => {}}
            external
          />
          <SupportCard
            icon={<MessageCircle size={24} className="text-green-400" />}
            title="Community"
            description="Connect with others and share experiences"
            action="Join Discord"
            onClick={() => {}}
            external
          />
          <SupportCard
            icon={<Mail size={24} className="text-yellow-400" />}
            title="Contact Support"
            description="Get personalized help from our team"
            action="Send email"
            onClick={() => {}}
          />
        </div>

        {/* FAQ Section */}
        <div>
          <h3 className="text-lg font-semibold text-white mb-4 flex items-center gap-2">
            <HelpCircle size={20} className="text-cyan-400" />
            Frequently Asked Questions
          </h3>
          <div className="space-y-3">
            <FAQItem
              question="How accurate is the facial analysis?"
              answer="Our analysis uses advanced AI models trained on thousands of facial measurements. While results are highly accurate for general proportions, individual variations exist. Use results as a guide rather than absolute measurements."
            />
            <FAQItem
              question="What do the scores mean?"
              answer="Scores range from 0-10, where 10 represents ideal proportions based on established facial harmony standards. Scores above 7 are considered good, above 8 excellent, and above 9 exceptional."
            />
            <FAQItem
              question="Can I improve my facial harmony score?"
              answer="Yes! The 'Your Plan' section provides personalized recommendations ranging from foundational lifestyle changes to minimally invasive and surgical options. Many improvements are achievable without surgery."
            />
            <FAQItem
              question="Are my photos stored securely?"
              answer="Your photos are processed locally in your browser and are not stored on our servers unless you explicitly choose to save them. All data is encrypted and you can delete it at any time."
            />
            <FAQItem
              question="Why are my front and side scores different?"
              answer="Front and side profiles measure different facial features. It's common to have different scores as facial harmony varies by angle. The overall score balances both profiles."
            />
          </div>
        </div>

        {/* Resources */}
        <div>
          <h3 className="text-lg font-semibold text-white mb-4 flex items-center gap-2">
            <FileText size={20} className="text-cyan-400" />
            Additional Resources
          </h3>
          <div className="space-y-2">
            <a
              href="#"
              className="flex items-center justify-between p-3 bg-neutral-900/40 border border-neutral-800 rounded-lg hover:border-neutral-700 transition-colors"
            >
              <span className="text-sm text-neutral-300">Understanding Facial Proportions</span>
              <ExternalLink size={14} className="text-neutral-500" />
            </a>
            <a
              href="#"
              className="flex items-center justify-between p-3 bg-neutral-900/40 border border-neutral-800 rounded-lg hover:border-neutral-700 transition-colors"
            >
              <span className="text-sm text-neutral-300">The Science of Facial Harmony</span>
              <ExternalLink size={14} className="text-neutral-500" />
            </a>
            <a
              href="#"
              className="flex items-center justify-between p-3 bg-neutral-900/40 border border-neutral-800 rounded-lg hover:border-neutral-700 transition-colors"
            >
              <span className="text-sm text-neutral-300">Non-Surgical Enhancement Guide</span>
              <ExternalLink size={14} className="text-neutral-500" />
            </a>
          </div>
        </div>

        {/* Contact */}
        <div className="bg-gradient-to-r from-cyan-500/10 to-blue-600/10 border border-cyan-500/20 rounded-xl p-6 text-center">
          <Users size={32} className="mx-auto text-cyan-400 mb-3" />
          <h3 className="text-lg font-semibold text-white mb-2">Still need help?</h3>
          <p className="text-sm text-neutral-400 mb-4">
            Our support team is available 24/7 to assist you with any questions.
          </p>
          <button className="px-6 py-2.5 bg-cyan-500 text-black font-medium rounded-lg hover:bg-cyan-400 transition-colors">
            Contact Support
          </button>
        </div>
      </div>
    </TabContent>
  );
}
